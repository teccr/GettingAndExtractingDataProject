## Extracting and Cleaning the "Human Activity Recognition Using Smartphones Data Set"
## 
## Author: Francisco Marin, 2015.
## Coursera: Getting and Cleaning Data Course, Data Science Specialization. 
## Summary: 
## This script will prepare a tidy dataset from the Human Activity Recognition Using Smartphones Data Set.
## The original zip file was made available by Samsung and it is used for educational purposes. Following  
## the instructions in the Coursera web site, a dataset will be generated following the tidy data principles.
##
## R packages used: dplyr, stringr
## The script requires an Internet Connection to download the data set. 
##
## Versions:
## 1.0: Initial Version

## Summary: 
## This main function will execute the analysis, it will get the data from the web, unzip it, extract the datasets, merge them,
## transform them and export them into one tidy data file.
## 
## Return Value: 
## No value is expected
run_analysis <- function() {
	# Loading the required libraries
	library(dplyr)
	library(stringr)
	
	## Clean log file if it exists
	if(file.exists(settings.LOG_FILE_NAME)) {
		unlink(settings.LOG_FILE_NAME, recursive=TRUE)
	}
	
	## Executing the steps
	log_entry("-----Step 1: Getting and checking the RAW data...---------------", settings.INFO_FLAG)
	prepare_files()
	log_entry("-----Step 2: Merging Training and Test Sets...------------------", settings.INFO_FLAG)
	united_data_set <- merge_datasets()
	log_entry("-----Step 3: Extracting Measurements in the new data set...-----", settings.INFO_FLAG)
	united_data_set <- extract_measures(united_data_set)
	log_entry("-----Step 4: Applying format and label names...-----------------", settings.INFO_FLAG)
	united_data_set <- apply_format(united_data_set)
	log_entry("-----Step 5: Export Tidy Data Set...----------------------------", settings.INFO_FLAG)
	export_tidy_data(united_data_set)
	log_entry("-----Transformation successful...-------------------------------", settings.INFO_FLAG)
}

## Summary:
## This function will download the data, extract the folder and verified the structure 
## of folders and files.
## Details:
## If one of the validations executed by the function over files and folders is not sucessful, it will
## stop the execution of the program with an error. Also, the function is downloading files from internet,
## deleting folders/files and unzip utils.
##
## Arguments:
## 	settings: An object containing the analysis settings
## Return Value:
##	The function does not return a value.
prepare_files <- function(settings) {
	## Because I am working on windows I am setting this variable to allow HTTPS downloads.
	#setInternet2(use = TRUE)
	#download.file(settings.file_url, destfile = settings.tmp_file)

	if(file.exists(settings.tmp_folder)) {
		log_entry("Existing data was found, it will be deleted...", settings.INFO_FLAG)
		unlink(settings.tmp_folder, recursive=TRUE)
		log_entry("Existing data was deleted...", settings.INFO_FLAG)
	}

	## unzip the downloaded data
	unzip(settings.tmp_file, list=FALSE, exdir=settings.tmp_folder)

	## quick verification of the Files and folders for the data set
	files <- list.files(path=settings.tmp_folder, full.names=FALSE, ignore.case=TRUE, recursive=TRUE)
	files <- sort(files, decreasing=FALSE)
	if(all(files == get_expected_files())) {
		log_entry("Files and folder are matching the expected structured...", settings.INFO_FLAG)
	} else {
		log_entry("Error: The files and folders do not match the expected structure...", settings.ERROR_FLAG)
	}
}

