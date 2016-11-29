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
echo "Begining end to end data processing run..."

#Data Upload
echo "Begining data upload"
echo "Uploading user defined issues"
$r_command $r_script_folder"issues_upload.R"
echo "Uploading legislators from govtrack"
$r_command $r_script_folder"legislator_upload.R"
echo "Uploading OpenSecrets 2016 campaign finance data" 
$r_command $r_script_folder"upload_CF16.R"
echo "Uploading govtrack voting records"
$r_command $r_script_folder"voting_upload.R"

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
$r_command $r_script_folder"organization_scoring.R"

#Output results
echo "Creating results file"
$r_command $r_script_folder"output_results.R"
