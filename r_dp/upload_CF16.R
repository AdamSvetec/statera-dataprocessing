#Upload contribution information for each candidate
#Standard Environment cleansing
rm(list=ls())
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
dbWriteTable(conn=con, name="legislator_opensecrets", value=legislators, row.names = FALSE, overwrite = TRUE)
rm(legislators)

#Importing contributions of individuals to candidates
dbRemoveTable(conn=con, name="indiv_to_pol_raw")
#See https://www.opensecrets.org/resources/datadictionary/Data%20Dictionary%20for%20Individual%20Contribution%20Data.htm
#for specific data dictionary definitions.
indiv.col.names = c('Cycle','FECTransID','ContribID','Contrib','RecipID','Orgname','UltOrg','RealCode','Date','Amount','Street','City','State','Zip','RecipCode','Type','CmteID','OtherID','Gender','Microfilm','Occupation','Employer','Source')
indiv.ignore.cols = c("NULL","NULL",NA,NA,NA,NA,NA,"NULL","NULL",NA,"NULL","NULL","NULL","NULL",NA,"NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL")
#Because of the enormous size of the file we need to read it in chunk by chunk and filter
#num_lines <- scan(pipe(paste("wc -l",individual_to_cand_file)), what=list(0, NULL))[[1]]
num_lines <- 1000000
num_per_read <- 50000
skipped_groups <- c("Retired", "[Candidate Contribution]", "", "[24T Contribution]", "Investor")
contribution_threshold <- 5000
i <- 0
while(i < num_lines){
  indiv_contributions_append <- read.table(individual_to_cand_file, header=FALSE, sep=',', quote='|', stringsAsFactors = FALSE, col.names=indiv.col.names, colClasses=indiv.ignore.cols, nrows=num_per_read, skip=i)
  indiv_contributions_append <- indiv_contributions_append[substring(indiv_contributions_append$RecipID, first=1,last=1) != 'C',] #Remove contributions to committees
  indiv_contributions_append <- indiv_contributions_append[indiv_contributions_append$Amount >= contribution_threshold,] #Remove any contributions below the threshold
  indiv_contributions_append <- indiv_contributions_append[!(indiv_contributions_append$Orgname %in% skipped_groups),] #Remove any contributions from groups we have determined to skip
  dbWriteTable(conn=con, name="indiv_to_pol_raw", value=indiv_contributions_append, row.names = FALSE, overwrite = FALSE, append = TRUE)
  rm(indiv_contributions_append)
  i = i + num_per_read
  print(paste("Number read: ",i))
}

#Group by organization and create new table with each corporation
#Will store total contribution
dbRemoveTable(conn=con, name="organization")
dbSendQuery(con, "create table organization( Orgname varchar(30), total_amount numeric(12), total_contr numeric(10));")
dbSendQuery(con, "insert into organization select Orgname, sum(Amount), count(contribID) from indiv_to_pol_raw group by Orgname;")
dbSendQuery(con, "alter table organization add Id int auto_increment primary key;")

#Pull out individual contributions and create table between organization and politician
dbRemoveTable(conn=con, name="indiv_to_pol")
dbSendQuery(con, "create table indiv_to_pol( org_id int NOT NULL, pol_id varchar(9) NOT NULL, amount numeric(10));")
dbSendQuery(con, "insert into indiv_to_pol select organization.Id, RecipID, Amount from organization, indiv_to_pol_raw where organization.Orgname = indiv_to_pol_raw.Orgname;")

dbDisconnect(con)
#For Fun: find politicians that have recieved money from Hallmark Cards pac
#fecCommittees$RecipId <- factor(fecCommittees$RecipID)
#HCRecipID <- fecCommittees[1, 6]
#politicians[which(politicians$CID == min(HCRecipID)), ]