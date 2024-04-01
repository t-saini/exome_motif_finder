#!/usr/bin/env bash
# Goal: Identifiy which fasta files meet a given criteria based on a tabulated text file
# and then copy over this files into a new directory
# Author: Tanvir Saini

#command line argument to take in the path for the clinical data
clinical_data="$1"


#awk is used with the format set to tab, and by ignoring the first row
#we look at column 3 for the diameter constraint of 20 - 30 mm and
#in column 5 we check to see if it is sequenced
#print is followed up to in order to store our results in the array.
#without print awk will display no results, and then we would have ane empty array.
code_names=($(awk -F'\t' 'NR > 1 && $3 >= 20 && $3 <= 30 && $5=="Sequenced" {print $6}' ${clinical_data}))


#the next two echo statements are used for logging purposes
#to ensure that our array is not empty
echo "The following code names were found fitting the 20mm to 30mm and Sequenced requirement:"
echo ${code_names[@]}

#this if block is used to determine if exomes exists
#within the current directory, if it does not,
#the script will exit.
echo "Checking if exomes exists within the current directory..."
if [ -d './exomes' ]; then
    echo "Directory ./exomes exists"
else
    echo "Directory exomes does not exist!!!"
    echo "Please have ./exomes within the current directory"
    exit 1
fi

#this if block is used to determine if exomesCohort exists
#if the directory does not exist it will first
#create the directory before proceeding forward
#if it does exist it will move forward as normal.
echo "Checking if exomesCohort exists..."
if [ -d './exomesCohort' ]; then
    echo "Directory exomesCohort exists"
else
    echo "Directory exomesCohort does not exist"
    echo "Creating directory exomesCohort"
    mkdir exomesCohort
    echo "Directory exomesCohort created"
fi


#in this for loop we itterate through the
#code names found in our array
#the the respective fastas will be copied
#over to the exomesCohort directory
for code_name in "${code_names[@]}"
do
    cp ./exomes/${code_name}.fasta ./exomesCohort/
    echo "Succesfully copied ${code_name}.fasta to ./exomesCohort"
done


#this line is used for logging purposes
#in order to indicate that the exome fastas
#have been copied over.
echo "Exomes have been copied over to ./exomesCohort"