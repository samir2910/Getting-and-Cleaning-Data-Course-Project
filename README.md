# Getting-and-Cleaning-Data-Course-Project
Script to clean the data collected from the accelerometers from the Samsung Galaxy S smartphone. 

Source data:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The R script called run_analysis.R creates the "AccelerometersData" data table by doing the following:
1. Merges the training and the test sets to create one data set
2. Extracts only the measurements on the mean and standard deviation for each measurement
3. Uses descriptive activity names to name the activities in the data set and add subject id
4. Appropriately labels the data set with descriptive variable names.

It also creates a second data set called "AverageAccelerometersDataPerActivityPerSubject" with the average of each variable for each activity and each subject