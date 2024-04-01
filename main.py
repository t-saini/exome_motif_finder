from pathlib import Path
import sys
import subprocess
import logging
import exomeReport

#Using logger to display the step by step process
#these messages are also accompanied with the time
#and date of when the message was produced
logging.basicConfig(level=logging.INFO, 
    format='[%(levelname)s]-%(asctime)s:::%(message)s',
    datefmt='%Y-%m-%d %H:%M:%S')

#this list has the name of all of the expected
#bash files that should exist within the current
#directory.
BASH_FILES = ['copyExomes.sh','createCrisprReady.sh',
                'identifyCrisprSite.sh','editGenome.sh']

def _pre_reqs()->bool:
    #this helper function ensure that the
    #required files are in the same directory
    for bash_prereq in BASH_FILES:
        #the file is passed to Path so that
        #the exist() method can be used to 
        #determine if the file is present in 
        #the direcotry
        bash_path = Path(bash_prereq)
        if bash_path.exists() is False:
            #if a given file returns False
            #the user is warned and the and
            #the python script exists with 
            #error code 1
            logging.warning(f"{bash_path} does not exist!!!")
            logging.warning(f"Please ensure {bash_path} exists in the current working directory")
            sys.exit(1)

def main():
    #arguments put into the terminal past the 0th entry
    #is stored as a list which will be referedd to as 
    #arguments
    arguments = sys.argv[1:]
    logging.info("Running Bash Pre-requisite check...")
    #kick starts the pre req check, if this fails
    #main.py will exit with sys code 1
    _pre_reqs()
    logging.info("Bash Pre-requisite check successful")
    #this for loop will itterate through the list BASH_FILES
    #enumerate is used to to pull the index and the file
    #enumerate is also used over range(len())
    for index, bash_file in enumerate(BASH_FILES):
        #logging will display which file is being ran
        logging.info(f"Running {bash_file}")
        #the bash prompt will be filled dynamically
        bash_prompt = ['bash',f'{bash_file}']
        #only the first two bash scripts require a file path
        if index < 2:
            #while the index is is less than it will be calling the first
            #two bash scripts that require an input that will be sitting in arguments.
            bash_prompt = ['bash',f'{bash_file}', f'{arguments[index]}']
        #subprocess.Popen is used to run execute the bash scripts
        bash_process = subprocess.Popen(bash_prompt, 
                            stdout=subprocess.PIPE, stderr = subprocess.PIPE,
                            text=True)
        #the standard out and standard error are extracted thanks to
        #the method .communciate()
        stdout, stderr = bash_process.communicate()
        #the method split is used to turn stdout into array
        #this is done to remove any empty entries
        stdout_array = stdout.split('\n')
        stdout_array = [i for i in stdout_array if i != '']
        for stdout_message in stdout_array:
            #for every stdout_message in the array
            #print the message
            logging.info(stdout_message)
        #if stderr is ever executed
        #print the error and exit the script
        if stderr != '':
            logging.warning(stderr)
            sys.exit(1)
    logging.info("Creating final report titled - exomeReport.txt")
    #functions from exomeReport are imported and executed here
    clinical_df = exomeReport.open_clinicaldata(arguments[0])
    files_postcrispr, path_to_postcrispr = exomeReport.grab_postcrispr("./postcrispr")
    #since the output of exomeReport.exomereport is a file a variable is not needed
    exomeReport.exomereport(clinical_df, files_postcrispr, path_to_postcrispr)

#checks whether the script is being run directly by the Python interpreter. 
#If it is, the code block underneath will be executed.
if __name__ == "__main__":
    main()