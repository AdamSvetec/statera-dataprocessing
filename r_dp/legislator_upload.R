#Data upload for legislator data from govTrack
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), group="data-processing")
#Will use folder specified in command line arguments or will use default:
foldername = '~/BulkData/'
filename_hist = 'legislators-historic.csv'
filename_curr = 'legislators-current.csv'
#Parse command line arguments to get filepath of legislators-historic.csv
args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
  foldername = args[1]
}
setwd(foldername)

#Read in legislators table from file
legislators_historic = read.table(filename_hist, header=TRUE, sep=",", quote="\"", fill=TRUE, stringsAsFactors=FALSE)
legislators_current = read.table(filename_curr, header=TRUE, sep=",", quote="\"", fill=TRUE, stringsAsFactors=FALSE)
#Remove all unused columns
filter = c('last_name', 'first_name', 'birthday', 'gender', 'type', 'state', 'district', 'party', 'bioguide_id', 'opensecrets_id')
legislators_historic = subset(legislators_historic, select = filter)
legislators_current = subset(legislators_current, select = filter)

#Remove people without opensecrets_id
legislators_historic = legislators_historic[legislators_historic$opensecrets_id != "",]

#Upload legislators table to database
ignore <- dbWriteTable(conn=con, name=LEG_GOVTRACK_TBL, value=legislators_historic, row.names=FALSE, overwrite=TRUE)
ignore <- dbWriteTable(conn=con, name=LEG_GOVTRACK_TBL, value=legislators_current, row.names=FALSE, overwrite=FALSE, append=TRUE)
ignore <- dbDisconnect(con)