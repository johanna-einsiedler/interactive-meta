from pathlib import Path

from bs4 import BeautifulSoup, NavigableString
import sys
sys.path.append("..")
from rag.config import DOCS_DIR
import rag

import os
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.document_loaders import PyPDFLoader

from io import StringIO
from pdfminer.high_level import extract_text_to_fp
from pdfminer.layout import LAParams
from pdfminer.utils import open_filename
import re
from bs4 import BeautifulSoup
from langchain_core.documents import Document
from bs4.element import Comment


def extract_pages(record):
    loader = PyPDFLoader(os.path.join(DOCS_DIR,record['path']))
    pages = loader.load_and_split()
    page_list = []
    for i,page in enumerate(pages):
        page_id = i
        uri = path_to_uri(path=record['path'])
        page_list.append({'source': f"{uri}#{page_id}", "text": page.page_content})
    return page_list

def get_sections(record):
    content_length = 1
    # initialize counter
    i=0
    semantic_snippets = []
    page_list = []
    all_snippets =[]
    # create paper id from name
    paper_id = str(record['path']).split('/')[-1].split('.')[0]
    print(paper_id)
    # open file
    with open_filename(record['path'], "rb") as fp:
        # while we still have pages left
        # find different types of styles in the text
        cur_text = ''
        while (cur_text!='' or i==0):
            #print('text',cur_text)
            page_id = i+1
            print(page_id)
            output_string = StringIO()
            # extract page text and write it as HTML into output_string 
            extract_text_to_fp(
                fp,  # type: ignore[arg-type]
                output_string,
                codec="",
                page_numbers=[i],
                maxpages=1,
                laparams=LAParams(),
                output_type="html",
                )
            # collect metadata
            metadata = {
                #"source": record['path'],
                'page': page_id,
                'paper_id': paper_id,
                'id': paper_id+'_'+str(i)
                }

            # parse html
            soup = BeautifulSoup(output_string.getvalue(),'html.parser')
            content = soup.find_all('div')
            snippets = [] 

            cur_text = ''
            cur_fs = None
            # first collect all snippets that have the same font size
            for c in content:
                sp = c.find('span')
                if not sp:
                    continue
                st = sp.get('style')
                if not st:
                    continue
                fs = re.findall('font-size:(\d+)px',st)
                if not fs:
                    continue
                fs = int(fs[0])
                if not cur_fs:
                    cur_fs = fs
                if fs == cur_fs:
                    cur_text += c.text
                else:
                    snippets.append((cur_text,cur_fs,page_id))
                    cur_fs = fs
                    cur_text = c.text
            snippets.append((cur_text,cur_fs,page_id))
            i+=1
    # remove duplicates (those are most likely footnotes etc.)
        #snippets = list(set(snippets))  
    docs =[]
    for s in all_snippets:
        smetadata = metadata.copy()
        smetadata['font_size'] = s[1]
        docs.append([Document(page_content=s[0], metadata=smetadata)][0])
        

    return docs


""" # remove duplicates (those are most likely footnotes etc.)
snippets = list(set(snippets))  
data = [Document(page_content=output_string.getvalue(), metadata=metadata)][0]
content_length = len(snippets[len(snippets)-1][0])
if content_length >0:
    cur_idx = -1
    semantic_snippets = []
    # Assumption: headings have higher font size than their respective content
    for s in snippets:
        if len(s[0])>0:
            # if current snippet's font size > previous section's heading => it is a new heading
            if not semantic_snippets or s[1] > semantic_snippets[cur_idx].metadata['heading_font']:
                metadata={'heading':s[0], 'content_font': 0, 'heading_font': s[1]}
                metadata.update(data.metadata)
                semantic_snippets.append(Document(page_content='',metadata=metadata))
                cur_idx += 1
                continue

            # if current snippet's font size <= previous section's content => content belongs to the same section (one can also create
            # a tree like structure for sub sections if needed but that may require some more thinking and may be data specific)
            if not semantic_snippets[cur_idx].metadata['content_font'] or s[1] <= semantic_snippets[cur_idx].metadata['content_font']:
                semantic_snippets[cur_idx].page_content += s[0]
                semantic_snippets[cur_idx].metadata['content_font'] = max(s[1], semantic_snippets[cur_idx].metadata['content_font'])
                continue

            # if current snippet's font size > previous section's content but less than previous section's heading than also make a new
            # section (e.g. title of a PDF will have the highest font size but we don't want it to subsume all sections)
            metadata={'heading':s[0], 'content_font': 0, 'heading_font': s[1]}
            metadata.update(data.metadata)
            semantic_snippets.append(Document(page_content='',metadata=metadata))
            cur_idx += 1
"""



# define function to split sections into even smaller chunks
def chunk_section(section, chunk_size=300, chunk_overlap=50):
    text_splitter = RecursiveCharacterTextSplitter(
        separators= ["\n\n", ""] ,
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        length_function=len)
    docs = []
    for i, chunk in enumerate(text_splitter.split_text(section.page_content)):
        section_metadata = section.metadata.copy()
        section_metadata['id'] = section_metadata['id']+'_'+str(i)
        section_metadata['chunk_id'] = str(i)
        docs.append(Document(page_content = chunk, metadata = section_metadata))
    
    return docs


