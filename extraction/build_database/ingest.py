from pathlib import Path
from rag.config import ROOT_DIR, EFS_DIR, DOCS_DIR, MAX_CONTEXT_LENGTHS
from rag.embed import add_to_collection
import matplotlib.pyplot as plt
from dotenv import load_dotenv; load_dotenv()
import os
import numpy as np

# chromadb
import chromadb
from chromadb.utils import embedding_functions

# langchain
from langchain.text_splitter import RecursiveCharacterTextSplitter
from rag.data import extract_pages, get_sections, chunk_section




# get path to docs
list_of_docs = [{"path": path} for path in DOCS_DIR.rglob("*.pdf") if not path.is_dir()]

# read in pdfs and split into sections
sections = list(map(get_sections,list_of_docs))
sections =[item for sublist in sections for item in sublist]

# split sections further into chunks
chunks = list(map(chunk_section, sections))
chunks =[item for sublist in chunks for item in sublist]


# set client
client = chromadb.PersistentClient(path=os.path.join(ROOT_DIR,"chromadb/"))

# define embedding model name
embedding_model_name = "text-embedding-ada-002"

# define embedding function
openai_ef = embedding_functions.OpenAIEmbeddingFunction(
                model_name=embedding_model_name,
                api_key=os.environ["OPENAI_API_KEY"] 
            )

# get collection
collection = client.get_or_create_collection(
        name="paper_collection",
        metadata={"hnsw:space": "cosine"} ,
        embedding_function= openai_ef
    )

# embed and add chunks to database
list(map(add_to_collection,list(np.repeat(collection,len(chunks))),chunks))

print('Ingested:'+list_of_docs)