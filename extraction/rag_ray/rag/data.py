from pathlib import Path

from bs4 import BeautifulSoup, NavigableString
import sys
sys.path.append("..")
from rag.config import DOCS_DIR

import os

from langchain.document_loaders import PyPDFLoader

def extract_pages(record):
    loader = PyPDFLoader(os.path.join(DOCS_DIR,record['path']))
    pages = loader.load_and_split()
    page_list = []
    for i,page in enumerate(pages):
        page_id = i
        uri = path_to_uri(path=record['path'])
        page_list.append({'source': f"{uri}#{page_id}", "text": page.page_content})
    return page_list

def extract_text_from_section(section):
    texts = []
    for elem in section.children:
        if isinstance(elem, NavigableString):
            if elem.strip():
                texts.append(elem.strip())
        elif elem.name == "section":
            continue
        else:
            texts.append(elem.get_text().strip())
    return "\n".join(texts)


def path_to_uri(path, scheme="https://", domain="docs.ray.io"):
    return scheme + domain + str(path).split(domain)[-1]




def fetch_text(uri):
    url, anchor = uri.split("#") if "#" in uri else (uri, None)
    file_path = Path(EFS_DIR, url.split("https://")[-1])
    with open(file_path, "r", encoding="utf-8") as file:
        html_content = file.read()
    soup = BeautifulSoup(html_content, "html.parser")
    if anchor:
        target_element = soup.find(id=anchor)
        if target_element:
            text = target_element.get_text()
        else:
            return fetch_text(uri=url)
    else:
        text = soup.get_text()
    return text
