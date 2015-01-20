# 
# Coursera "Getting and Cleaning Data" (getdata-010) final project
# https://class.coursera.org/getdata-010/human_grading/view/courses/973497/assessments/3/submissions
#
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
# Here are the data for the project:  
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Apropriately labels the data set with descriptive variable names. 
# 5. from the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr)

# Read the raw data in
train_X <- read.table("UCI HAR Dataset\\train\\X_train.txt")
train_Y <- read.table("UCI HAR Dataset\\train\\y_train.txt")
train_S <- read.table("UCI HAR Dataset\\train\\subject_train.txt")
test_X <- read.table("UCI HAR Dataset\\test\\X_test.txt")
test_Y <- read.table("UCI HAR Dataset\\test\\y_test.txt")
test_S <- read.table("UCI HAR Dataset\\test\\subject_test.txt")

# 1 - Merges the training and the test sets to create one data set.
train_X$y <- train_Y$V1
train_X$s <- train_S$V1
test_X$y <- test_Y$V1
test_X$s <- test_S$V1
data = rbind(train_X, test_X)

# 2 - Extracts only the measurements on the mean and standard deviation for each measurement.
features <- read.table("UCI HAR Dataset\\features.txt")
colnames(features) <- c("Col_Idx", "Name")
features$Name = as.character(features$Name)
# find variables that only have -mean()- or -std()- in their names
features_wanted <- features[grep("-mean[(][)]-|-std[(][)]-", features$Name), ]
cols = ncol(data)
data_wanted <- data[, c(features_wanted$Col_Idx, cols-1, cols)]

# 3 - Uses descriptive activity names to name the activities in the data set
activity_labels <- read.table("UCI HAR Dataset\\activity_labels.txt")
colnames(activity_labels) <- c("Id", "Label")

cols = ncol(data_wanted)
activities <- data.frame(Id=data_wanted[, cols-1])
x=merge(activities, activity_labels, sort=FALSE)
data_wanted[, cols-1] = x$Label

# 4 - Appropriately labels the data set with descriptive variable names
colnames(data_wanted) <- c(features_wanted$Name, "Activity", "Subject")

# 5 - From the data set in step 4, creates a second, independent tidy data 
# set with the average of each variable for each activity and each subject.

avg_all = ddply(data_wanted, .(Subject, Activity), numcolwise(mean, rm.na=TRUE))

write.table(avg_all, "run_analysis_output.txt", row.name=FALSE)
