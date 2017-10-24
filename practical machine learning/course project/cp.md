
# Course project - Practical Machine Learning
Leandro Carisio Fernandes

## Summary

In this course project, we should deal with the Weight Lifting Exercise Dataset [1]. Our goal is to use data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants, who were asked to perform barbell lifts correctly and incorrectly in 5 different ways. The database consists of a training set and a testing set. After using the training set, we should predict the classes of 20 observations of the testing dataset.

My approach to solve this problem was to split the training dataset into two datasets: one where the training is applyed (70% of the dataset), and another for validation (and to extract the expected out-of-sample error). Then, I cleaned the data (removing NAs and variables with high correlation). Finally, I used the randomForest algorithm to build the model. Since the final accuracy was greater than 99% (expected out-of-sample error of ~1%), I considered that the random forest solve the problem.

## Pre-processing

### Getting and cleaning Data

There are two files available: 'pml-training.csv' and 'pml-testing.csv', which were loaded into the variables training and testing:


```r
training <- read.csv('pml-training.csv')
testing <- read.csv('pml-testing.csv')
```

The first seven columns of these database refers to some identification of the subject/measure (columns names: x, user_name, raw_timestamp_part_1, raw_timestamp_part_2, cvtd_timestamp, new_window, num_window). Since this is not relevant for the purpose of these project, we will remove these columns of the variables:


```r
training <- training[, -c(1:7)]
testing <- testing[, -c(1:7)]
```

A little exploratory analysis show that our training database has 160 columns (variables) and 67 columns has NA:


```r
number_of_columns <- length(colnames(training))
number_of_NA_columns <- sum(colSums(is.na(training)) > 0)
print(paste('Number of columns:', number_of_columns, '. Number of columns with NA:', number_of_NA_columns))
```

```
## [1] "Number of columns: 153 . Number of columns with NA: 67"
```

I will consider only the columns that does not have any NA. This can be revisited if the training result was not satisfactory.


```r
training <- training[ , colSums(is.na(training)) == 0]
```

