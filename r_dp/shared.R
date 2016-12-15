#File for sharing variables, tablenames, etc. between scripts
DB_GROUP = 'data-processing'

ORG_TBL = 'organization'
CONTR_TBL = 'contribution'
ISSUE_TBL = 'issue'
LEG_GOVTRACK_TBL = 'legislator_govtrack'
LEG_OPENSECRETS_TBL = 'legislator_opensecrets'
LEG_FINAL_TBL = 'legislator'
BILL_TBL = 'bill'
VOTE_TBL = 'vote'
BILL_SCORE_TBL = 'bill_score'
LEG_SCORE_TBL = 'legislator_score'
ORG_SCORE_TBL = 'org_score'
ORG_SCORE_FINAL_TBL = 'final_org_results'
METRIC_RESULTS_TBL = 'metric_result'

data_path = '/home/ubuntu/BulkData/'
source_path = '/home/ubuntu/379SeniorProject/'
log_file = paste(source_path,'log/data_processing.log',sep="")

#Prints string given to it with ending newline and numbers expressed without e notation
status <- function(str){
  options(scipen=10)
  cat(paste(str,"\n"))
  options(scipen=0)
}

#Prints the current progress of a function to output
progress <- function (current, max = 100) {
  percent <- current / max * 100
  cat(sprintf('\r[%-50s] %d%%',
              paste(rep('=', percent / 2), collapse = ''),
              floor(percent)))
  if (current >= max)
    cat('\n')
}

dp_log <- function (str){
  #file.create(log_file, showWarnings = TRUE, overwrite=FALSE)
  write(paste(format(Sys.time(), "%a %b %d %X %Y")," | ",str), file = log_file, append = TRUE)
}