#Data upload for legislator data

#Parse command line arguments to get filepath of legislators-historic.csv
args = commandArgs(trailingOnly=TRUE)
filename = '~/BulkData/legislators-historic.csv'
if(length(args) > 0){
  filename = args[1]
}

#Read in legislators table from file
legislators = read.table(filename, header = TRUE, sep = ",", fill=TRUE, stringsAsFactors = FALSE)

#Remove all unused columns
legislators = subset(legislators, select = c(last_name, first_name, birthday, gender, type, state, district, party, govtrack_id, bioguide_id))

#Convert birthday strings to dates and remove all legislators born earlier than 1900
legislators$birthday <- as.Date(legislators$birthday)
legislators <- legislators[!is.na(legislators$birthday),]
years <- as.numeric(format(legislators$birthday, "%Y"))
legislators <- legislators[years > 1900,]

#tail(legislators, 5)

library(RMySQL)

#Testing functionality on 'test' database. works, now need to implement for actual dataprocessing database 
con <- dbConnect(RMySQL::MySQL(), group="data-processing")
dbWriteTable(conn=con, name="legislator", value=legislators, row.names = FALSE, overwrite = TRUE)
dbDisconnect(con)

