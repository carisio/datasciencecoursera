###############################################################################
# GETTING AND CLEANING DATA - COURSE PROJECT - SCRIPT: RUN_ANALYSIS.R
###############################################################################
#
# Item 1. Merges the training and the test sets to create one data set.
# 
# Dowload the zip file and unzip it. This step could take a while 
# because the file size is more than 60 MBytes. This script saves
# the zip file as data.zip
#
# NOTE: If you already have the zip file, comment the lines 12 and 13, rename
#       it to data.zip, set the workspace to its location and run the next 
#       commands
#
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(fileUrl, destfile = "./data.zip", method="curl")
unzip(zipfile = "./data.zip", exdir = ".")

# Read the train and test data
# When data.zip is "unziped", a "UCI HAR Dataset" is created.
# There are two folders in this folter: test and train.
# Read the x, y and subject data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

# Merge the data x, y and subject data:
#       - rbind (row bind) will be responsible to merge both datasets.
# The result is stored in the "XXXXX_merged" variables
x_merged <- rbind(x_train, x_test)
y_merged <- rbind(y_train, y_test)
subject_merged <- rbind(subject_train, subject_test)

# At this point, there are three new variables:
# x_merged: represents 561 measurements
# y_merged: represents the activity labels
# subject_merged: represents the id of the subject (person)
#
# Let's give descriptive names for the columns of these three datasets
col_name_x <- read.table("UCI HAR Dataset/features.txt")
names(x_merged) <- col_name_x[,2]
names(y_merged) <- "activity"
names(subject_merged) <- "subject"

# To complete the exercise, it is necessary to cbind all this tables
# At this point, data is a unique dataset with all information:
# subject, activity and measurements. Note: The column in this data set
# has descriptive names
data <- cbind(subject_merged, y_merged, x_merged)

# Item 2. Extracts only the measurements on the mean and standard deviation for
#          each measurement. 
#
# According to the features_info.txt file, the set of variables that deals with
# mean and standard deviation has mean() and std() in its name.
# Note that the parenthesis is necessary because there are some variables with
# ___mean___ that is not about mean value (e.g. meanFreq()). Besides,
# there are variables that ends with mean (e.g. gravityMean) that DO NOT
# represent the mean value of the variable (actually, it is a mean value in
# a signal window sample).
# The regular expression to represent the function "mean() or std()" is
# "mean\\(\\)|std\\(\\)". Note that it is necessary to escape the parenthesis
# with \\
# It is important to keep the information about the subject and activity,
# because the item 5 of this exercise requires it
#
# Find the columns index with subject, activity, mean() or std()
idx_mean_or_std <- grep(pattern = "subject|activity|mean\\(\\)|std\\(\\)", 
                        names(data))

# With the indexes, it is easy to extract only this columns:
mean_std_dataset <- data[,idx_mean_or_std]


# Item 3. Uses descriptive activity names to name the activities in the 
#         data set
#
# The activity labels are stored in the activity_labels.txt file.
# First let's read that file:
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
# The activity_labels is stored in a way such as the line 1 is the
# activity 1 and so on. So, if data$activity stores the value i,
# than all we need to do is find the ith line of activity_labels
# to get a descriptive name for the activity. Than, we just change
# the integer value for factor values:
mean_std_dataset[,"activity"] <- activity_labels[mean_std_dataset$activity,2]

# Item 4. Appropriately labels the data set with descriptive variable names.
#
# This was already been done in Item 1 when we changed the variable names
# using the features.txt. See lines 44, 45, 46 and 47. To check this, let's
# see the variables names:
print(names(mean_std_dataset))

# Item 5. From the data set in step 4, creates a second, independent tidy 
#         data set with the average of each variable for each activity and
#         each subject.
#
# Use ddply to apply the mean function at each column and organize by 
# subject and activity
library(plyr)
avg_per_sub_and_act <- ddply(mean_std_dataset, c("subject","activity"), numcolwise(mean))

write.table(x = avg_per_sub_and_act, file = "result.txt", row.name=FALSE)