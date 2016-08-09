#DOWNLOAD DATASET if not present
zipfilename <- "Dataset.zip"
if (!file.exists(zipfilename)){
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                zipfilename, method = "curl")
}

#UNZIP dataset if needed
datadir <- "UCI HAR Dataset"
if (!dir.exists(datadir)) {
  unzip("Dataset.zip")
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
required_features <- feature_labels_tab[grepl("std\\(\\)|mean\\(\\)",feature_labels_tab$label),]
merged_x_shrinked <- merged_x[,required_features$id]

#ADD FEATURE NAMES (with a little cleanup)
colnames(merged_x_shrinked) <- required_features$label

#ADD LABEL NAMES TO merged_y
merged_y <- merge(activity_labels_tab, merged_y, by.x = "id", by.y = "V1")

#create complete dataframe with subjects and activities
fulldataset <- cbind(merged_x_shrinked, factor(merged_subject$V1), merged_y$label)
colnames(fulldataset) <- c(names(merged_x_shrinked),"subject","activity")


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
