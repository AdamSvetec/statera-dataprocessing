#Script used to upload the scores of analyzed bills
#Standard Environment cleansing
rm(list=ls())
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

issue_names <- colnames(bill_scores)
if(issue_names[1] != "id"){
  stop("First entry in issues table should be bill's id")
}
id_numbers <- c(-1)
i <- 2
while(i <= length(issue_names)){
  result <- dbGetQuery(con, paste("select Id from issue where issue_shortname=\"", gsub("."," ",issue_names[i], fixed = TRUE),"\"", sep=""))
  #result <- list(Id=1)
  if(length(result$Id) == 0){
    stop("bill score header not found in database")  
  }
  id_numbers[i] <- as.integer(result$Id)
  i=i+1
}

bill_score_upload <- function(row, bcon, bid_numbers){
  scores_frame = data.frame("bill_id"=character(), "issue_id"=numeric(), "score"=numeric(), stringsAsFactors=FALSE)
  for(i in 2:length(bid_numbers)){
    scores_frame[i-1,"bill_id"] <- row["id"]
    scores_frame[i-1,"issue_id"] <- bid_numbers[i]
    scores_frame[i-1,"score"] <- row[i]
  }
  dbWriteTable(conn=bcon, name="bill_score", value=scores_frame, row.names = FALSE, overwrite = FALSE, append = TRUE)
  rm(scores_frame)
}

dbRemoveTable(conn=con, name="bill_score")
apply(bill_scores, 1, bill_score_upload, bcon = con, bid_numbers = id_numbers)

#Delete all bills that are not analyzed to allow for much faster scoring
dbSendStatement(con, 
"DELETE FROM bill
WHERE NOT EXISTS 
	(SELECT *
	FROM bill_score
	WHERE bill_score.bill_id = bill.vote_id);")

dbDisconnect(con)