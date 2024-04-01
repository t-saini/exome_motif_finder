#!/usr/bin/env bash
# Goal: Search for a regex match of [A-Z]GG and return A[A-Z]GG along with 
# any characters upstream or downstream of the regex match
# Author: Tanvir Saini

#checks to see if ./topmotifs is present in the current directory
#if it is, we proceed forward, however if it does not the script exits
#the script exists here because topmotifs is supposed to have the inputs
if [ -d './precrispr' ]; then
    echo "Directory ./precrispr exists"
else
    echo "Directory ./precrispr does not exist"
    echo "Please run identifyCrisprSite.sh before running this script"
    exit 1
fi

#checks to see if ./precrispr directory exists in the current directory
#if it does, the script proceeds. if the directory does not exist
#the directory will be created
#the script does not exit because this will contain our outputs
if [ -d './postcrispr' ]; then
    echo "Directory ./postcrispr exists"
else
    echo "Directory ./postcrispr does not exist"
    mkdir ./postcrispr
    echo "Directory ./postcrispr created successfully"
fi

#the following array stores all of the files
#within the directory ./precrispr
exomes_precrispr=($(ls ./precrispr))


#itterate through each file name found in exomes_precrispr
for exome in ${exomes_precrispr[@]}
do
    echo "Preparing file ${exome}"
    #sed will ignore the every line with > in the file and will
    #proceed to process the next line. If the line in ./precrispr/exome
    #find a regex match to [A-Z]GG and do a substitution to A[A-Z]GG
    #as indicated by s/ and output the results along with upstream and downstream characters
    #to directory ./postcrispr
    crispr_ready=($(sed '/^>/n; s/\([A-Z]GG\)/\A&/' "./precrispr/${exome}"))
    #from the file name stored in ${exome} the strings prior to the _ will be
    #saved to the variable exomename
    exomename=${exome%%_*}
    #exomename is used for the _postcrispr naming convention.
    echo "Creating ${exomename}_postcrispr.fasta and outputing to ./postcrispr"
    printf "%s\n" "${crispr_ready[@]}" > ./postcrispr/${exomename}_postcrispr.fasta
done