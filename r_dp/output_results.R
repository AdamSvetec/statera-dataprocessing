#Takes each organization and creates a csv file holding all of the results of the analysis
#Standard Environment cleansing
rm(list=ls())
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
organizations <- dbGetQuery(con, "SELECT Id, Orgname, total_amount, total_contr FROM organization;")
#Get a list of issue's ids and names
issues <- dbGetQuery(con, "SELECT issue_shortname, Id FROM issue;")

#Open connection to file
outputFileConn<-file(filename, "w")

#Print header to output file
cat(paste("Organization","Total Contributions", "Total Number of Contributions","",sep=", "), file=outputFileConn, append=FALSE)
cat(paste(issues[,"issue_shortname"], collapse=", "), file=outputFileConn, append=TRUE)
cat("\n", file=outputFileConn, append=TRUE)

#For each organization, gather their scores and print them to the file
#Scores a given organization
print_organization <- function(organization, filename){
  organization_name <- paste("\"", organization['Orgname'], "\"", sep="")
  cat(paste(organization_name,organization['total_amount'],organization['total_contr'],"", sep=", "), file=outputFileConn, append=TRUE)
  scores <- dbGetQuery(con, paste(
    "SELECT score
    FROM org_score
    WHERE org_score.org_id = ",organization['Id']," 
    ORDER BY org_score.issue_id;",
    sep=""))
  scores_v <- unlist(scores, recursive = FALSE, use.names = FALSE)
  cat(paste(scores_v, collapse=", "), file=outputFileConn, append=TRUE)
  cat("\n", file=outputFileConn, append=TRUE)
}

#For each organization, pass this row to score_organization()
apply(organizations, 1, print_organization, filename)

close(outputFileConn)
dbDisconnect(con)