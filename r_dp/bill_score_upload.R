#Script used to upload the scores of analyzed bills
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(),group="data-processing")
#Will use filepath specified in command line arguments or will use:
filename = '~/BulkData/bill_scores.csv'

#Parse command line arguments to get filepath of bill scores
args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
  filename = args[1]
}

#Read bill scores into dataframe for processing
bill_scores <- read.table(filename, header=TRUE, sep=",", quote="|", comment.char='#', stringsAsFactors=FALSE)

#For each issue name ensure there is a matching issue in the database and get it's id
issue_names <- colnames(bill_scores)
if(issue_names[1] != "id"){
  stop("First entry in issues table should be bill's id")
}
id_numbers <- c(-1)
for(i in 2:length(issue_names)){
  result <- dbGetQuery(con, paste("SELECT Id FROM ",ISSUE_TBL_NAME," WHERE issue_shortname=\"", gsub("."," ",issue_names[i], fixed = TRUE),"\"", sep=""))
  if(length(result$Id) == 0){
    stop("bill score header not found in database")  
  }
  id_numbers[i] <- as.integer(result$Id)
}

#Uploads the scores of a bill for each issue
bill_score_upload <- function(row){
  scores_frame = data.frame("bill_id"=character(), "issue_id"=numeric(), "score"=numeric(), stringsAsFactors=FALSE)
  for(i in 2:length(id_numbers)){
    scores_frame[i-1,"bill_id"] <- row["id"]
    scores_frame[i-1,"issue_id"] <- id_numbers[i]
    scores_frame[i-1,"score"] <- row[i]
  }
  ignore <- dbWriteTable(conn=con, name=BILL_SCORE_TBL_NAME, value=scores_frame, row.names = FALSE, overwrite = FALSE, append = TRUE)
  rm(scores_frame)
}

#For every bill insert it's scores
ignore <- dbRemoveTable(conn=con, name=BILL_SCORE_TBL_NAME)
ignore <- apply(bill_scores, 1, bill_score_upload)

#Delete all bills that are not analyzed to allow for faster scoring
ignore <- dbSendStatement(con,paste( 
  "DELETE FROM ",BILL_TBL_NAME," 
  WHERE vote_id NOT IN 
	  ( SELECT bill_id
	  FROM ",BILL_SCORE_TBL_NAME,");",sep=""))

#Delete all votes for bills that are not analyzed to allow for faster scoring
ignore <- dbSendStatement(con, paste(
  "DELETE FROM ",VOTE_TBL_NAME,"
  WHERE bill_id NOT IN 
	  ( SELECT vote_id
	  FROM ",BILL_TBL_NAME," );",sep=""))

ignore <- dbDisconnect(con)