## Summary:
## This function will load the different data sets and merge them into one intermediate data frame.
## Details:
## The function will load each file, merge the different categories and create one united data set. This data set will .
## contain all the original observations in one consistent structure with Subjects, Activities names, data set names (test, train),
## and the different means and standard deviations. 
## 
## Return Value:
##	The function will return a data frame with all the observations unified in one structure with Activity Names, Subject Id, variables, features.
merge_datasets <- function() {
	log_entry("Loading Dataset for Activities and Features...", settings.INFO_FLAG)
	## extract the features data set
	activities_ds <- read.table(paste(settings.tmp_folder, settings.tmp_activities_file, sep="/"), col.names=c("ActivityId","ActivityName"), header=FALSE)
	features_ds <- read.table(paste(settings.tmp_folder, settings.tmp_features_file, sep="/"), col.names=c("FeatureId","FeatureName"), header=FALSE)
	## Setting target 
	features_ds <- features_ds[grepl("mean()", features_ds$FeatureName, ignore.case = TRUE) | grepl("std()", features_ds$FeatureName, ignore.case = TRUE), ]
	
	log_entry("Load the data sets with the train information...", settings.INFO_FLAG)
	train_ds <- extract_data_set(settings.tmp_train_X_file, settings.tmp_train_Y_file, settings.tmp_train_subject_file, features_ds, "Train", activities_ds)
	
	log_entry("Load the data sets with the test information...", settings.INFO_FLAG)
	test_ds <- extract_data_set(settings.tmp_test_X_file, settings.tmp_test_Y_file, settings.tmp_test_subject_file, features_ds, "Test", activities_ds)
	
	#log_entry("Merge the data sets", settings.INFO_FLAG)
	result_ds <- rbind(train_ds, test_ds)
	result_ds
}

## Summary:
## This function will merge different data frames into one data frame of observations.
## Details:
## The different components of the observations will be merge into one data frame, this will
## be the intermediate step that will allow data transformations for the required data frame in the project.
##
## Arguments:
## 	x_file_name: Name of the file containing the X values of the observations (measurements)
##	y_file_name: Name of the file containing the Y values of the observations
##	subject_file_name:	Name of the file containing the Subjects of the observations
##	features_ds: Data frame containing the features used in the experiment.
##	data_set_name: Name of the data set to evaluate ("Train" or "Test")
##	activities_ds: Data Frame containing the activities names. 
## Return Value:
##	Data frame containing all the columns of one set (train or test).
extract_data_set <- function(x_file_name, y_file_name, subject_file_name, features_ds , data_set_name, activities_ds) {

	## read the data sets
	subjects_ds_tmp <- read.table(paste(settings.tmp_folder, subject_file_name, sep="/"), col.names=c("SubjectId"), header=FALSE)
	outputY_ds <- read.table(paste(settings.tmp_folder, y_file_name, sep="/"), col.names=c("ActivityId"), header=FALSE)
	outputX_ds <- read.table(paste(settings.tmp_folder, x_file_name, sep="/"), header=FALSE)

	subjects_num <- length(subjects_ds_tmp)
	
	## Extracting target columns for the train set: mean() and Std() measures
	outputX_ds <- outputX_ds[, features_ds$FeatureId]
	names(outputX_ds) <- features_ds$FeatureName
	
	## set the activity names
	outputY_ds <- inner_join(outputY_ds, activities_ds ,by="ActivityId")
	ActivityNames <- outputY_ds$ActivityName
	names(ActivityNames) <- c("ActivityName")
	
	## Merging columns
	result <- cbind(data_set_name,subjects_ds_tmp)
	result <- cbind(ActivityNames, result)
	result <- cbind(result, outputX_ds)
	result <- rename(result, DataSetName = data_set_name )
	result
}

## Summary:
## This function will create the means of variables for each observation grouping by Activity, subject and data set (train or test).
##
## Arguments:
## 	target_data_set: Intermediate data frame with all the observations and columns involved.
## Return Value:
##	Tidy data set containing the mean of measurements by Subject Id, Activity and Data Set (Train or Test).
extract_measures <- function(target_data_set) {
	# generate a group by expression
	#group_expression <- group_by(target_data_set, ActivityNames, DataSetName, SubjectId)
	target_data_set <- target_data_set %>% group_by(ActivityNames, DataSetName, SubjectId) %>% summarise_each(funs(mean))
	target_data_set
}

