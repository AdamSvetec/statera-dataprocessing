#Script used to upload the issues that will be used for scoring
#Standard Environment cleansing
rm(list=ls())
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

#Write to database
dbWriteTable(conn=con, name="issue", value=issues, row.names = FALSE, overwrite = TRUE)
dbSendQuery(con, "alter table issue add Id int auto_increment primary key;")

dbDisconnect(con)