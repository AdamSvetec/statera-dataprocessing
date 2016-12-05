#!/bin/bash

#Script for end to end data run
data_folder="~/BulkData/"
legislator_file="legislators-historic.csv"
bill_scores_file="bill_scores.csv"
issues_file="issues.csv"
votes_folder="votes/"
cf16_folder="CampaignFin16/"
r_command="R --vanilla -q --slave -f"
r_script_folder="../r_dp/"

read -s -p "Please enter password: " local_pass
echo ""
echo "Begining end to end data processing run..."

#Data Upload
echo "Begining data upload"
echo "Uploading user defined issues"
$r_command $r_script_folder"issues_upload.R"
echo "Uploading legislators from govtrack"
$r_command $r_script_folder"legislator_upload.R"
echo "Uploading opensecrets legislator data" 
$r_command $r_script_folder"upload_CF16.R"
echo "Uploading opensecrets contribution data"
sudo mysql --password=$local_pass --verbose dataprocessing < ../db_utils/indivs_read.sql
echo "Uploading govtrack voting records"
$r_command $r_script_folder"voting_upload.R"

#Filter out companies not in fortune 500
$r_command $r_script_folder"fortune_n_reduce.R"

#Upload Bill Scores
echo "Uploading user defined bill leans"
$r_command $r_script_folder"bill_score_upload.R"

#Legislator Mapping
echo "Merging legislator data from govtrack and OpenSecrets"
$r_command $r_script_folder"legislator_merge.R"

#Scoring
echo "Scoring legislators"
$r_command $r_script_folder"legislator_scoring.R"
echo "Scoring organizations"
#$r_command $r_script_folder"organization_scoring.R"
sudo mysql --password=$local_pass --verbose dataprocessing < ../db_utils/org_scoring.sql

#Output results
echo "Creating results file"
$r_command $r_script_folder"output_results.R"
