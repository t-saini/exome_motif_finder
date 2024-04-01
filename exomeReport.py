import pandas as pd
import subprocess
from pathlib import Path
import sys
import logging

#Using logger to display the step by step process
#using print statements hurt my soul now.
#used logging.basicConfig to make the error 
#message aesthically pleasing.
logging.basicConfig(level=logging.INFO, 
    format='[%(levelname)s]-%(asctime)s::: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S')

#Template was set as a global variable since it will
#be called and used, and never modified.
TEMPLATE = ("Organism {}, discovered by {}, has a diameter of {}mm, "
            "and from the enviornment {} \n\nThe list of genes can be found in {} \n\n"
            "The first sequence of {} is:\n\n{}\n\n{}\n\n")

def open_clinicaldata(file_path:str)->pd.DataFrame:
    #file_path is the input, it's expected to be a string
    #and a Path object is created for better navigation and
    #manipulation of the files
    data = Path(file_path)
    #suffix is used to determine if the input file is a text file
    if data.suffix != '.txt':
        #if it is not a text file, a warning is given and
        #the system exists with error code 1
        logging.warning("Data input must be a tabulated text file!!!")
        logging.info("Exiting...Please try again.")
        sys.exit(1)
    #if the suffix of the path is a text it
    #is opened in pandas using the seperator \t
    #indicating to pandas that is tab deliminated
    logging.info(f"Opening file: {data.name}")
    clinicaldata = pd.read_csv(data, sep='\t')
    #the data type for column Diameter is enforced to be an int
    #this done because I wanted to use the .between() function later on
    clinicaldata['Diameter (mm)'] = clinicaldata['Diameter (mm)'].astype(int)
    #returns the tabulated text file as a dataframe
    return clinicaldata

def grab_postcrispr(postcrispr_dir:str)->[list, Path]:
    #this function takes in the path as a string for the 
    #post crispr directory, it is then passed as an argument
    #to Path
    path_to_postcrispr = Path(postcrispr_dir)
    #subprocess is used here to run ls in order to fetch
    #all of the files in the directory. 
    ls_postcrispr = subprocess.run(f"ls {path_to_postcrispr}", shell=True, check=True,stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    #the results from ls_postcrispr is used with split, in order
    #to generate a list with all of the file names
    files_postcrispr = ls_postcrispr.stdout.split('\n')
    #this removes any potentail empty strings in the list and 
    #reassigns the list with its updated self
    files_postcrispr = [i for i in files_postcrispr if i !='']
    #this logging line is used to ensure the right number of files are being
    #recognized by 
    logging.info(f"Found {len(files_postcrispr)} number of files in {str(path_to_postcrispr)}")
    #the list of files from with the postcrispr directory and
    #and the absolute path to the directory is returned using resolve
    #a function from the pathlib library
    return files_postcrispr, path_to_postcrispr.resolve()

def pull_fastaseqs(path_to_fasta:str) -> str:
    #function takes in a path to a given fasta
    #it is expected to be a string and will be
    #passed to Path
    file_path = Path(path_to_fasta)
    #using the with statement to manage opening and closing
    #the fasta file
    with open(file_path, 'r') as file:
        #the opened file has the method read()
        #appleid is stored in file_content
        file_content = file.read()
    #the split method is applied in order to generator a
    #list where the deliminator is at every \n that was
    #seen in the file
    content_array = file_content.split('\n')
    #only the first two entries in the list are returned 
    #this is due to the assignment constraints
    return content_array[0:2]

def write_report(report_text):
    #this function expects a string, specifically
    #using the with statement to create the file
    #exomeReport.txt, the contents of the string
    #will be written to the file.
    with open("exomeReport.txt", 'w') as file:
        file.write(report_text)


def exomereport(clinicaldata:pd.DataFrame, postcrispr_files:list,crispr_dir:Path)-> None:
    #this function expects a pandas dataframe, a list, and a path to a directory
    #that is a Path object
    #final report is an empty string at the start, but will be concatinated
    #upon at the end of the foor loop
    final_report = ""
    logging.info("Generating Report")
    #this for loop itterates through the list of file names
    #found from the function from the grab_postcrispr function
    for postcrispr_file in postcrispr_files:
        #the code name is dervied from the from the file name by 
        #splitting on the _ in the name taking the 0th element of
        #the lis
        codename = str(postcrispr_file).split("_")[0]
        #the discoverer is pulled from the dataframe based on the code name, 
        #sequencing status being sequenced, and the diaameter falls between
        #20 and 30, and is inclusive to 20 and 30
        discoverer = clinicaldata['Discoverer'][(clinicaldata['code_name']==codename)&
            (clinicaldata['Status']=='Sequenced')&
            (clinicaldata['Diameter (mm)'].between(20,30))].iloc[0]
        #the exact diameter is pulled from the dataframe using the codename
        #the sequencing status being sequenced and the discoverer name
        diameter = clinicaldata['Diameter (mm)'][(clinicaldata['code_name']==codename)&
            (clinicaldata['Status']=='Sequenced')&
            (clinicaldata['Discoverer']==discoverer)].iloc[0]
        #environment is exctracted using the codename, the sequencing status being 
        #sequenced, the diameter, and the discoverer name
        environment = clinicaldata['Environment'][(clinicaldata['code_name']==codename)&
            (clinicaldata['Status']=='Sequenced')&(clinicaldata['Diameter (mm)']==diameter)&
            (clinicaldata['Discoverer']==discoverer)].iloc[0]
        #a string of the exact path to the file is generated
        path = str(crispr_dir) + '/' + postcrispr_file
        #this is passed as an argument to pull_fastaseqs
        fasta_header, fasta_seq = pull_fastaseqs(path)
        #it is also used with all of the other variables and is passed into
        #the TEMPLATE.
        mini_report = TEMPLATE.format(codename, discoverer, diameter, environment, 
                              path, codename, fasta_header, fasta_seq)
        #the mini report is concatinated to the final_report
        final_report += mini_report
    write_report(final_report)
    #once the report is written the following if statement
    #is used to determine if the report is in the current directory.
    if Path('./exomeReport.txt').exists():
        logging.info("Successfully created exomeReport.txt in current directory")
    else:
        logging.warning("!!Failed to create exomeReport.txt in current directory!!")
