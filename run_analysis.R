#Load packages
library(dplyr)

library(tidyr)

# Read Activity Labels and Features 

activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt"
                              , header = FALSE, col.names = c("actnum", "actdesc"))
features <- read.table("./data/UCI HAR Dataset/features.txt"
                       , header = FALSE, col.names = c("colnum","coldesc"))

# Read subject_train, X_train and y_train

subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", header = FALSE, col.names = "subject")
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt", sep = "", header = FALSE, col.names = features$coldesc)
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt", sep = " ", header = FALSE, col.names = "actnum")

# Read  subject_test, X_test, y_test

subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", header = FALSE, col.names = "subject")
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt", sep = "", header = FALSE, col.names = features$coldesc)
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt", sep = "", header = FALSE, col.names = "actnum")

# Combine  test and training data sets 

x_all <- rbind(x_train, x_test)
y_all <- rbind(y_train, y_test)
subj_all <- rbind(subject_train, subject_test)

# Combine x_all, y_all and subj_all to create a new data frame 'har' (Human Activity Recognition) dataset

har <- cbind(subj_all, y_all, x_all)

# Clean up all interim data frames

rm(subject_test, subject_train, x_test, x_train, y_test, y_train)
rm(x_all, y_all, subj_all)

# Create a data frame with only mean and stdev for each measurement

harSub <- select(har, subject, actnum, contains("mean"), contains("std"), -contains("meanFreq"))

# Descriptive names, rearrange, sort columns and make tidy

harSub <- merge(harSub, activity_labels, by = "actnum")

harSub <- select(harSub, 2, 1, 76, 3:75) 

harSub <- arrange(harSub,subject, actnum)

harSub$subject <- as.factor(harSub$subject)
harSub$actnum <- as.factor(harSub$actnum)

# Summarise

gather <- gather(harSub, measure, value, 4:75)
summary <- harSub %>% group_by(subject, actnum, actdesc) %>% summarise_each(funs(mean))    
        

# Write dataset to file

write.table(summary, file = "./UCI-HAR/HAR_summary.txt", quote = FALSE
            , sep = " ", row.names = FALSE, col.names = TRUE)