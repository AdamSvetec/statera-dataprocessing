#Merge of legislator data coming from OpenSecrets and govTrack
#Standard Environment cleansing
rm(list=ls())
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), group="data-processing")
#Names of each table:
leg_opensecrets_db <- "legislator_opensecrets"
leg_govtrack_db <- "legislator_govtrack"
leg_final_db <- "legislator"

#Read both tables from database
#leg_opensecrets <- dbReadTable(con, name=leg_opensecrets_db)
#leg_govtrack <- dbReadTable(con, name=leg_govtrack_db)

#Because opensecrets id's are stored for a large chunk of govTrack legislators, just migrate table for now, may need modification in the future
dbSendStatement(con, paste("RENAME TABLE ",leg_govtrack_db," TO ",leg_final_db, sep=""))
dbRemoveTable(con, name=leg_opensecrets_db)

dbDisconnect(con)