#Normalizes the organization scores
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(),group="data-processing")

org_scores <- dbReadTable(con, name=ORG_SCORE_TBL)
avg_org_score_pos <- dbGetQuery(con, paste("SELECT AVG(score) as avg from org_score where score > 0;"))['avg']
avg_org_score_neg <- dbGetQuery(con, paste("SELECT AVG(score) as avg from org_score where score < 0;"))['avg']
avg_org_score <- max(avg_org_score_neg*-1, avg_org_score_pos)

for(i in 1:nrow(org_scores)){
  new_org_score <- org_scores[i,'score']/(2*avg_org_score)
}

ignore <- dbDisconnect(con)