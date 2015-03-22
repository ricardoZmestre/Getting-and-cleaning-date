# Getting and Cleaning data -- project course

## Goals

The goal is to create a tidy dataset based on the existing data [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip), where results from an experiment with smartphones are collected. The experiment measured movements of 30 subjects, as measured by the smartphone sensors, according to 6 different activities: walking, walking upstairs, walking downstairs, sitting, standing and laying. Data include a training and a test parts. Each kind of measurement is present with different statistics, among which means and standard deviations.

The goal of the exercise is to clean up the dataset by: 

1. merging the training and test parts of the data;
2. extracting measurements for the mean and standard deviation of each, discarding the other statistics;
3. set variable names for subject and type of activity;
4. set variable names for the measurements to make them easy to identify.

Furthermore, the means of the measurements for each pair of subject and activity must be calculated and downloaded into a fix-format dataset.

## Steps

The steps to accomplish the task can be found in run_analysis.R, an R script where the following steps are taken:

1. The initial dataset is downloaded, unzipped and read.

The code is such that downloading and unzipping the original dataset, which takes time, is only performed if the file is not already present. This step creates a folder structure which contains, at different levels of depth, files for the measurements of the train and test parts (**X_trend.txt** and **X_train.txt**), for the subjects (**subject_train.txt** and **subject_test.txt**) and for the activities (**y_train.txt** and **y_test.txt**). Labels are collected in separate files for the activities (**activity_labels.txt**) and the different measurements (**features.txt**).

2. The next step is to collect all the information in a single tidy file, without distinguishing the train and test parts of the experiment.

This is achieved by binding all the train information into a single data.frame, using function *cbind()* to gather the information, and naming variables according to the labelling information. The same steps are taken for the test data. Finally, the two data frames are joined together (using *rbind()*) to form the data frame with the omplete information. As a last step, measurements statistics other than mean and standard deviation are deleted, using function *grep()* to select the correct columns.

3. The last step is to calculate means of the measurements according to subject and activity.

This is done using function *summarise_each()* in package *dplyr*, which applies a given function (in this case, *mean()*) to all columns in a data frame. The data frame is first grouped by subject and acitvity, using function *group_by()*, so that the means are calculated per group. The resulting data frame is ungrouped (to restore it to a flat group structure) and downloaded into a text file called datamean.txt.

A codebook is also supplied in R markdown file codebook.Rmd.


