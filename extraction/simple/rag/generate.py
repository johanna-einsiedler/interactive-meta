import json
import pickle
import re
import time
from pathlib import Path

from IPython.display import JSON, clear_output, display
from rank_bm25 import BM25Okapi
from tqdm import tqdm

from rag.config import EFS_DIR, ROOT_DIR
from rag.utils import get_client, get_num_tokens, trim

import chromadb
from chromadb.utils import embedding_functions

import os

def response_stream(chat_completion):
    for chunk in chat_completion:
        content = chunk.choices[0].delta.content
        if content is not None:
            yield content


def prepare_response(chat_completion, stream):
    if stream:
        return response_stream(chat_completion)
    else:
        return chat_completion.choices[0].message.content


def generate_response(
    llm,
    max_tokens=None,
    temperature=0.0,
    stream=False,
    system_content="",
    assistant_content="",
    user_content="",
    max_retries=1,
    retry_interval=60,
):
    """Generate response from an LLM."""
    retry_count = 0
    client = get_client(llm=llm)
    messages = [
        {"role": role, "content": content}
        for role, content in [
            ("system", system_content),
            ("assistant", assistant_content),
            ("user", user_content),
        ]
        if content
    ]
    while retry_count <= max_retries:
        try:
            chat_completion = client.chat.completions.create(
                model=llm,
                max_tokens=max_tokens,
                temperature=temperature,
                stream=stream,
                messages=messages,
            )
            return prepare_response(chat_completion, stream=stream)

        except Exception as e:
            print(f"Exception: {e}")
            time.sleep(retry_interval)  # default is per-minute rate limits
            retry_count += 1
    return ""


class QueryAgent:
    def __init__(self, embedding_model_name='',
                 llm='gpt-3.5-turbo', temperature=0.0, 
                 max_context_length=4096, system_content="", assistant_content="", 
                 client =  chromadb.PersistentClient(path="/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/extraction/simple/chromadb/"),
                collection_name = "paper_collection"):
    
  

        
        # Embedding model
      #  self.embedding_model = get_embedding_model(
       #     embedding_model_name=embedding_model_name, 
       #     model_kwargs={"device": "cuda"}, 
       #     encode_kwargs={"device": "cuda", "batch_size": 100})
        
        # Context length (restrict input length to 50% of total context length)
        max_context_length = int(0.5*max_context_length)
        
        # LLM
        self.llm = llm
        self.temperature = temperature
        self.context_length = max_context_length - get_num_tokens(system_content + assistant_content)
        self.system_content = system_content
        self.assistant_content = assistant_content
        self.client = client
        self.collection_name = collection_name

    def __call__(self, query, num_chunks=5, stream=True):
        # Get sources and context
        client = self.client
        embedding_model_name = "text-embedding-ada-002"
        # define embedding function
        openai_ef = embedding_functions.OpenAIEmbeddingFunction(
                model_name=embedding_model_name,
                api_key=os.environ["OPENAI_API_KEY"] 
            )
        collection = client.get_or_create_collection(
        name=self.collection_name,
        metadata={"hnsw:space": "cosine"} ,
        embedding_function= openai_ef
    )

        context_results = collection.query(
    query_texts=[query],
    n_results=num_chunks,
    #where={"metadata_field": "is_equal_to_this"},
    #where_document={"$contains":"search_string"}
)
       # context_results = semantic_search(
        ##   embedding_model=self.embedding_model, 
          #  k=num_chunks)
            
        # Generate response
        context = context_results['documents']
        #context = [item["text"] for item in context_results]
        #sources = [item["source"] for item in context_results]
        user_content = f"query: {query}, context: {context}"
        answer = generate_response(
            llm=self.llm,
            temperature=self.temperature,
            stream=stream,
            system_content=self.system_content,
            assistant_content=self.assistant_content,
            user_content=trim(user_content, self.context_length))

        # Result
        result = {
            "question": query,
            #"sources": sources,
            "sources": context,
            'metadatas': context_results['metadatas'],
            "answer": answer,
            "llm": self.llm,
        }
        return result
