# README

This is the final project for the "GETTING AND CLEANING DATA" course.

This repo has four files:
- README.MD: This file
- run_analysis.R: A script that downloads a file, runs some operations and saves a tidy data set called result.txt
- result.txt: The processed and tidy data set
- codebook.MD: The description of the variables of result.txt

In this project we are supossed to download a train and test data set and:
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Item 1. Merges the training and the test sets to create one data set.

First we download the data, save it as data.zip and extract it:

~~~
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(fileUrl, destfile = "./data.zip", method="curl")
unzip(zipfile = "./data.zip", exdir = ".")
~~~

When data.zip is "unziped", a "UCI HAR Dataset" folder is created. There are two folders in this folter: test and train. Read the x, y and subject data

~~~
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
~~~

Merge the x, y, and subject data using the rbind command. The result will be stored in ___merged variables:

~~~
x_merged <- rbind(x_train, x_test)
y_merged <- rbind(y_train, y_test)
subject_merged <- rbind(subject_train, subject_test)
~~~

At this point, there are three new variables:
- x_merged: represents 561 measurements
- y_merged: represents the activity labels
- subject_merged: represents the id of the subject (person)

To give descriptive names for the columns, we can read its description in the "features.txt" file:

~~~
col_name_x <- read.table("UCI HAR Dataset/features.txt")
names(x_merged) <- col_name_x[,2]
names(y_merged) <- "activity"
names(subject_merged) <- "subject"
~~~

To complete this solution, we should merge the x, y and subject data. We can achieve this goal using the cbind column and putting the result in the data variable. Data will have the columns: [subject, activity, ... all 562 variables ...]

~~~
data <- cbind(subject_merged, y_merged, x_merged)
~~~

## Item 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

According to the features_info.txt file, the set of variables that deals with mean and standard deviation has mean() and std() in its name.
Note that the parenthesis is necessary because there are some variables with ___mean___ that is not about mean value (e.g. meanFreq()). Besides, there are variables that ends with mean (e.g. gravityMean) that DO NOT represent the mean value of the variable (actually, it is a mean value in a signal window sample).

The regular expression to represent the function "mean() or std()" is "mean\\(\\)|std\\(\\)". Note that it is necessary to escape the parenthesis with \\ It is important to keep the information about the subject and activity, because the item 5 of this exercise requires it

First, we can find the columns index with subject, activity, mean() or std():

~~~
idx_mean_or_std <- grep(pattern = "subject|activity|mean\\(\\)|std\\(\\)", 
                        names(data))
~~~

With the indexes, it is easy to extract only this columns:

~~~
mean_std_dataset <- data[,idx_mean_or_std]
~~~

## Item 3. Uses descriptive activity names to name the activities in the data set

The activity labels are stored in the activity_labels.txt file. Let's read that file:

~~~
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
~~~

The activity_labels is stored in a way such as the line 1 is the activity 1 and so on. So, if data$activity stores the value i, than all we need to do is find the ith line of activity_labels to get a descriptive name for the activity. Than, we just change the integer value for factor values:

~~~
mean_std_dataset[,"activity"] <- activity_labels[mean_std_dataset$activity,2]
~~~

## Item 4. Appropriately labels the data set with descriptive variable names.

We have already done this in Item 1. We can just see the variables names:

~~~
print(names(mean_std_dataset))
~~~

## Item 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

We can use ddply library to apply the mean function at each column and organize by subject and activity: 

~~~
library(plyr)
avg_per_sub_and_act <- ddply(mean_std_dataset, c("subject","activity"), numcolwise(mean))
~~~

Write the final data set to result.txt to submit it to peer review:

~~~
write.table(x = avg_per_sub_and_act, file = "result.txt", row.name=FALSE)
~~~