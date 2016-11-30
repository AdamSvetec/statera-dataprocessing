#Scores each legislator on each issue according to their voting history
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(),group="data-processing")

#Get's a list of all legislator id's to score
legislator_table <- dbGetQuery(con, paste("SELECT bioguide_id, opensecrets_id FROM ",LEG_FINAL_TBL_NAME,";",sep=""))
#Get's a list of all issue id's
issue_ids <- dbGetQuery(con, paste("SELECT Id FROM ",ISSUE_TBL_NAME," GROUP BY Id",sep=""))

#Generates a score for a given legislator and issue
generate_score <- function(legislator_id, issue_id){
  #Need lean of each bill they voted on and how they voted
  #TODO: can this be optimized better?
  leans <- dbGetQuery(con, paste(
    "SELECT y_or_no, score
    FROM ",VOTE_TBL_NAME,", ",BILL_SCORE_TBL_NAME,"
    WHERE ",VOTE_TBL_NAME,".pol_id = \"",legislator_id,"\" AND ",VOTE_TBL_NAME,".bill_id = ",BILL_SCORE_TBL_NAME,".bill_id AND ",BILL_SCORE_TBL_NAME,".issue_id = ",issue_id," AND EXISTS (
	    SELECT *
	    FROM ",BILL_TBL_NAME,"
	    where ",BILL_TBL_NAME,".vote_id = ",VOTE_TBL_NAME,".bill_id);",sep=""))
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
score_legislator <- function(counter){
  legislator <- legislator_table[counter,]
  leg_scores <- data.frame("leg_id"=character(),"issue_id"=numeric(),"score"=numeric(), stringsAsFactors=FALSE)
  for(issue_id in issue_ids$Id){
    leg_scores[nrow(leg_scores)+1,"leg_id"] <- legislator['opensecrets_id']
    leg_scores[nrow(leg_scores),"issue_id"] <- issue_id
    leg_scores[nrow(leg_scores),"score"] <- generate_score(legislator['bioguide_id'], issue_id)
  }
  ignore <- dbWriteTable(conn=con, name=LEG_SCORE_TBL_NAME, value=leg_scores, row.names = FALSE, overwrite = FALSE, append = TRUE)
  progress(counter, legislator_count)
}

#Removes the table from the database before recalculating
ignore<-dbRemoveTable(con, name=LEG_SCORE_TBL_NAME)
legislator_count <- nrow(legislator_table)
status(paste("Scoring",legislator_count,"legislators"))
#Calculates score for each legislator and each issue
ignore <- sapply(1:legislator_count, score_legislator)

ignore <- dbDisconnect(con)