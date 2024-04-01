Exome Motif Finder
Author: Tanvir Saini

This repository contains a collection of scripts and files to perform exome analysis
for preparing potentail CRISPR sites for a given exome. The workflow involves multiple steps, 
including data preprocessing, motif analysis, CRISPR site identification, genome editing,
and report generation.

## Workflow Overview

1.Data Preprocessing: Initial clinical data (clinical_data.txt) is processed to identify exomes 
    meeting specific criteria pertaining to sequencing status and diameter. Relevant files 
    are copied to a new directory, exomesCohort.
2.Motif Analysis: Motifs are analyzed within each exome to identify the highest occurring motifs
    based exact matches via a user provided file (motif_list.txt). A file per exome is 
    created and saved to a new directory, topmotifs.
3.CRISPR Site Identification: Potential CRISPR sites are identified within exome sequences
    using regular expression pattern match to find [ACGT]GG and a leading 20 basepairs as the CRISPR site. 
    Those are saved to new files per exome within the directory precrispr.
4.Genome Editing: The CRISPR sites that were identified are modified to have a leading A at 
    the first [ACGT]GG site, and the results are saved to new FASTA files into the directory
5.Exome Report Generation: A comprehensive report is generated summarizing the findings from the analysis.

## Files Overview

1.copyExomes.sh
Description: Bash script to identify and copy relevant exome files based on clinical data criteria.

2.createCrisprReady.sh
Description: Bash script to prepare exome files for CRISPR analysis by analyzing motifs.

3.identifyCrisprSite.sh
Description: Bash script to identify potential CRISPR sites within exome sequences.

4.editGenome.sh
Description: Bash script for making genes CRISPR ready, identifying specific genetic sequences and .

5.exomeReport.py
Description: Python script to generate an exome report based on clinical data and analysis results.

6.main.py
Description: Python script to orchestrate the execution of Bash scripts and generate the final exome report.


## Requirements

Python Packages

This project requires the following Python packages:

- pandas
- logging

## How to Run

Execute the following command in the terminal when inside the week3 directory
using the provided files and the exomes of interest must be within the directory exomes:

python3 main.py "./clinical_data.txt" "./motif_list.txt"

If your clinical data text file (`clinical_data.txt`) or motif list file (`motif_list.txt`) 
are located in a different directory, provide the full path to the files when executing the command
within the week3 directory. 
For example:

python3 main.py "/path/to/your/clinical_data.txt" "/path/to/your/motif_list.txt"

If directory exomes is not within the current directory the script will exit with error code 1
The directory exomes must be within the same directory.

## Input
Clinical Data File(clinical_data.txt): must be a tab-delimited text file, the following
    column names are required:
    Discoverer, Location, Diameter (mm), Status, code_name 
    clincal_data.txt is provided

Motifs of interest(motif_list.txt):A text file containing motifs of interest, 
motif_list.txt is provided.

## Output
After running the provided scripts, users can expect the following outputs:

1. **Intermediate Files**:
    -From copyExomes.sh:
        Directory exomesCohort with copied FASTAs from directory exomes, that meet
        the Sequenced status criteria that also fall between the 20 and 30 mm Diameter

    -From createCrisprReady.sh:
        Directory topmotifs with FASTAs using *_topmotifs.fasta naming convention.
        FASTAs will have sequences with their highest ranking motifs that exactly
        match those from motif_list.txt

    -From identifyCrisprSite.sh
        Directory precrsipr with FASTAs using *_precrispr.fasta naming convention.
        FASTAs will be a subset of createCrisprReady.sh output. This subset will contain
        sequences that have at least 20 basepairs prior to the motif NGG

    -From editGenome.sh
        Directory postcrispr with FASTAs using *_postcrispr.fasta naming convention. 
        FASTA files are modified versions of the output from identifyCrisprSite.sh.
        Within these sequences A will be inserted right before the motif NGG


2. **Final Report**:
   Upon successful execution of all scripts, a final report titled `exomeReport.txt` 
   will be generated in the project directory. This report summarizes the findings using 
   the following text template:

    Organism CODENAME, discovered by DISCOVERER, has a diameter of DIAMETER, and is from the environment ENVIRONMENT.

    The list of genes can be found in: ./some_path_crispr/codename_postcrispr.fasta

    The first sequence of CODENAME is:

    >Gene0123

    ATACGTACGGATCTATTT

    Where CODENAME, DISCOVERER, DIAMETER, and ENVIRONMENT are extracted from the user
    provided tab delimited text file.

## Error Handling
Logger is used within the Python scripts to keep track
of the time and date when actions execute successfully or fail.
The scripts also check and handle file dependencies and will
exit if key directories or files are missing.

Examples:

1. Missing key directory (taken from copyExomes.sh):
    [WARNING]- YYYY-MM-DD H:M:S ::: "Checking if ./exomes exists within the current directory..."
    [WARNING]- YYYY-MM-DD H:M:S ::: "Directory ./exomes does not exist!!!"
    [WARNING]- YYYY-MM-DD H:M:S ::: "Please have ./exomes within the current directory"


Example:

1. Missing key file:
    [WARNING]- YYYY-MM-DD H:M:S ::: "<bash_file> does not exist!!!"
    [WARNING]- YYYY-MM-DD H:M:S ::: "Please ensure <bash_file> exists in the current working directory"

