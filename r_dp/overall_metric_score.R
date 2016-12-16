#Get Final Metrics on analysis
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), group="data-processing")

#Get's a list of all issues
issues <- dbGetQuery(con, paste("SELECT * FROM ",ISSUE_TBL,";",sep=""))

dp_log("Metric results")

issue_results <- data.frame()
for(i in 1:nrow(issues)){
  issue <- issues[i,]
  results <- dbGetQuery(con, paste("select AVG(score) as average, STDDEV(score) as stddev from ",ORG_SCORE_TBL," where issue_id = ",issue['Id'],";",sep=""))
  issue_results[nrow(issue_results)+1,'issue_id'] <- issue$Id;
  issue_results[nrow(issue_results),'avg_score'] <- results$average;
  issue_results[nrow(issue_results),'stddev_score'] <- results$stddev;
  issue_results[nrow(issue_results),'date'] <- Sys.Date()
  print(paste("Issue: ",issue['issue_shortname']," | avg score: ",results$average," | std dev: ",results$stddev))
  dp_log(paste("Issue: ",issue['issue_shortname']," | avg score: ",results$average," | std dev: ",results$stddev))
}

ignore <- dbWriteTable(con, name=METRIC_RESULTS_TBL, value=issue_results, append=TRUE,row.names=FALSE)

ignore <- dbDisconnect(con)
