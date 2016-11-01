#Data upload for legislator data

#Parse command line arguments to get filepath of legislators-historic.csv
args = commandArgs(trailingOnly=TRUE)
if(length(args) != 1){
  stop("Filename of legislator data must be provided")
}
filename = args[1]

#Read in legislators table from file
legislators = read.table(filename, header = TRUE, sep = ",", fill=TRUE)

#Remove all unused columns
legislators$url <- NULL
legislators$address <- NULL
legislators$phone <- NULL
legislators$contact_form <- NULL
legislators$rss_url <- NULL
legislators$twitter <- NULL
legislators$facebook <- NULL
legislators$facebook_id <- NULL
legislators$youtube <- NULL
legislators$youtube_id <- NULL
legislators$bioguide_id <- NULL
legislators$thomas_id <- NULL
legislators$lis_id <- NULL
legislators$cspan_id <- NULL
legislators$votesmart_id <- NULL
legislators$ballotpedia_id <- NULL
legislators$washington_post_id <- NULL
legislators$icpsr_id <- NULL
legislators$wikipedia_id <- NULL

#Convert birthday strings to dates and remove all legislators born earlier than 1900
legislators$birthday <- as.Date(legislators$birthday)
legislators <- legislators[!is.na(legislators$birthday),]
years <- as.numeric(format(legislators$birthday, "%Y"))
legislators <- legislators[years > 1900,]

#tail(legislators, 5)
