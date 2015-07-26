# https://github.com/gsgxnet/cproj_tidy_gs

library(dplyr)

# read the description for the activities into a data.frame
activity_labels <- read.table("activity_labels.txt", header = FALSE, stringsAsFactors = FALSE, col.names = c("activity", "activityDescr"))

# read the features(=column names) into a data.frame
features <- read.table("features.txt", header = FALSE, sep = " ", stringsAsFactors = FALSE, col.names = c("colNr", "colXname"))

# a vector specifying the with of all numeric columns
tXfields <- rep(16, times=561)

# read the calculated raw data of measurements of directory test, using the variable names from features
testX <- read.fwf("./test/X_test.txt", widths = tXfields, header = FALSE, stringsAsFactors = FALSE, col.names = features$colXname)
# read the activities corrosponding to the measurements
testy <- read.table("./test/y_test.txt", col.names = c("activity"))
# read the subjects corrospondung to the measurements
testSubj <- read.csv("./test/subject_test.txt", header = FALSE, stringsAsFactors = FALSE, col.names = c("Subj"))
# combine subjects, activities and measurements into one dataframe
testSubjActiX <- cbind(testSubj,testy,testX)

# read the data from the train collection in the same way as from the test collection
trainX <- read.fwf("./train/X_train.txt", widths = tXfields, header = FALSE, stringsAsFactors = FALSE, col.names = features$colXname)
trainy <- read.table("./train/y_train.txt", col.names = c("activity"))
trainSubj <- read.csv("./train/subject_train.txt", header = FALSE, stringsAsFactors = FALSE, col.names = c("Subj"))
trainSubjActiX <- cbind(trainSubj,trainy,trainX)

# combine the train and test collection, using only the specified measurements
ttSubjActiX <- tbl_df(rbind(trainSubjActiX,testSubjActiX)) %>% # 10299 row 68 col
  select(Subj, activity, contains(".mean."), contains(".std.")) %>%
  group_by(activity, Subj) 

# condense the measurements by activity and subject 
ttASXmeans <- summarise_each(ttSubjActiX, funs(mean) )

# replace the numeric activities by activity descriptions
ttActivlabelSubjXmeans <- merge(ttASXmeans, activity_labels) %>% select(activityDescr, -activity, Subj:fBodyBodyGyroJerkMag.std..)

# export the condensed tidy data set
write.table(ttActivlabelSubjXmeans, file = "ttActivlabelSubjXmeans.txt", row.names = FALSE)
