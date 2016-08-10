#############################################################################
#
# run_analysis.R - Obtain, read and clean data from UCI HAR dataset
#
# Project for John Hopkins University - Getting and Cleaning Data on Coursera
#
# Author: Gianluca Ferri - glferri@gmail.com
#
#############################################################################

#DOWNLOAD DATASET if not present
zipfilename <- "UCI HAR Dataset.zip"
datadir <- "UCI HAR Dataset"
if (!file.exists(zipfilename) && !dir.exists(datadir)){
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                zipfilename, method = "curl")
}

#UNZIP dataset if needed
if (!dir.exists(datadir)) {
  unzip(zipfilename)
}

#READ DATASET
activity_labels_tab <- read.table(file.path(datadir,"/activity_labels.txt"), col.names = c("id","label"))
feature_labels_tab <- read.table(file.path(datadir,"/features.txt"), col.names = c("id","label"))

train_data_x <- read.table(file.path(datadir,"/train/X_train.txt"))
train_data_y <- read.table(file.path(datadir,"/train/y_train.txt"))
train_data_subject <- read.table(file.path(datadir,"/train/subject_train.txt"))

test_data_x <- read.table(file.path(datadir,"/test/X_test.txt"))
test_data_y <- read.table(file.path(datadir,"/test/y_test.txt"))
test_data_subject <- read.table(file.path(datadir,"/test/subject_test.txt"))


#MERGE MEASUREMENTS
merged_x <- rbind(train_data_x, test_data_x)
merged_y <- rbind(train_data_y, test_data_y)
merged_subject <- rbind(train_data_subject, test_data_subject)


#SELECT REQUIRED FEATURES
#accept meanFreq values also (if not, regexp should be: "std\\(\\)|mean\\(\\)" )
required_features <- feature_labels_tab[grepl("std|mean",feature_labels_tab$label),]
merged_x_shrinked <- merged_x[,required_features$id]

#cleanup unneeded data
rm(train_data_x, train_data_y, train_data_subject,test_data_x,test_data_y,test_data_subject)
rm(feature_labels_tab)

#CLEANUP FEATURE NAMES
templabs <- required_features$label
templabs <- sub("^t","timeDomain", templabs)
templabs <- sub("^f","freqDomain", templabs)
templabs <- sub("Acc", "Accelerometer", templabs)
templabs <- sub("Gyro", "Gyroscope", templabs)
templabs <- sub("Mag", "Magnitude", templabs)
templabs <- sub("mean", "Mean", templabs)
templabs <- sub("std", "Std", templabs)
templabs <- gsub("-", "", templabs)
templabs <- sub("\\(\\)","", templabs)
required_features$cleanlabel <- templabs
rm(templabs)

#ADD FEATURE NAMES and write the feature label dataset for reference
colnames(merged_x_shrinked) <- required_features$cleanlabel
write.table(required_features, "feature_list.txt", row.names = FALSE)

#ADD ACTIVITY NAMES TO merged_y
merged_y$label <- activity_labels_tab$label[merged_y$V1]

#create complete dataframe with subjects and activities
fulldataset <- cbind(merged_x_shrinked, factor(merged_subject$V1), merged_y$label)
colnames(fulldataset) <- c(names(merged_x_shrinked),"subject","activity")

#remove unneded variables
rm(merged_x,merged_y,merged_subject, required_features)

#NEW DATASET
library(dplyr)
#group_by subject and activity
tidydataset <- fulldataset %>% group_by(subject, activity) %>% 
  #summarize applying mean to each other variable
  summarize_each(funs(mean)) %>%
  #order by subject and activity
  arrange(subject,activity)

#save table to disk
write.table(tidydataset, "tidy.txt", row.names = FALSE)
