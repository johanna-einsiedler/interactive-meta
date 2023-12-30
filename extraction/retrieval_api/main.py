import time
from rag.generate import QueryAgent
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from rag.config import MAX_CONTEXT_LENGTHS
import chromadb
from chromadb.utils import embedding_functions
import rag
import os
#os.environ["R_HOME"] = r"/Library/Frameworks/R.framework/Versions/4.1/Resources/"

app = FastAPI()



#@app.put("/{study_id}")
#async def update_item(study_id: str):

   # agent = QueryAgent(
     #   embedding_model_name='',
     #   llm=llm,
    #    max_context_length=MAX_CONTEXT_LENGTHS[llm],
    #    system_content=system_content)
    #result = agent(query=query, stream=False)
 #   result = {'test':study_id}
  #  return result



class Query(BaseModel):
    query: str



class Answer(BaseModel):
    question: str
    sources: List[str]
    answer: str
    llm: str


app = FastAPI()


#@app.get("/")
#async def root():

@app.post("/query")
def query(self, query: Query):

    #query = "What is the main result of the study?"
    system_content = ''
    llm = 'gpt-3.5-turbo'

    agent = QueryAgent(
       embedding_model_name='',
        llm=llm,
        max_context_length=MAX_CONTEXT_LENGTHS[llm],
        system_content=system_content)
    result = agent(query=query.query, stream=False)
    return result


