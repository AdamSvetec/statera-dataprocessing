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

#Importing legislator data
#See https://www.opensecrets.org/resources/datadictionary/Data%20Dictionary%20Candidates%20Data.htm 
#for specific data dictionary definitions.
leg.col.names = c('Cycle', 'FECCandID', 'CID', 'FirstLastP', 'Party', 'DistIDRunFor', 'DistIDCurr', 'CurrCand', 'CycleCand', 'CRPICO', 'RecipCode', 'NoPacs')
legislators <- read.table(legislators_file, header=FALSE, sep=",", quote = '|', fill=TRUE, stringsAsFactors = FALSE, col.names = leg.col.names)
legislators <- subset(legislators, select = c('Cycle', 'CID', 'FirstLastP', 'Party', 'DistIDCurr'))

#Upload legislators table to database
ignore<-dbWriteTable(conn=con, name=LEG_OPENSECRETS_TBL_NAME, value=legislators, row.names = FALSE, overwrite = TRUE)
rm(legislators)

#Because of enourmous file size, these operations on indivs16.txt is being moved entirely to SQL

#Importing contributions of individuals to candidates
#setwd("~/379SeniorProject/r_dp/")
#output <- scan(pipe(paste("../db_utils/indivs_read.sql")), what=list(0, NULL))[[1]]
#setwd(foldername)
#INDIV_TO_POL_RAW_TBL_NAME = 'indiv_to_pol_raw' #Exists just for the lifetime of this script
#ignore<-dbRemoveTable(conn=con, name=INDIV_TO_POL_RAW_TBL_NAME)
#See https://www.opensecrets.org/resources/datadictionary/Data%20Dictionary%20for%20Individual%20Contribution%20Data.htm
#for specific data dictionary definitions.
#indiv.col.names = c('Cycle','FECTransID','ContribID','Contrib','RecipID','Orgname','UltOrg','RealCode','Date','Amount','Street','City','State','Zip','RecipCode','Type','CmteID','OtherID','Gender','Microfilm','Occupation','Employer','Source')
#indiv.ignore.cols = c("NULL","NULL",NA,NA,NA,NA,NA,"NULL","NULL",NA,"NULL","NULL","NULL","NULL",NA,"NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL")
#Because of the enormous size of the file we need to read it in chunk by chunk and filter
#num_lines <- scan(pipe(paste("wc -l",individual_to_cand_file)), what=list(0, NULL))[[1]]
#num_lines <- 1000000
#num_per_read <- 50000
#skipped_groups <- c("Retired", "[Candidate Contribution]", "", "[24T Contribution]", "Investor")
#contribution_threshold <- 100000
#status(paste("Uploading ",num_lines," contributions"))
#sql_statement <- paste("SELECT RecipID, Orgname, Amount FROM file WHERE RecipID NOT LIKE \"C%\" AND Amount > ",contribution_threshold,";",sep="")
#field_types <- list('Cycle'="VARCHAR(10)",'FECTransID'="VARCHAR(10)",'ContribID'="VARCHAR(10)",'Contrib'="VARCHAR(10)",'RecipID'="VARCHAR(10)",'Orgname'="VARCHAR(10)",'UltOrg'="VARCHAR(10)",'RealCode'="VARCHAR(10)",'Date'="VARCHAR(10)",'Amount'="VARCHAR(10)",'Street'="VARCHAR(10)",'City'="VARCHAR(10)",'State'="VARCHAR(10)",'Zip'="VARCHAR(10)",'RecipCode'="VARCHAR(10)",'Type'="VARCHAR(10)",'CmteID'="VARCHAR(10)",'OtherID'="VARCHAR(10)",'Gender'="VARCHAR(10)",'Microfilm'="VARCHAR(10)",'Occupation'="VARCHAR(10)",'Employer'="VARCHAR(10)",'Source'="VARCHAR(10)")
#indiv_contributions_append <- read.csv.sql(individual_to_cand_file, sql=sql_statement, header=FALSE, colClasses=indiv.ignore.cols, field.types=field_types, sep=",")
#i <- 0
#while(i < num_lines){
#  indiv_contributions_append <- read.table(individual_to_cand_file, header=FALSE, sep=',', quote='|', stringsAsFactors = FALSE, col.names=indiv.col.names, colClasses=indiv.ignore.cols, nrows=num_per_read, skip=i)
#  indiv_contributions_append <- indiv_contributions_append[substring(indiv_contributions_append$RecipID, first=1,last=1) != 'C',] #Remove contributions to committees
#  indiv_contributions_append <- indiv_contributions_append[indiv_contributions_append$Amount >= contribution_threshold,] #Remove any contributions below the threshold
#  indiv_contributions_append <- indiv_contributions_append[!(indiv_contributions_append$Orgname %in% skipped_groups),] #Remove any contributions from groups we have determined to skip
#  ignore<-dbWriteTable(conn=con, name=INDIV_TO_POL_RAW_TBL_NAME, value=indiv_contributions_append, row.names = FALSE, overwrite = FALSE, append = TRUE)
#  rm(indiv_contributions_append)
#  i = i + num_per_read
#  progress(i, num_lines)
#}

#Group by organization and create new table with each corporation
#Will store total contribution
#ignore<-dbRemoveTable(conn=con, name=ORG_TBL_NAME)
#ignore<-dbSendStatement(con, paste("CREATE TABLE ",ORG_TBL_NAME," ( Orgname VARCHAR(30), total_amount NUMERIC(12), total_contr NUMERIC(10));",sep=""))
#ignore<-dbSendStatement(con, paste("INSERT INTO ",ORG_TBL_NAME," SELECT Orgname, SUM(Amount), COUNT(contribID) FROM ",INDIV_TO_POL_RAW_TBL_NAME," GROUP BY Orgname;",sep=""))
#ignore<-dbSendStatement(con, paste("ALTER TABLE ",ORG_TBL_NAME," ADD Id INT AUTO_INCREMENT PRIMARY KEY;",sep=""))

#Pull out individual contributions and create table between organization and politician
#ignore<-dbRemoveTable(conn=con, name=INDIV_TO_POL_TBL_NAME)
#ignore<-dbSendStatement(con, paste("CREATE TABLE ",INDIV_TO_POL_TBL_NAME," ( org_id INT NOT NULL, pol_id VARCHAR(9) NOT NULL, amount NUMERIC(10));",sep=""))
#ignore<-dbSendStatement(con, paste("INSERT INTO ",INDIV_TO_POL_TBL_NAME," SELECT organization.Id, RecipID, Amount FROM organization, ",INDIV_TO_POL_RAW_TBL_NAME," WHERE organization.Orgname = ",INDIV_TO_POL_RAW_TBL_NAME,".Orgname;",sep=""))
#ignore<-dbRemoveTable(conn=con, name=INDIV_TO_POL_RAW_TBL_NAME)

ignore <- dbDisconnect(con)
