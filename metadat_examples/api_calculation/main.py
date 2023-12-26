from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional
import subprocess
import os
import pandas as pd
import ast
import sys
import json
#os.environ["R_HOME"] = r"/Library/Frameworks/R.framework/Versions/4.1/Resources/"

app = FastAPI()


class Filter(BaseModel):
    id: Optional[list] = None
    description: Optional[list] = None 
    display_name: Optional[list] = None
    type: Optional[list] = None
    values: Optional[list] = None
    display_values: Optional[list] = None
    display: Optional[list] = None

class FilterList(BaseModel):
    filters: list = []




@app.put("/items/{study_id}")
async def update_item(study_id: str, filterlist: FilterList):
    shell_command = 'Rscript run_analysis.R ' + "'"+ study_id+"'" +" '"+json.dumps(filterlist.filters)+"'"
    print(json.dumps(filterlist.filters))
    out = subprocess.run(shell_command ,shell=True, capture_output=True)
    results = {"dataset": out.stdout}
    return results