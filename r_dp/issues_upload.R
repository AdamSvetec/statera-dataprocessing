#Script used to upload the issues that will be used for scoring
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), group="data-processing")
#Will use filepath specified in command line arguments or will use:
filename = '~/BulkData/issues.csv'

#Parse command line arguments to get filepath of issues
args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
  filename = args[1]
}

#Read in issues from file specified
issues <- read.table(filename, header=TRUE, sep=",", quote="|", stringsAsFactors=FALSE)

#Write issues to database
ignore<-dbWriteTable(conn=con, name=ISSUE_TBL, value=issues, row.names = FALSE, overwrite = TRUE)
ignore<-dbSendQuery(con, paste("ALTER TABLE ",ISSUE_TBL," ADD Id INT AUTO_INCREMENT PRIMARY KEY;",sep=""))

ignore <- dbDisconnect(con)