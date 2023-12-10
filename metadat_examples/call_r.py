import subprocess
import os
import pandas as pd
import ast
import sys

if __name__ == "__main__":
    # first argument should be name of the dataset as given in the R documentation
    dataset = sys.argv[1]
    # second argument should be input string for filters
    input = sys.argv[2]
    # Use ast.literal_eval to convert the string to a list
    input = ast.literal_eval(input)

    # call R file 
    out = subprocess.run(['/Library/Frameworks/R.framework/Versions/4.1/Resources/bin/Rscript', 'calculation_scripts/'+dataset+'.R'] + [str(dataset),str(input)], universal_newlines=True,capture_output=True )
    #print(ast.literal_eval(out.stdout))
    print(out)
