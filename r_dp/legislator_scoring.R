#Scores each legislator on each issue according to their voting history
#Standard Environment cleansing
rm(list=ls())
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(),group="data-processing")

#Get's a list of all legislator id's to score
legislator_table <- dbGetQuery(con, "SELECT bioguide_id, opensecrets_id FROM legislator;")
#Get's a list of all issue id's
issue_ids <- dbGetQuery(con, "SELECT Id FROM issue GROUP BY Id")

#Generates a score for a given legislator and issue
generate_score <- function(legislator_id, issue_id){
  #Need lean of each bill they voted on and how they voted
  leans <- dbGetQuery(con, paste(
    "SELECT y_or_no, score
    FROM vote, bill_score
    WHERE vote.pol_id = \"",legislator_id,"\" AND vote.bill_id = bill_score.bill_id AND bill_score.issue_id = ",issue_id," AND EXISTS (
	    SELECT *
	    FROM bill
	    where bill.vote_id = vote.bill_id);",sep=""))
  if(nrow(leans) == 0){
    return(0)
  }
  total_lean <- 0
  #If the legislator voted yes on the bill, add the score, but add the negation of the score if they voted no
  for(i in 1:nrow(leans)){
    if(leans[i,'y_or_no'] == 'y'){
      total_lean <- total_lean + as.numeric(leans[i,'score'])
    }else{
      total_lean <- total_lean - as.numeric(leans[i,'score'])
    }
  }
  return(total_lean / nrow(leans))
}

#Takes a given legislator and scores them on each issue
score_legislator <- function(legislator){
  leg_scores <- data.frame("leg_id"=character(),"issue_id"=numeric(),"score"=numeric(), stringsAsFactors=FALSE)
  for(issue_id in issue_ids$Id){
    leg_scores[nrow(leg_scores)+1,"leg_id"] <- legislator['opensecrets_id']
    leg_scores[nrow(leg_scores),"issue_id"] <- issue_id
    leg_scores[nrow(leg_scores),"score"] <- generate_score(legislator['bioguide_id'], issue_id)
  }
  dbWriteTable(conn=con, name="pol_score", value=leg_scores, row.names = FALSE, overwrite = FALSE, append = TRUE)
}

#Removes the table from the database before recalculating
dbRemoveTable(con, name="pol_score")
#Calculates score for each legislator and each issue
apply(legislator_table, 1, score_legislator)

dbDisconnect(con)