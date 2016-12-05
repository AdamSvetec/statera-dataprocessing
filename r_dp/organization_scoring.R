#Scores each organization on each issue according to their contribution history
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(),group="data-processing")

#Get list of all organization's id's
organizations <- dbGetQuery(con, paste("SELECT Id FROM ",ORG_TBL_NAME,";",sep=""))
#Get list of all issues to analyze
issue_ids <- dbGetQuery(con, paste("SELECT Id FROM ",ISSUE_TBL_NAME," GROUP BY Id",sep=""))

#Generates a score for a given organization and issue
generate_score <- function(organization_id, issue_id){
  #Need lean of each politician they contributed to on this specific issue
  leans <- dbGetQuery(con, paste(
    "SELECT amount, score
    FROM ",INDIV_TO_POL_TBL_NAME,", ",LEG_SCORE_TBL_NAME,"
    WHERE ",INDIV_TO_POL_TBL_NAME,".org_id = ",organization_id," AND ",LEG_SCORE_TBL_NAME,".issue_id = ",issue_id," AND ",INDIV_TO_POL_TBL_NAME,".pol_id = ",LEG_SCORE_TBL_NAME,".leg_id;",
    sep=""))
  if(nrow(leans) == 0){
    return(0)
  }
  total_lean <- 0
  total_contributions <- 0
  for(i in 1:nrow(leans)){
    amount <- leans[i,'amount']
    lean <- leans[i,'score']
    total_lean <- total_lean + (lean*amount)
    total_contributions <- total_contributions + amount
  }
  return(total_lean / total_contributions)
}

#Scores a given organization
score_organization <- function(count){
  org_scores <- data.frame("org_id"=numeric(),"issue_id"=numeric(),"score"=numeric(), stringsAsFactors=FALSE)
  #For each issue we calculate a score using the generate_score function
  for(issue_id in issue_ids$Id){
    org_scores[nrow(org_scores)+1,"org_id"] <- organizations[count,'Id']
    org_scores[nrow(org_scores),"issue_id"] <- issue_id
    org_scores[nrow(org_scores),"score"] <- generate_score(organizations[count,'Id'], issue_id)
  }
  ignore <- dbWriteTable(conn=con, name=ORG_SCORE_TBL_NAME, value=org_scores, row.names = FALSE, overwrite = FALSE, append = TRUE)
  progress(count, org_count)
}

#Delete the table before recalculating scores
ignore <- dbRemoveTable(con, name=ORG_SCORE_TBL_NAME)
org_count <- nrow(organizations)
#For each organization, pass this row to score_organization()
ignore <- sapply(1:org_count, score_organization)

ignore <- dbDisconnect(con)