The kurtosis and swewness of the data are statistical of the data. So, this kind of information is already considered in the data. So, this variables can also be removed. The variables that ends with _yaw_belt, _yaw_dubbell and _yaw_forearm are factor variables with strange values (there are some #DIV/0 in its contents). Therefore, they can also be removed.


```r
training <- training[, !grepl('kurtosis', names(training))]
training <- training[, !grepl('skewness', names(training))]
training <- training[, !grepl('_yaw_belt', names(training))]
training <- training[, !grepl('_yaw_dumbbell', names(training))]
training <- training[, !grepl('_yaw_forearm', names(training))]
```

At this point, our data our training set was reduced to:


```r
dim(training)
```

```
## [1] 19622    53
```

### Preparing Data to Build the Model

We can only work with the training dataset. So, I will split it in two dataset: tr, used to train, and validation, for validation purpose. The validation dataset will be used to find the expected out-of-sample error when applying the model in the testing dataset.


```r
set.seed(12345)
inTrain <- createDataPartition(y=training$classe, p=0.7, list=F)
tr <- training[inTrain, ]
validation <- training[-inTrain, ]
```

Now, let's check if it is possible to reduce the tr dimensions (this is necessary to reduce the possibility of overfitting the data). The obvious solution is to remove variables that have a high correlation with other variable. There is not a rule of thumb of what is a high correlation. In this project, I will consider that two variables are high correlated with each other if the absolute value of the correlation is greater than 80%. The code below remove these variables of the training set (part of the code was based on [2]):


```r
nPreditors <- dim(tr)[2] - 1

correlationMatrix <- cor(tr[,1:nPreditors])
correlationMatrix[lower.tri(correlationMatrix, diag=TRUE)] <- NA

# corGT80percent hold the correlation data greater than 80% or less than -80%
corGT80percent <- subset(melt(correlationMatrix, na.rm = TRUE), value > 0.8 | value < -0.8)
corGT80percent
```

```
##                  Var1             Var2      value
## 105         roll_belt         yaw_belt  0.8155677
## 157         roll_belt total_accel_belt  0.9809116
## 366        pitch_belt     accel_belt_x -0.9664972
## 417         roll_belt     accel_belt_y  0.9244325
## 420  total_accel_belt     accel_belt_y  0.9265901
## 469         roll_belt     accel_belt_z -0.9920366
## 472  total_accel_belt     accel_belt_z -0.9747072
## 477      accel_belt_y     accel_belt_z -0.9328594
## 522        pitch_belt    magnet_belt_x -0.8824400
## 528      accel_belt_x    magnet_belt_x  0.8930028
## 954       gyros_arm_x      gyros_arm_y -0.9190891
## 1217      accel_arm_x     magnet_arm_x  0.8148940
## 1325     magnet_arm_y     magnet_arm_z  0.8169281
## 1695 gyros_dumbbell_x gyros_dumbbell_z -0.9847435
## 1744   pitch_dumbbell accel_dumbbell_x  0.8118029
## 1849     yaw_dumbbell accel_dumbbell_z  0.8513373
## 2371 gyros_dumbbell_x  gyros_forearm_z -0.9387690
## 2373 gyros_dumbbell_z  gyros_forearm_z  0.9518215
## 2385  gyros_forearm_y  gyros_forearm_z  0.8739898
```

```r
removeInputs <- unique(as.character(corGT80percent[,2]))
tr <- tr[, -which(names(tr) %in% removeInputs) ]
```

Considering that we shrink the tr dataset, we can also remove these columns of the other datasets (validation and testing)


```r
cols <- colnames(tr)
validation <- subset(validation, select = names(validation) %in% cols )
testing <- subset(testing, select = names(testing) %in% cols )
```

## Building the model

To build the model, I will initially consider the random forest the classify the classes of the subjects:


```r
model <- randomForest(classe ~., data=tr)
```

Now, with this model, we can check the confusion matrix of the training data. As we can observe, the accuracy in the training data is 100%.


```r
CM <- confusionMatrix(predict(model, tr), tr$classe)
CM$table
```

```
##           Reference
## Prediction    A    B    C    D    E
##          A 3906    0    0    0    0
##          B    0 2658    0    0    0
##          C    0    0 2396    0    0
##          D    0    0    0 2252    0
##          E    0    0    0    0 2525
```

```r
print(paste('Accuracy (%): ', 100*CM$overall['Accuracy']))
```

```
## [1] "Accuracy (%):  100"
```

```r
# The accuracy can also be calculated using:
# sum(predict(model, tr) == tr$classe)/length(predict(model, tr))
```

To check what will be the expected out-of-sample error in some testing data, we need to check our model using the validation database:


```r
CM <- confusionMatrix(predict(model, validation), validation$classe)
CM$table
```

```
##           Reference
## Prediction    A    B    C    D    E
##          A 1673    8    0    0    0
##          B    1 1124   16    0    0
##          C    0    7 1010   22    0
##          D    0    0    0  942    3
##          E    0    0    0    0 1079
```

```r
print(paste('Accuracy (%): ', 100*CM$overall['Accuracy']))
```

```
## [1] "Accuracy (%):  99.0314358538658"
```

```r
print(paste('Confidence interval (%): (', 100*CM$overall['AccuracyLower'], ', ', 100*CM$overall['AccuracyUpper'], ')'))
```

```
## [1] "Confidence interval (%): ( 98.7469117981355 ,  99.2656168099831 )"
```

```r
# The accuracy can also be calculated using:
# sum(predict(model, validation) == validation$classe)/length(predict(model, validation))
```

As we can observe, the accuray is >99%, which means that the expected out-of-sample error is about 1%. For the purpose of this project, this value is satisfatory. So, it is not necessary to consider other approaches.

## Predicting the test dataset

Now, we can use our model to predict in the test dataset:


```r
predict(model, testing)
```

```
##  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 
##  B  A  B  A  A  E  D  B  A  A  B  C  B  A  E  E  A  B  B  B 
## Levels: A B C D E
```

## References
[1] - http://groupware.les.inf.puc-rio.br/har

[2] - https://stackoverflow.com/questions/26666533/finding-row-column-names-from-a-correlation-matrix-values
