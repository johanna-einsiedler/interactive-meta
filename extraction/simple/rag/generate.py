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



class QueryAgent:
    def __init__(self, embedding_model_name='',
                 llm='gpt-3.5-turbo', temperature=0.0, 
                 max_context_length=4096, system_content="", assistant_content=""):
        
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

    def __call__(self, query, num_chunks=5, stream=True):
        # Get sources and context

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
