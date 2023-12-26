import subprocess
import os
import pandas as pd
import ast
import sys
#os.environ["R_HOME"] = r"/Library/Frameworks/R.framework/Versions/4.1/Resources/"

if __name__ == "__main__":
    # first argument should be name of the dataset as given in the R documentation
    dataset = sys.argv[1]
    # second argument should be input string for filters
    input = sys.argv[2]
    # Use ast.literal_eval to convert the string to a list
    #input = ast.literal_eval(input)
    # call R file 
    #out = subprocess.run(['open','/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/api_calculation/run_analysis.R'] + ['dataloe2013','[{"id":["study"],"description":["study author(s) and year"],"display_name":[],"type":["character"],"values":["Abu-Bader (2000)","Cole et al. (2004)","Wallach & Mueller (2006)","Weaver et al. (2007)","Acker (2004)"],"display_values":[],"display":["false"]},{"id":["n"],"description":["sample size"],"display_name":[],"type":["integer"],"values":["218","232","156","382","259"],"display_values":[],"display":["false"]},{"id":["tval"],"description":["t-statistic for the test of the association/predictor"],"display_name":[],"type":["numeric"],"values":["4.61","6.19","4.07","-0.77","1.16"],"display_values":[],"display":["true"]},{"id":["preds"],"description":["number of predictors included in the regression model"],"display_name":[],"type":["integer"],"values":["4","7","6","19","15"],"display_values":[],"display":["false"]},{"id":["R2"],"description":["the coefficient of determination (i.e., R-squared value) of the regression model"],"display_name":[],"type":["numeric"],"values":["0.24","0.455","0.5","0.327","0.117"],"display_values":[],"display":["false"]}] '], universal_newlines=True,capture_output=True ,check=True)
    #file_path = '/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/filter_descriptions/dat.aloe2013.txt'
    #with open(file_path, 'r') as file:
     #  lines = file.readlines()    #print(jsonstring)
    shell_command = 'Rscript /Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/calculation_scripts/run_analysis.R ' + "'"+ dataset+"'" +" '"+input+"'"
    #print(shell_command)
    out = subprocess.run(shell_command ,shell=True, capture_output=True)

    #out = subprocess.run(['open','/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/calculation_/run_analysis.R'] + [str(dataset),str(input)], universal_newlines=True,capture_output=True,check=True )
    #print(ast.literal_eval(out.stdout))
    print(out.stdout)
