import os

from langchain.embeddings import OpenAIEmbeddings
from langchain.embeddings.huggingface import HuggingFaceEmbeddings

# function to add to collection
def add_to_collection(collection, chunk):
    collection.upsert(
    documents= chunk.page_content,
    metadatas=chunk.metadata,
    ids=chunk.metadata['id']
    )