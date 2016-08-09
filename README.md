# datascience_getclean_ucihar
Getting and Cleaning Data Course Project -  Get, clean, and tidy UCI HAR dataset

## Description
The R script run_analysis.R loads data from UCI HAR dataset for Human wearable devices.
The script produces the file tidy.txt, containing the mean for the mean and standard deviation values of each feature, for each pair of subject and activity, ordered by the to variables, respectively.

Refer to [CodeBook.md] for information on the variable of the intermediate and tidy dataset.

## Running
The script can be run on a clean directory: it downloads the dataset in its working directory on a file called Dataset.zip, then unzip it into the zip default directory "UCI HAR Dataset".

If either Dataset.zip or UCI HAR Dataset are present, the first steps are skipped.
The output data set is tidy.txt in the working directory.