## Summary:
## This function will apply format and label changes to the tidy data set.
##
## Arguments:
## 	target_data_set: Tidy data for the project.
## Return Value:
##	Tidy data set with the expected format.
apply_format <- function(target_data_set) {
	 fixed_col_names <- c("ActivityNames", "DataSetName", "SubjectId", "TBodyAccMeanX", "TBodyAccMeanY", "TBodyAccMeanZ", "TBodyAccStdX", "TBodyAccStdY", "TBodyAccStdZ", "TGravityAccMeanX", "TGravityAccMeanY", "TGravityAccMeanZ", "TGravityAccStdX", "TGravityAccStdY", "TGravityAccStdZ", "TBodyAccJerkMeanX", "TBodyAccJerkMeanY", "TBodyAccJerkMeanZ", "TBodyAccJerkStdX", "TBodyAccJerkStdY", "TBodyAccJerkStdZ", "TBodyGyroMeanX", "TBodyGyroMeanY", "TBodyGyroMeanZ", "TBodyGyroStdX", "TBodyGyroStdY", "TBodyGyroStdZ", "TBodyGyroJerkMeanX", "TBodyGyroJerkMeanY", "TBodyGyroJerkMeanZ", "TBodyGyroJerkStdX", "TBodyGyroJerkStdY", "TBodyGyroJerkStdZ", "TBodyAccMagMean", "TBodyAccMagStd", "TGravityAccMagMean", "TGravityAccMagStd", "TBodyAccJerkMagMean", "TBodyAccJerkMagStd", "TBodyGyroMagMean", "TBodyGyroMagStd", "TBodyGyroJerkMagMean", "TBodyGyroJerkMagStd", "FBodyAccMeanX", "FBodyAccMeanY", "FBodyAccMeanZ", "FBodyAccStdX", "FBodyAccStdY", "FBodyAccStdZ", "FBodyAccMeanFreqX", "FBodyAccMeanFreqY", "FBodyAccMeanFreqZ", "FBodyAccJerkMeanX", "FBodyAccJerkMeanY", "FBodyAccJerkMeanZ", "FBodyAccJerkStdX", "FBodyAccJerkStdY", "FBodyAccJerkStdZ", "FBodyAccJerkMeanFreqX", "FBodyAccJerkMeanFreqY", "FBodyAccJerkMeanFreqZ", "FBodyGyroMeanX", "FBodyGyroMeanY", "FBodyGyroMeanZ", "FBodyGyroStdX", "FBodyGyroStdY", "FBodyGyroStdZ", "FBodyGyroMeanFreqX", "FBodyGyroMeanFreqY", "FBodyGyroMeanFreqZ", "FBodyAccMagMean", "FBodyAccMagStd", "FBodyAccMagMeanFreq", "FBodyBodyAccJerkMagMean", "FBodyBodyAccJerkMagStd", "FBodyBodyAccJerkMagMeanFreq", "FBodyBodyGyroMagMean", "FBodyBodyGyroMagStd", "FBodyBodyGyroMagMeanFreq", "FBodyBodyGyroJerkMagMean", "FBodyBodyGyroJerkMagStd", "FBodyBodyGyroJerkMagMeanFreq", "Angle_TBodyAccMean_Gravity", "Angle_TBodyAccJerkMean_GravityMean", "Angle_TBodyGyroMean_GravityMean", "Angle_TBodyGyroJerkMean_GravityMean", "Angle_X_GravityMean", "Angle_Y_GravityMean", "Angle_Z_GravityMean")
	names(target_data_set) <- fixed_col_names
	
	target_data_set
}


## Summary:
## This function will apply format and label changes to the tidy data set.
##
## Arguments:
## 	target_data_set: Tidy data for the project.
## Return Value:
##	Tidy data set with the expected format.
export_tidy_data <- function(target_data_set) {
	write.table(target_data_set,file=settings.tidy_file_name, row.names = FALSE, append=FALSE)
}

## ----------------------------------------------------------------------
## ----------------------------------------------------------------------
## Settings and functions for utilities

