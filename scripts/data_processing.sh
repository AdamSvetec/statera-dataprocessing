#!/bin/bash

#Script for end to end data run
data_folder="/home/ubuntu/BulkData/"
source_folder="/home/ubuntu/379SeniorProject/"
fortune_n_file="fortune_500.csv"
bill_scores_file="bill_scores.csv"
issues_file="issues.csv"
votes_folder="votes/"
cf16_folder="CampaignFin16/"
r_command="R --vanilla -q --slave -f"
r_script_folder=$source_folder"r_dp/"

read -s -p "Please enter password: " local_pass
echo ""
echo "Begining end to end data processing run..."

#Copying user generated data files to data directory
cp -fp -- $source_folder"extraneous/"$issues_file $data_folder
cp -fp -- $source_folder"extraneous/"$bill_scores_file $data_folder
cp -fp -- $source_folder"extraneous/"$fortune_n_file $data_folder

#Preliminary
echo "Performing preliminary check"
$r_command $r_script_folder"preliminary.R"

#Data Upload
echo "Begining data upload"
echo "Uploading user defined issues"
$r_command $r_script_folder"issues_upload.R"
echo "Uploading legislators from govtrack"
$r_command $r_script_folder"legislator_upload.R"
echo "Uploading opensecrets legislator data" 
$r_command $r_script_folder"campaignfin16_upload.R"
echo "Uploading opensecrets contribution data"
sudo mysql --password=$local_pass --verbose dataprocessing < ../db_utils/indivs_read.sql
echo "Uploading govtrack voting records"
$r_command $r_script_folder"voting_upload.R"

#Filter out companies not in fortune 500
echo "Reducing organizations to fortune 500 companies"
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
$r_command $r_script_folder"organization_scoring.R"
#sudo mysql --password=$local_pass --verbose dataprocessing < ../db_utils/org_scoring.sql

#Output results
echo "Creating results file"
$r_command $r_script_folder"output_results.R"

#Collect Metrics
echo "Collecting Metrics"
$r_command $r_script_folder"overall_metric_score.R"
