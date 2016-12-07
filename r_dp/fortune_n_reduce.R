#Reduce Organization List to Companies contained in fortune n
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")
#Connect to processing database and close connection on exit
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), group="data-processing")
filename = '~/BulkData/fortune_500.csv'
#Parse command line arguments to get filepath of fortune
args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
  filename = args[1]
}

#Replace orgnames with updated ones
file_conn <- file(filename,open="r")
lines <-readLines(file_conn)
org_names = data.frame()
close(file_conn)
status(paste("Slimming organizations to ",length(lines)," count"))
for(i in 1:length(lines)){
  names <- unlist(strsplit(lines[i], split=","))
  org_names[nrow(org_names)+1,'Orgname'] <- trimws(names[1])
  for(j in 2:length(names)){
    ignore <- dbSendStatement(con, paste("UPDATE ",INDIV_TO_POL_TBL_NAME,"
                                          SET Orgname = \"",trimws(names[1]),"\"
                                          WHERE Orgname = \"",trimws(names[j]),"\";",sep=""))
  }
  progress(i,2*length(lines))
}

#Remove all organizations that are not in list
ignore <- dbWriteTable(con, name="temp_org_names", value=org_names, row.names=FALSE, overwrite=TRUE)
ignore <- dbSendStatement(con, paste("DELETE FROM ",INDIV_TO_POL_TBL_NAME,"
                                      WHERE Orgname NOT IN (SELECT Orgname FROM temp_org_names);",sep=""))
ignore <- dbRemoveTable(con, name="temp_org_names")
progress(75,100)
ignore <- dbRemoveTable(con, name=ORG_TBL_NAME)
ignore <- dbSendStatement(con, paste("CREATE TABLE ",ORG_TBL_NAME," ( 
                                      Orgname VARCHAR(30), 
                                      total_amount NUMERIC(12), 
                                      total_contr NUMERIC(10));",sep=""))
ignore <- dbSendStatement(con, paste("INSERT INTO ",ORG_TBL_NAME," 
                            SELECT orgname, SUM(Amount), COUNT(*) 
                            FROM ",INDIV_TO_POL_TBL_NAME," 
                            GROUP BY orgname;",sep=""))
ignore <- dbSendStatement(con, paste("ALTER TABLE ",ORG_TBL_NAME," ADD Id INT AUTO_INCREMENT PRIMARY KEY;",sep=""))
progress(85,100)
ignore <- dbSendStatement(con, paste("UPDATE ",INDIV_TO_POL_TBL_NAME,"                                                                       
                                      SET org_id = (SELECT Id                                                                            
                                      FROM ",ORG_TBL_NAME,"                                                                     
                                      WHERE ",ORG_TBL_NAME,".Orgname = ",INDIV_TO_POL_TBL_NAME,".orgname);",sep=""))
ignore <- dbSendStatement(con, paste("ALTER TABLE ",INDIV_TO_POL_TBL_NAME," DROP COLUMN orgname;"))
progress(100,100)

ignore <- dbDisconnect(con)
