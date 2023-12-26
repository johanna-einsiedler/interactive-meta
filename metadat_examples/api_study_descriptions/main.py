from fastapi import FastAPI
import json

app = FastAPI()


@app.get("/{study_id}")
async def read_item(study_id):
    with open('study_descriptions/'+study_id+'.txt', 'r') as file:
        data = json.load(file)
    print(data)
    return data