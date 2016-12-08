#Merge of legislator data coming from OpenSecrets and govTrack
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), group="data-processing")

#Read both tables from database
#leg_opensecrets <- dbReadTable(con, name=leg_opensecrets_db)
#leg_govtrack <- dbReadTable(con, name=leg_govtrack_db)

#Because opensecrets id's are stored for a large chunk of govTrack legislators, just migrate table for now, may need modification in the future
ignore <- dbRemoveTable(con, name=LEG_FINAL_TBL)
#Remove all legislators from govtrack data that do not have an opensecrets id
ignore <- dbSendStatement(con, paste("DELETE FROM ",LEG_GOVTRACK_TBL," WHERE opensecrets_id = \"\";",sep=""))
ignore <- dbSendStatement(con, paste("RENAME TABLE ",LEG_GOVTRACK_TBL," TO ",LEG_FINAL_TBL,";", sep=""))
ignore <- dbRemoveTable(con, name=LEG_OPENSECRETS_TBL)

ignore <- dbDisconnect(con)