## version of the procedure
settings.version = 1.0
## Url of the zip file containing the Research Data
settings.file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
## Name of the name of the temporary file 
settings.tmp_file <- "ResearchData.zip"
## Name of the temporary folder
settings.tmp_folder <- "./ResearchData"
## Name of the output file for the Tidy data set
settings.tidy_file_name <- "tidyds.txt"
## Name of the files with data
settings.tmp_features_file <- "UCI HAR Dataset/features.txt"
settings.tmp_activities_file <- "UCI HAR Dataset/activity_labels.txt"
settings.tmp_train_subject_file <- "UCI HAR Dataset/train/subject_train.txt"
settings.tmp_train_X_file <- "UCI HAR Dataset/train/X_train.txt"
settings.tmp_train_Y_file <- "UCI HAR Dataset/train/y_train.txt"
settings.tmp_test_subject_file <- "UCI HAR Dataset/test/subject_test.txt"
settings.tmp_test_X_file <- "UCI HAR Dataset/test/X_test.txt"
settings.tmp_test_Y_file <- "UCI HAR Dataset/test/y_test.txt"
settings.ERROR_FLAG <- "Error"
settings.INFO_FLAG <- "Info"
settings.LOG_FILE_NAME <- "LogFile.txt"

## Summary:
## This function will create an entry in the log file and print it in the R console. If the message
## is Error Category, it will send a stop signal.
##
## Arguments:
## 	entry_text: Message to log.
##	msg_level: Could be "Error" or "Info"
## Return Value:
##	No return value expected.
log_entry <- function(entry_text, msg_level) {
	if(msg_level == settings.ERROR_FLAG) {
		stop(entry_text)
	} else {
		print(entry_text)
		write(entry_text, file=settings.LOG_FILE_NAME, append=TRUE, sep = "\n")
	}
}

## Summary:
## This function will return the expected file structure.
##
## Return Value:
##	No return value expected.
get_expected_files <- function() {
	tmpFiles <- sort(c("UCI HAR Dataset/activity_labels.txt",   
	"UCI HAR Dataset/features.txt", 
	"UCI HAR Dataset/features_info.txt",  
	"UCI HAR Dataset/README.txt",  
	"UCI HAR Dataset/test/Inertial Signals/body_acc_x_test.txt",   
	"UCI HAR Dataset/test/Inertial Signals/body_acc_y_test.txt",   
	"UCI HAR Dataset/test/Inertial Signals/body_acc_z_test.txt",   
	"UCI HAR Dataset/test/Inertial Signals/body_gyro_x_test.txt",  
	"UCI HAR Dataset/test/Inertial Signals/body_gyro_y_test.txt",  
	"UCI HAR Dataset/test/Inertial Signals/body_gyro_z_test.txt",  
	"UCI HAR Dataset/test/Inertial Signals/total_acc_x_test.txt",  
	"UCI HAR Dataset/test/Inertial Signals/total_acc_y_test.txt",  
	"UCI HAR Dataset/test/Inertial Signals/total_acc_z_test.txt",  
	"UCI HAR Dataset/test/subject_test.txt", 
	"UCI HAR Dataset/test/X_test.txt", 
	"UCI HAR Dataset/test/y_test.txt", 
	"UCI HAR Dataset/train/Inertial Signals/body_acc_x_train.txt", 
	"UCI HAR Dataset/train/Inertial Signals/body_acc_y_train.txt", 
	"UCI HAR Dataset/train/Inertial Signals/body_acc_z_train.txt", 
	"UCI HAR Dataset/train/Inertial Signals/body_gyro_x_train.txt",
	"UCI HAR Dataset/train/Inertial Signals/body_gyro_y_train.txt",
	"UCI HAR Dataset/train/Inertial Signals/body_gyro_z_train.txt",
	"UCI HAR Dataset/train/Inertial Signals/total_acc_x_train.txt",
	"UCI HAR Dataset/train/Inertial Signals/total_acc_y_train.txt",
	"UCI HAR Dataset/train/Inertial Signals/total_acc_z_train.txt",
	"UCI HAR Dataset/train/subject_train.txt",  
	"UCI HAR Dataset/train/X_train.txt",  
	"UCI HAR Dataset/train/y_train.txt"), decreasing=FALSE)
	tmpFiles 
}

## ----------------------------------------------------------------------
## ----------------------------------------------------------------------
