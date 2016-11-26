#Data upload for legislator data from govTrack
#Standard Environment cleansing
rm(list=ls())
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

#Convert birthday strings to dates and remove all legislators born earlier than 1900
legislators <- legislators[legislators$opensecrets_id != "",]
#legislators$birthday <- as.Date(legislators$birthday)
#legislators <- legislators[!is.na(legislators$birthday),]
#years <- as.numeric(format(legislators$birthday, "%Y"))
#legislators <- legislators[years > 1900,]

#tail(legislators, 5)

library(RMySQL)

#Upload legislators table to database
con <- dbConnect(RMySQL::MySQL(), group="data-processing")
dbWriteTable(conn=con, name="legislator_govtrack", value=legislators, row.names = FALSE, overwrite = TRUE)
dbDisconnect(con)

