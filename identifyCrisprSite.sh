#!/usr/bin/env bash
# Goal: Identifiy which sequences within a FASTA has
# the desired motif and outputs those sequences into 
# a new file under the directory precrispr
# Author: Tanvir Saini

#checks to see if ./topmotifs is present in the current directory
#if it is, we proceed forward, however if it does not the script exits
#the script exists here because topmotifs is supposed to have the inputs
if [ -d './topmotifs' ]; then
    echo "Directory ./topmotifs exists"
else
    echo "Directory ./topmotifs does not exist"
    echo "Please run createCrisprReady.sh before running this script"
    exit 1
fi

#checks to see if ./precrispr directory exists in the current directory
#if it does, the script proceeds. if the directory does not exist
#the directory will be created
#the script does not exit because this will contain our outputs
if [ -d './precrispr' ]; then
    echo "Directory ./precrispr exists"
else
    echo "Directory ./precrispr does not exist"
    mkdir ./precrispr
    echo "Directory ./precrispr created successfully"
fi

#ls is used to quickly obtain all of the file names within
#the directory topmotifs
exomes=($(ls "./topmotifs"))
#an empty array crispr_ready is declared for use
#this array will contain all sequences that 
#are returned by sed
declare -a crispr_ready=()

#we itterate through each file found and stored
#within the exomes array from earlier when ls was used
for exome in "${exomes[@]}"
do
    #inform the user which exome is about to be analyzed with sed
    echo "Finding suitable candidates for crispr within ${exome}"
    #sed will do the following if the line starts with >, it is not omitted but stored in a 
    #hold space. If the line does not start with > it will return 3-mer match 
    #where the first letter can be A,C,T, or G
    #the next two letters must be GG and at least 20 characters must preceed
    #the 3-mer.
    #H, x, and p within the curly braces allows sed to collect and print 
    #the entire sequence (including the header) that matches the specified pattern, 
    #rather than just the matching lines.
    crispr_ready+=($(sed -n '/^>/ h ;/^[^>].\{20,\}[ACTG]GG/ {H; x;p}' ./topmotifs/${exome}))
    #the file name stored in exome is cleaned up to remove  _topmotif.fasta
    #the renaming exome name will be used in the final file creation
    exomename=${exome%%_*}
    #Inform the user that the results are being outputted to ./precrispr
    echo "Out putting results to ./precrispr/${exomename}_precrispr.fasta"
    printf "%s\n" "${crispr_ready[@]}" > "./precrispr/${exomename}_precrispr.fasta"
    #crispr_ready is emptied, if this step is not done, results from previous
    #exomes would roll over into the next precrisper output
    crispr_ready=()
done