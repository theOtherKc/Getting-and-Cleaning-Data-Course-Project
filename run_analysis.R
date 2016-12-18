library(reshape2)

file_name <- "input_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(file_name)){
  file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(file_url, file_name,mode="wb")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file_name) 
}

# Load the activity labels and features needed for this project
act_Lables <- read.table("UCI HAR Dataset/activity_labels.txt")
act_Lables[,2] <- as.character(act_Lables[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
features_needed <- grep(".*mean.*|.*std.*", features[,2])
features_needed.names <- features[features_needed,2]
features_needed.names = gsub('-mean', 'Mean', features_needed.names)
features_needed.names = gsub('-std', 'Std', features_needed.names)
features_needed.names <- gsub('[-()]', '', features_needed.names)


# Load the datasets from files
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_needed]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_needed]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge the two datasets and add labels
combinedData <- rbind(train, test)
colnames(combinedData) <- c("subject", "activity", features_needed.names)

# convert activities and subjects into factors
combinedData$activity <- factor(combinedData$activity, levels = act_Lables[,1], labels = act_Lables[,2])
combinedData$subject <- as.factor(combinedData$subject)

combinedData.melted <- melt(combinedData, id = c("subject", "activity"))
combinedData.mean <- dcast(combinedData.melted, subject + activity ~ variable, mean)

write.table(combinedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
