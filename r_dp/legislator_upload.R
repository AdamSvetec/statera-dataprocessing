#Data upload for legislator data from govTrack
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), group="data-processing")
#Will use file specified in command line arguments or will use default:
filename = '~/BulkData/legislators-historic.csv'

#Parse command line arguments to get filepath of legislators-historic.csv
args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
  filename = args[1]
}

#Read in legislators table from file
legislators = read.table(filename, header=TRUE, sep=",", quote="\"", fill=TRUE, stringsAsFactors=FALSE)

#Remove all unused columns
legislators = subset(legislators, select = c(last_name, first_name, birthday, gender, type, state, district, party, bioguide_id, opensecrets_id))

#Remove all legislators that do not have an opensecrets id
#legislators <- legislators[legislators$opensecrets_id != "",]

#Upload legislators table to database
ignore <- dbWriteTable(conn=con, name=LEG_GOVTRACK_TBL_NAME, value=legislators, row.names = FALSE, overwrite = TRUE)

ignore <- dbDisconnect(con)