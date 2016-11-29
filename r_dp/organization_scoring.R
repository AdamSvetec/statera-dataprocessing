#Scores each organization on each issue according to their contribution history
#Standard Environment cleansing
rm(list=ls())
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(),group="data-processing")

#Get list of all organization's id's
organizations <- dbGetQuery(con, "SELECT Id FROM organization;")
#Get list of all issues to analyze
issue_ids <- dbGetQuery(con, "SELECT Id FROM issue GROUP BY Id")

#Generates a score for a given organization and issue
generate_score <- function(organization_id, issue_id){
  #Need lean of each politician they contributed to on this specific issue
  leans <- dbGetQuery(con, paste(
    "SELECT amount, score
    FROM indiv_to_pol, pol_score
    WHERE indiv_to_pol.org_id = ",organization_id," AND pol_score.issue_id = ",issue_id," AND indiv_to_pol.pol_id = pol_score.leg_id;",
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
score_organization <- function(organization){
  org_scores <- data.frame("org_id"=numeric(),"issue_id"=numeric(),"score"=numeric(), stringsAsFactors=FALSE)
  #For each issue we calculate a score using the generate_score function
  for(issue_id in issue_ids$Id){
    org_scores[nrow(org_scores)+1,"org_id"] <- organization['Id']
    org_scores[nrow(org_scores),"issue_id"] <- issue_id
    org_scores[nrow(org_scores),"score"] <- generate_score(organization['Id'], issue_id)
  }
  dbWriteTable(conn=con, name="org_score", value=org_scores, row.names = FALSE, overwrite = FALSE, append = TRUE)
}

#Delete the table before recalculating scores
dbRemoveTable(con, name="org_score")
#For each organization, pass this row to score_organization()
apply(organizations, 1, score_organization)

dbDisconnect(con)