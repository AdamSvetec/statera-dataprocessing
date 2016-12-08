#Upload contribution information for each candidate
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), group="data-processing")
#Will use directory specified in command line arguments or will use:
foldername = '~/BulkData/CampaignFin16/'
#Will read all data files specified by:
legislators_file <- 'cands16.txt'
fec_committees_file <- 'cmtes16.txt'
pac_to_cand_file <- 'pacs16.txt'
pac_to_pac_file <- 'pac_other16.txt'
individual_to_cand_file <- 'indivs16.txt'

args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
  foldername = args[1]
}
setwd(foldername)

sql_script_file = '~/379SeniorProject/db_utils/indivs_read.sql'

#Importing legislator data
#See https://www.opensecrets.org/resources/datadictionary/Data%20Dictionary%20Candidates%20Data.htm 
#for specific data dictionary definitions.
leg.col.names = c('Cycle', 'FECCandID', 'CID', 'FirstLastP', 'Party', 'DistIDRunFor', 'DistIDCurr', 'CurrCand', 'CycleCand', 'CRPICO', 'RecipCode', 'NoPacs')
legislators <- read.table(legislators_file, header=FALSE, sep=",", quote = '|', fill=TRUE, stringsAsFactors = FALSE, col.names = leg.col.names)
legislators <- subset(legislators, select = c('Cycle', 'CID', 'FirstLastP', 'Party', 'DistIDRunFor'))

#Upload legislators table to database
ignore<-dbWriteTable(conn=con, name=LEG_OPENSECRETS_TBL, value=legislators, row.names = FALSE, overwrite = TRUE)
rm(legislators)

#Because of enourmous file size, these operations on indivs16.txt are done entirely in SQL

ignore <- dbDisconnect(con)
