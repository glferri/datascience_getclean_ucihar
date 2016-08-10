# Code Book for tidy.txt dataset
## Description

### Structure
The dataset first 2 columns represent the subject and activity couples for which the mean value of each selected feature is shown in the following coluns. 
### Variables
**cathegorical**
subject: the subject performing the experiment
activity: the type of activity that was accomplished during measurement

**numerical**
All variables are constructed from normalized data, bound to [-1,1]. Data have thus no units.

Variable names are constructed using the following conventions:
*domain*
timeDomain indicates that the measurement is obtained from time domain data
freqDomain indicates that the measurement is obtained from frequency domain data (after appling FFT to time domain data)
**acceleration type**
Body indicates body acceleration
Gravity indicates gravity acceleration (for accelerometer data)
**source**
Accelerometer indicates data obtained from accelerometer data
Gyroscope indicates data obtained from Gyroscope data
**data extracted**
Mean: mean of data
Std: standard deviation of data
meanFreq: mean frequency, for frequency domain data
**Jerk**
Jerk indicates the Jerk feature is extracted
**axis, or magnitude**
X,Y,Z: axis for data in vector form
Magnitude: indicates the euclidean magnitude is computed for vector data before appling mean or std

**note**: it is unclear what BodyBody variables represent.

See the generated [feature_list.txt](feature_list.txt) for the list of original feature names along the new names. The dataset is updated each time the script runs, so changes in naming policy or feature selection affect its content.

## Construction
tidy.txt is obtained running the accompaining script [run_analysis.R](run_analysis.R).
See [README.md](README.md) for notes on running it.

In order to obtain tidy.txt the following steps are accomplished:
1. load features, activity, subjects and label data into dataframes
2. combine train and test data (feature, activity and subjects are maintained separate at this step)
3. select the required features:
	we decided to keep meanFreq, being itself a mean of a feature. 
In this case we used the following regex: `"std|mean"`.
In order to keep only std() and mean() variables, the following regexp can be used: `"std\\(\\)|mean\\(\\)"`.
4. add a column to feature label data frame with cleaned up labels:
```
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
```
5. change feature dataset labels using the cleaned up ones (since they are in order by construction, no matching by id is needed)
6. add a column to activity dataframe with the matched label from its label dataframe
7. combine the feature, subject and activity column into the full dataset
8. generate the tidy dataset (dplyr verbs used):
    1. `group_by` the full data set by subject and activity
    2. `summarize_each` column by applying mean to each subject-activity couple
    3. `arrange` ordering by subject and then for activity
9. save the generated dataset into tidy.txt
 
