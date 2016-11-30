#Takes each organization and creates a csv file holding all of the results of the analysis
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(),group="data-processing")
#Will upload to filepath specified in command line arguments or will use:
filename = '~/BulkData/results.csv'
#Parse command line arguments to get filepath of bill scores
args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
  filename = args[1]
}

#Get list of organization's names and their id's
organizations <- dbGetQuery(con, "SELECT Id, Orgname, total_amount, total_contr FROM ",ORG_TBL_NAME,";")
#Get a list of issue's ids and names
issues <- dbGetQuery(con, "SELECT issue_shortname, Id FROM ",ISSUE_TBL_NAME,";")

#Open connection to file
outputFileConn<-file(filename, "w")

#Print header to output file
cat(paste("Organization","Total Contributions", "Total Number of Contributions","",sep=", "), file=outputFileConn, append=FALSE)
cat(paste(issues[,"issue_shortname"], collapse=", "), file=outputFileConn, append=TRUE)
cat("\n", file=outputFileConn, append=TRUE)

#For a given organization, gather their scores and print them to the file
print_organization <- function(organization, filename){
  organization_name <- paste("\"", organization['Orgname'], "\"", sep="")
  cat(paste(organization_name,organization['total_amount'],organization['total_contr'],"", sep=", "), file=outputFileConn, append=TRUE)
  scores <- dbGetQuery(con, paste(
    "SELECT score
    FROM ",ORG_SCORE_TBL_NAME,"
    WHERE org_id = ",organization['Id']," 
    ORDER BY issue_id;",
    sep=""))
  scores_v <- unlist(scores, recursive = FALSE, use.names = FALSE)
  cat(paste(scores_v, collapse=", "), file=outputFileConn, append=TRUE)
  cat("\n", file=outputFileConn, append=TRUE)
}

#For each organization, pass this row to score_organization function
ignore <- apply(organizations, 1, print_organization, filename)
close(outputFileConn)

#Takes each organization and creates a single table with organization and scoring information
merge_orgs_and_scores <- function(org){
  org_score <- list()
  scores <- dbGetQuery(con, paste(
    "SELECT score, issue_id
    FROM ",ORG_SCORE_TBL_NAME,"
    WHERE org_id = ",org['Id'],";",
    sep=""))
  org_score['orgname'] <- org['Orgname']
  org_score['total_contributions'] <- org['total_amount']
  org_score['total_contr_number'] <- org['total_contr']
  for(i in 1:nrow(scores)){
    org_score[paste('issue_',scores[i,'issue_id'],sep="")] <- scores[i,'score']
  }
  org_score_tbl <- data.frame(org_score)
  ignore <- dbWriteTable(con, name=ORG_SCORE_FINAL_TBL_NAME, value=org_score_tbl, row.names = FALSE, overwrite = FALSE, append = TRUE)
}

#Create a new table with final results stored in a single table
ignore <- dbRemoveTable(con, name=ORG_SCORE_FINAL_TBL_NAME)
ignore <- apply(organizations, 1, merge_orgs_and_scores)

ignore <- dbDisconnect(con)