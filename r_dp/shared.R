#File for sharing variables, tablenames, etc. between scripts

ORG_TBL_NAME = 'organization'
INDIV_TO_POL_TBL_NAME = 'indiv_to_pol'
ISSUE_TBL_NAME = 'issue'
LEG_GOVTRACK_TBL_NAME = 'legislator_govtrack'
LEG_OPENSECRETS_TBL_NAME = 'legislator_opensecrets'
LEG_FINAL_TBL_NAME = 'legislator'
BILL_TBL_NAME = 'bill'
VOTE_TBL_NAME = 'vote'
BILL_SCORE_TBL_NAME = 'bill_score'
LEG_SCORE_TBL_NAME = 'legislator_score'
ORG_SCORE_TBL_NAME = 'organization_score'
ORG_SCORE_FINAL_TBL_NAME = 'final_org_results'

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