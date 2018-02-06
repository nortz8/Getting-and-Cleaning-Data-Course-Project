## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Part 0: Extracting the raw data into variables, Install / Load Packages

# install (if not yet installed) and load packages
if(!require(janitor)){
  install.packages("janitor")
  library(janitor)
  }
if(!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
  }
if(!require(tidyr)){
  install.packages("tidyr")
  library(tidyr)
}


library(dplyr)
library(tidyr)
library(janitor)

# extract data
features <- tbl_df(read.table("~/UCI HAR Dataset/features.txt", quote="\"", comment.char=""))
activityLabels <- tbl_df(read.table("~/UCI HAR Dataset/activity_labels.txt", quote="\"", comment.char=""))

yTest <- tbl_df(read.table("~/UCI HAR Dataset/test/y_test.txt", quote="\"", comment.char=""))
XTest <- tbl_df(read.table("~/UCI HAR Dataset/test/X_test.txt", quote="\"", comment.char=""))

yTrain <- tbl_df(read.table("~/UCI HAR Dataset/train/y_train.txt", quote="\"", comment.char=""))
XTrain <- tbl_df(read.table("~/UCI HAR Dataset/train/X_train.txt", quote="\"", comment.char=""))

subjectTrain <- tbl_df(read.table("~/UCI HAR Dataset/train/subject_train.txt", quote="\"", comment.char=""))
subjectTest <- tbl_df(read.table("~/UCI HAR Dataset/test/subject_test.txt", quote="\"", comment.char=""))

# Part 1: Merging the training and test sets

# merge data
mergedTest <- cbind(subjectTest, yTest, XTest)
mergedTrain <- cbind(subjectTrain, yTrain, XTrain)
mergedData <- rbind(mergedTest, mergedTrain)

# rename column labels and clean column names
featurenames <- features[,2]
columnLabels = c("subject", "activity", t(featurenames))
colnames(mergedData) = columnLabels
mergedData2 <- clean_names(mergedData)

# Part 2: Extracts only the mean and SD for each measurement

dfmean <- select(mergedData2, contains("mean"))
dfstd <- select(mergedData2, contains("std"))
subject <- mergedData2[,1]
activity <- mergedData2[,2]
dfmeanstd <- cbind(subject, activity, dfmean, dfstd)


# Part 3: Uses descriptive activity names to name the activities in the data set
dfmeanstd$activity <- as.character(dfmeanstd$activity)
dfmeanstd$activity <- gsub('1','WALKING', dfmeanstd$activity)
dfmeanstd$activity <- gsub('2','WALKING_UPSTAIRS', dfmeanstd$activity)
dfmeanstd$activity <- gsub('3','WALKING_DOWNSTAIRS', dfmeanstd$activity)
dfmeanstd$activity <- gsub('4','SITTING', dfmeanstd$activity)
dfmeanstd$activity <- gsub('5','STANDING', dfmeanstd$activity)
dfmeanstd$activity <- gsub('6','LAYING', dfmeanstd$activity)

# Part 4: Appropriately labels the data set with descriptive activity names.
names(dfmeanstd)<-gsub("subject", "Subject", names(dfmeanstd))
names(dfmeanstd)<-gsub("activity", "Activity", names(dfmeanstd))
names(dfmeanstd)<-gsub("^t", "Time", names(dfmeanstd))
names(dfmeanstd)<-gsub("^f", "Frequency", names(dfmeanstd))
names(dfmeanstd)<-gsub("jerk", "Jerk", names(dfmeanstd))
names(dfmeanstd)<-gsub("body", "Body", names(dfmeanstd))
names(dfmeanstd)<-gsub("acc", "Accelerometer", names(dfmeanstd))
names(dfmeanstd)<-gsub("gyro", "Gyroscope", names(dfmeanstd))
names(dfmeanstd)<-gsub("mag", "Magnitude", names(dfmeanstd))
names(dfmeanstd)<-gsub("BodyBody", "Body", names(dfmeanstd))
names(dfmeanstd)<-gsub("std", "SD", names(dfmeanstd))
names(dfmeanstd)<-gsub("mean", "Mean", names(dfmeanstd))
names(dfmeanstd)<-gsub("angle", "Angle", names(dfmeanstd))
names(dfmeanstd)<-gsub("gravity", "Gravity", names(dfmeanstd))
names(dfmeanstd)<-gsub("tBody", "TimeBody", names(dfmeanstd))

# Part 5: Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy1 <-group_by(dfmeanstd, Subject, Activity)
tidyData <- summarize_all(tidy1, funs(mean))
write.table(tidyData, file = "TidyData.txt")
