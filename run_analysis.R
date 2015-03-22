## Code for the course project of course Getting and Cleaning Data, in coursera
## Data used is a CSV file downloaded from the internet, as per isntructions
# Data are downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

library(data.table)
library(dplyr)

## initial data handling

# Check the zip file exists, if not download and unpack it.
# Beware! The download takes a very long time.
filename <- 'getdata%2Fprojectfiles%2FUCI HAR Dataset.zip'
#filename <- 'getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
#filename <- 'getdata/projectfiles/FUCI HAR Dataset.zip'
if (!file.exists(filename)) {
  url <- paste0('https://d396qusza40orc.cloudfront.net/', filename)
  download.file(url, filename, method='wget')
  # the code below does not work under R 3.1.3, because of wrongly formated url. (?)
  #download.file(cat('https://d396qusza40orc.cloudfront.net/', filename, sep=''),
  #              filename, method='wget')
  unzip(filename)
}

# get list of files, including their paths, from the unzipped file
files <- unzip(filename, list = TRUE)[,1]

# Handle relevant files in loop
# instead of hard-coding the paths to the files, the path names are searched in the 
# unzipped file and loaded into data frames using the function assign().
# NB: I use .Platform$file.sep in filenames to avoid problems between '/' as path
# separator in Windows as opposed to '\' in linux.
varNames <- c('X_test','subject_test','y_test',
              'X_train','subject_train','y_train',
              'activity_labels','features')
for (varName in varNames) {
  inFile <- paste0(.Platform$file.sep, varName, '.txt')
  if (length((idx <- grep(inFile, files)))>0) {
    inFile <- files[idx]
    print(sprintf('%s -- %s\n', varName, inFile))
  } else stop(inFile, ' missing')
  assign(varName, read.table(inFile))
}

# Handling X (the measurements)
## first, process the measuremnsts for the test part of the experiment
# create the proper labels for the measurements
names(X_test) <- features[[2]]
# then, drop measurements which are not means or standard deviations using grep()
X_test <- X_test[, grep('mean\\(\\)|std\\(\\)',names(X_test))]
# do the same for the train part of the data
names(X_train) <- features[[2]]
X_train <- X_train[, grep('mean\\(\\)|std\\(\\)',names(X_train))]
# Variable for test/train
type <- data.frame(rep(TRUE, nrow(X_test)))

## Now, handle the information for the activities
# first, put the labels
names(y_test) <- names(y_train) <- 'Activities'
# then, transform the activity variables into factors, to beautify them
# the advantage of using factors is that one gets labels in a very economic way
# the alternative would be to have strings for the 6 activities repated a large number of times
y_test$Activities <- factor(y_test$Activities, labels = activity_labels[[2]])
y_train$Activities <- factor(y_train$Activities, labels = activity_labels[[2]])

## Handling te information for the subjects, namely labelling them
names(subject_test) <- names(subject_train) <- 'Subject'

## Create now a data frames for the train and test parts, using cbind()
data_test <- cbind(subject_test, y_test, X_test)
data_train <- cbind(subject_train, y_train, X_train)
# And now create a single data set with the train and test parts together, using rbind()
data <- rbind(data_test, data_train)

# As a last step, create a data frame with averages of measurements by subject and activity,
# based on the overall data frame defined above
datamean <- data %>% 
  group_by(Subject, Activities) %>%
  summarise_each(funs(mean)) %>% 
  ungroup()
str(datamean)

# Finally, beautify names (a bit, they were not bad to start with)
# name of variables: get rid of parenthesis and hyphens
names(datamean) <- gsub('\\(\\)','',names(datamean))
names(datamean) <- gsub('-','.',names(datamean))
# let's also beautify the names of the variables by replacing 't' by 'time', 'f' by 'freq'
names(datamean) <- gsub('^t','time',names(datamean))
names(datamean) <- gsub('^f','freq',names(datamean))

write.table(datamean, file = 'datamean.txt', row.names = FALSE)

# end
