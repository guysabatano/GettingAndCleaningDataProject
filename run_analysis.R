library(reshape)
library(reshape2)
# Define file path locations
basePath  <- "./UCI HAR Dataset/UCI HAR Dataset"
testPath <- paste(basePath,"/test", sep="")
trainPath <- paste(basePath,"/train", sep="")

# Define file locations.
activtyLabelsPath<-paste(basePath,"/activity_labels.txt", sep="")
featuresPath<-paste(basePath,"/features.txt", sep="")
#define test files
xTestPath <- paste(testPath,"/X_test.txt", sep="")
subjectTestPath <- paste(testPath,"/subject_test.txt", sep="")
yTestPath <- paste(testPath,"/y_test.txt", sep="")

#define train files
xTrainPath <- paste(trainPath,"/X_train.txt", sep="")
subjectTrainPath <- paste(trainPath,"/subject_train.txt", sep="")
yTrainPath <- paste(trainPath,"/y_train.txt", sep="")




#Load labels and features
dfActivityLabels <- read.delim(activtyLabelsPath, sep=" ",header=F)
dfFeatures <- read.delim(featuresPath, sep=" ",header=F)
vFeatures<-as.character(dfFeatures[,2])
#dfXTest<-read.fwf(xTestPath,widths=rep(16,each=561),header=F)
#load test files
dfXTest<-read.table(xTestPath,header=F)
dfYTest<-read.table(yTestPath,header=F)
dfTestSubject<-read.table(subjectTestPath, header=F)

#load train files
dfXTrain<-read.table(xTrainPath,header=F)
dfYTrain<-read.table(yTrainPath,header=F)
dfTrainSubject<-read.table(subjectTrainPath, header=F)

# manipulate the features removing _ - and ,
#vFeatures<- gsub("\\(","",vFeatures)
#vFeatures<- gsub("\\)","",vFeatures)
vFeatures<- gsub(",","",vFeatures)
vFeatures<- gsub("-","",vFeatures)
vFeatures<- gsub("_","",vFeatures)
#add dimension names to the data sets.
names(dfXTest)<- vFeatures
names(dfXTrain)<- vFeatures
names(dfTrainSubject)<-"subject"
names(dfTestSubject)<-"subject"
names(dfYTest)<-"activityid"
names(dfYTrain)<-"activityid"
names(dfActivityLabels)<-c("activityid","activity")


#combine activity labels with activity
#print("1")
dfActivtyTest<-merge(dfActivityLabels,dfYTest,by.x="activityid")
#print("2")
dfActivtyTrain<-merge(dfActivityLabels,dfYTrain,by.x="activityid")
#combine subjects with observations
#print("3")
dfTrain<-cbind(dfTrainSubject,dfActivtyTrain,dfXTrain)
#print("4")
dfTest<-cbind(dfTestSubject,dfActivtyTest,dfXTest)
#combine dataframes
#print("5")
dfAllData<-rbind(dfTest,dfTrain)
#print("6")

dfAllData<-dfAllData[,c(1,2,3,grep("std", colnames(dfAllData)), grep("mean", colnames(dfAllData)))]

meltAllData <- melt(dfAllData, id = c("subject", "activity"))
dfAllDataMean <- dcast(meltAllData, subject + activity ~ variable, mean)



## write data 
write.table(dfAllDataMean, file="TidyDataMeans.txt", quote=FALSE, row.names=FALSE, sep="\t")

## write codebook
write.table(paste("* ", names(dfAllDataMean), sep=""), file="CodeBook.md", quote=FALSE,
            row.names=FALSE, col.names=FALSE, sep="\t")
