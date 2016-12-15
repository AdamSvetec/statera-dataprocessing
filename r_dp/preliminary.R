#Perform preliminary check on data
#Standard Environment cleansing
rm(list=ls())
#Include shared header
source("~/379SeniorProject/r_dp/shared.R")

dp_log("Beginning Data Processing Run")

file_info <- file.info(paste(data_path,"legislators-historic.csv",sep=""), extra_cols = TRUE)
dp_log(paste("govtrack data last uploaded at : ",file_info[1,'mtime'],sep=""))

file_info <- file.info(paste(data_path,"CampaignFin16/indivs_test.txt",sep=""), extra_cols = TRUE)
dp_log(paste("OpenSecrets data last uploaded at : ",file_info[1,'mtime'],sep=""))
