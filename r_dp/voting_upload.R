#Used to upload voting record of each bill put before congress
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), group="data-processing")
#Will use directory specified in command line arguments or will use:
foldername = '~/BulkData/votes'
#Will recursively read all data.json files and add bill and voting records to the database

#Parse command line arguments to get filepath of legislators-historic.csv
args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
  foldername = args[1]
}

#Creates list of all data.json file stored in foldername
filenames <- list.files(foldername, pattern="*.json", full.names=TRUE, recursive = TRUE)

#Used to import the voting records that use the json values
library(rjson)

#Establish database connection and clear bills and votes table
ignore<-dbRemoveTable(conn=con, name=BILL_TBL_NAME)
ignore<-dbRemoveTable(conn=con, name=VOTE_TBL_NAME)

num_files <- length(filenames)
status(paste("Uploading",num_files,"bills and respective voting records"))
#For every data.json file in the votes directory
for(i in 1:num_files){
  #Read in json file into voting_record object
  voting_record <- fromJSON( file=filenames[i], method = "C", unexpected.escape = "error" )

  #Read bill data and insert it into the database
  bill <- c()
  bill['category'] <- voting_record['category']
  bill['chamber'] <- voting_record['chamber']
  bill['congress'] <- voting_record['congress']
  bill['date'] <- voting_record['date']
  bill['date'] <- substring(voting_record['date'],first=1, last=10)
  bill['date'] <- as.Date(as.character(bill['date']), format="%Y-%m-%d")
  bill['number'] <- voting_record['number']
  bill['vote_id'] <- voting_record['vote_id']
  bills <- data.frame(bill)
  #Write bill objects to database
  ignore <- dbWriteTable(conn=con, name=BILL_TBL_NAME, value=bills, row.names = FALSE, overwrite = FALSE, append = TRUE)

  #Read voting records for given bill and insert them into the database
  vote <- c()
  votes <- data.frame(pol_id=character(), y_or_no=character(),bill_id=character(), stringsAsFactors=FALSE)
  #For every no vote
  for(nay_vote in voting_record$votes$Nay){
    vote['pol_id'] <- nay_vote$id
    vote['y_or_n'] <- 'n'
    vote['bill_id'] <- bill['vote_id']
    votes[nrow(votes)+1,] <- vote
  }
  #For every yes vote
  for(aye_vote in voting_record$votes$Aye){
    vote['pol_id'] <- aye_vote$id
    vote['y_or_n'] <- 'y'
    vote['bill_id'] <- bill['vote_id']
    votes[nrow(votes)+1,] <- vote
  }
  
  #Write voting records to database
  ignore <- dbWriteTable(conn=con, name=VOTE_TBL_NAME, value=votes, row.names = FALSE, overwrite = FALSE, append = TRUE)
  progress(i, num_files)
}

ignore <- dbDisconnect(con)