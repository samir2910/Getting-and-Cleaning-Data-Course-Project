#clearing workspace
rm(list = ls())

require(readr)
require(dplyr)

## 1. Read and merges the training and the test sets to create one data set.

## X_train is a fixed width file where each field is a 16 character double
X_train <- read_fwf("UCI HAR Dataset/train/X_train.txt",
                    fwf_widths(rep(16,561)), ##561 fixed width fields of 16 character
                    cols(
                      .default = col_double() ##all fields are double
                    )
)

## X_test is a fixed width file where each field is a 16 character double
X_test <- read_fwf("UCI HAR Dataset/test/X_test.txt",
                   fwf_widths(rep(16,561)), ##561 fixed width fields of 16 character
                   cols(
                     .default = col_double() ##all fields are double
                   )
)


##tidyDataset is a merge of X_train and X_test
AccelerometersData <- bind_rows(X_train, X_test)



## 2. Extracts only the measurements on the mean and standard deviation for each measurement.

##features is a space delimited file
features <- read_delim("UCI HAR Dataset/features.txt",
                       " ", ##space delimited
                       col_names = FALSE, ##no headers,
                       col_types = "ic" ## integer, character
)
names(features) <- c("FeatureId","FeatureLabel")

##We search the feature Labelriptions that contains mean() or std()
##That gives us the index of the columns where we have means and standard deviations
MeansAndStdIndexes <- grep("mean\\(\\)|std\\(\\)", features$FeatureLabel)

##We extract only these columns from AccelerometersData
AccelerometersData <- AccelerometersData %>%
  select(MeansAndStdIndexes)

##We rename the columns with the feature name (removing the brakets)
names(AccelerometersData) <- gsub("\\(\\)", "",features$FeatureLabel[MeansAndStdIndexes])

## 3.Uses descriptive activity names to name the activities in the data set

## y_train and y_test are simple lists
y_train <- read_table("UCI HAR Dataset/train/y_train.txt",
                      col_names = FALSE,
                      col_types = "i")
y_test <- read_table("UCI HAR Dataset/test/y_test.txt",
                     col_names = FALSE,
                     col_types = "i")

## merging y_train and y_test
y_all <- bind_rows(y_train, y_test)
names(y_all) <- "ActivityId"

## Read the activity table - a space delimited file
activities <- read_delim("UCI HAR Dataset/activity_labels.txt",
                       " ", ##space delimited
                       col_names = FALSE, ##no headers,
                       col_types = "ic" ## integer, character
)
names(activities) <- c("ActivityId","ActivityLabel")

## Transform the ids in y by meaningfull activity descriptions
y_all_activities <- y_all %>%
  inner_join(activities, by = "ActivityId") %>%
  select(ActivityLabel)

##Add to our table
AccelerometersData <- bind_cols(AccelerometersData, y_all_activities)


##Adding subjects to our table
###subject_train is a simple table
subject_train <- read_table("UCI HAR Dataset/train/subject_train.txt",
                            col_names = FALSE,
                            col_types = "i")

###subject_test is a simple table
subject_test <- read_table("UCI HAR Dataset/test/subject_test.txt",
                           col_names = FALSE,
                           col_types = "i")

## merging subject_train and subject_test
subject_all <- bind_rows(subject_train, subject_test)
names(subject_all) <- "SubjectId"

## Adding to our table
AccelerometersData <- AccelerometersData %>%
  bind_cols(subject_all)

## 4.Appropriately labels the data set with decriptive variable names.
## Done


## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
AverageAccelerometersDataPerActivityPerSubject <- AccelerometersData %>%
  group_by(SubjectId, ActivityLabel) %>%
  summarise_all(funs(mean))

## We add _mean to all the column names we summarized
names(AverageAccelerometersDataPerActivityPerSubject) <- 
  c(
    names(AverageAccelerometersDataPerActivityPerSubject)[c(1,2)],
    paste(
      names(AverageAccelerometersDataPerActivityPerSubject)[3:68],
      "_mean"
      )
  )

##write table to a file
write.table(AverageAccelerometersDataPerActivityPerSubject, "AverageAccelerometersDataPerActivityPerSubject.csv", row.names = FALSE)
