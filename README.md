# Project for the "Getting and Cleaning Data" Course in Coursera.
## Author: Francisco Marin
## 2015

## Objective
The purpose of the project is to generate a Tidy data set from the data provided by researches in the link:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
The original data is not matching the tidy data principles. Each observation has a piece of data in a different file. The files contain RAW data collected from different sensors in the experiment and the analysis was done later in a different phase. 

# Solution
The main script of the project is “run_analysis.R”. The script contains all the functions required to load, merge, transform and save the data. The output will be a tidy dataset following the requirements defined by the project instructors. The script will download the data, unzip it and execute all the procedures to create the tidy data set. Finally, the script will generate a small log file with the steps executed (the same information will be printed in the R console).

R Requirements:
-dplyr package.
-stringr package.
-Internet connection to download the files.

The script was tested in this system:
-OS: Microsoft Windows 7 64-Bit
-R 64-Bit 3.1.2 (2014-10-31)
-Intel(R) Core(TM) i5-2450 CPU @ 2.50 GHz 2.50 GHz
-8 GB RAM
-2 GB Video Memory

## Structure of the Code
The script (“run_analysis.R”) contains the following parts:
* run_analysis
* prepare_files
* merge_datasets
* extract_measures
* apply_format
* export_tidy_data
* Utility functions
* Script Settings

### run_analysis() function
It is the entry point for the study. It must be called without arguments to trigger the generation of the tidy data set. The function will execute other functions in the following order: 
* prepare_files
* merge_datasets
* extract_measures
* apply_format
* export_tidy_data

### prepare_files() function
This function will download the data, extract the folder and verified the structure of folders and files. If the data already exists in the system, the script will delete it and replace it with the downloaded data. 
Internet connection will be required for this step. 

### merge_datasets() function
This function will load all the files containing information about observations and data categories. It will merge all the information and the output will be an intermediate data set containing a wide
representation of the data. Each measurement will be a column and the extracted measurements are Mean and Standard Deviation from the original Human Activity Recognition data base. Everything will be order by Subject Id, Activity Name and Data Set type (train or test) of the observation. 
In this function the output will be a united version of the RAW data, merging every file according to the relationships between them:
* activity_Labels: Names and Id of activities in the experiment.
* features.txt: Names and Id of the Features (measures captured by the smart phones and sensors).
* subject_train.txt and subject_test.txt: Files containing the subject Id of each observation. 
* y_train.txt and y_test.txt: Files containing the activity Id of each observation.
* X_train.txt and X_test.txt: Files containing the features recorded for each observation. One row by observation and one column by feature.

### extract_measures() function
This function will transform the data returned by the merge_datasets() function. It will group by the Subject Id, Activity Name and Data Set Type (Train or Test). For each group, the script will calculate the mean of each column. This will create the tidy version of the data set requested in this project. The code will use the dplyr package to group and summarize each feature.

### apply_format() function
This function will apply format options. In this project, the only format option is the measures names. This function will replace the names of each columns for human friendly names.

### export_tidy_data() function
This function will save the tidy data in a file using the write.table() function. 

### Utility functions
Those are different functions created to reuse code and make easier the development and maintenance of the script. The functions are:
* extract_data_set: This function will load different files to built a data frame for Train or Test files. It is used in the extract_measures function.
* log_entry: This function will create a log entry in the log file. Also, it will print the information in the R console. If the message is an error, the function will use the stop function from R (There is a flag required as a script parameter to define the message category).
* get_expected_files: This function will get the expected file structure for the zip file containing the experiment data (Folders and files).

## Script settings
A set of variables is containing the parameters for the script. In this way it is easy to change file names, directories and other data. It can be changed to load the data from a separate parameter file. Each setting is specify bellow:
* settings.version: Version of the script.
* settings.file_url: Url of the file containing the data.
* settings.tmp_file: Name of the zip file for the data. The R script will save the zip with this name.
* settings.tmp_folder: Folder where the data will be unzipped. 
* settings.tidy_file_name: Name of the file for the tidy data set (including file extension).
* settings.tmp_features_file: Name of the file containing the features list.
* settings.tmp_activities_file: Name of the file containing the activities list.
* settings.tmp_train_subject_file: Name of the file containing the Subjects list for the "train" data.
* settings.tmp_train_X_file: Name of the file containing the X Axis Observations for the "train" data.
* settings.tmp_train_Y_file: Name of the file containing the Y Axis Observations for the "train" data.
* settings.tmp_test_subject_file: Name of the file containing the Subjects list for the "test" data.
* settings.tmp_test_X_file: Name of the file containing the X Axis Observations for the "test" data.
* settings.tmp_test_Y_file: Name of the file containing the Y Axis Observations for the "test" data.
* settings.ERROR_FLAG: Name of the message category representing an error message.
* settings.INFO_FLAG: Name of the message category representing an information message.
* settings.LOG_FILE_NAME: Name and extension of the Log File.