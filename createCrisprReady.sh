#!/usr/bin/env bash
# Goal: Analyze a list of motifs and output the three highest occuring motifs in each 
# gene for a given exome into another FASTA
# Author: Tanvir Saini

#command line argument for the path
#to the lists of interesting motifs
motifs="$1"

#using mapfile to have the text file
#be easily stored into the array
mapfile -t motif_array < "${motifs}"

#check to see if exomesCohort exists
#in the current directory, if it does
#move forward, if it does not
#notify that the user should have ran
#copyExomes.sh first and exit
if [ -d './exomesCohort' ]; then
    echo "Found directory exomesCohort"
else
    echo "Did not find exomesCohort!!!"
    echo "Did you run copyExomes.sh first?"
    exit 1
fi


#check to see if topmotifs exists
#in the current directory, if it does
#move forward, if it does not
#notify that the user and create
#the directory topmotifs
if [ -d './topmotifs' ]; then
    echo "Found directory ./topmotifs"
else
    echo "Did not find ./topmotifs"
    mkdir topmotifs
    echo "Successfully created ./topmotifs"
fi

#store the results of ls for exomesCohort
#into an array which will be used later
exomes=($(ls "./exomesCohort"))

#declare the array motif_counts
#this will be used later to take count
#of the motifs in a given exome
declare -a motif_counts=()

#the empty string found_genes
#will be a rolling concatination
#for grep results, and will then
#be used for the final file output
declare -a found_genes=()

#begin first for loop and notify
#the user of what exome is being looked at
for exome in ${exomes[@]}
do
    echo "Checking ${exome}"
    #the second for loop starts, each
    #motif in the motif_array will be
    #analyzed using grep
    for motif in ${motif_array[@]}
    do
        #each grep result will observed using -o
        #to only display the result if it matches the motif
        #using the command wc -l also tells us the number of lines
        #that are generated from the grep search
        #with the numeric result first and then motif itself
        #this format is for sorting later on.
        motif_count=$(grep "${motif}" -o "./exomesCohort/${exome}" | wc -l)
        motif_counts+=("${motif_count}_${motif}")
    done

    #exomename is going to be used
    #for the final file output
    #the '%' is used to remove
    #the fasta file extension from
    #the variable fasta
    exomename="${exome%.fasta}"
    echo "Extracting top 3 motifs for ${exomename}"
    #the entries in motif_counts will be sorted using
    #k1,1 which will look at the numeric value only when sorting
    #the n is used to specify that number in the string should be treated
    #as a number and last the r will have order from larges to smallest
    sorted_array=($(printf "%s\n" "${motif_counts[@]}" | sort -k1,1nr))
    #the 0th index to the 3rd index is looked at
    #since r was used as an argument with sort, the 0:3 should
    #yield the highest motifs found in that exome
    top_motifs=("${sorted_array[@]:0:3}")
    #the final for loop itterates through
    #the array top_motifs
    echo "Top 3 motifs found for ${exomename}:: ${top_motifs[@]}"
    for top_motif in ${top_motifs[@]}
    do 
        #top_motifs is passed into grep after removing the numeric prefix
        #the genes with the motif and the header prior will be selected
        #and outputted to /exomesCohort
        found_genes+=$(grep -B1 "${top_motif#*_}" "./exomesCohort/${exome}")

    done

    echo "Creating topmotifs.fasta for ${exomename}"
    #the large found_genes string will be written to the top_motifs
    #file with the exome name, and each entry in found genese will be
    #printed followed by a new line.
    #awk is used to remove any genes that may be found more than once.
    #sed is used to ensure that every fasta header is on a new line
    #tr removes \n-- which is generated by grep search
    #lastly grep -v is used to remove any extra empty lines.
    printf "%s\n" "${found_genes}" | awk '!seen[$0]++ {if (NR > 1) print ""; print $0}' | sed 's/>\([^[:space:]]\)/\n>\1/g' | tr -s '\n--' '\n' | grep -v '^$' > "./topmotifs/${exomename}_topmotifs.fasta"
    echo "${exomename}_topmotifs.fasta created inside ./topmotifs !!!"
    #we empty the array motif_counts and found_genes
    #this is done ot ensure we do not carry over genes
    #from one exome to another
    motif_counts=()
    found_genes=()
done