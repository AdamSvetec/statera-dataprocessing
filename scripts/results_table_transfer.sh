#!/bin/bash

local_db="dataprocessing"
web_server_url="ec2-54-212-210-64.us-west-2.compute.amazonaws.com"
web_server_ip="35.164.129.255"
remote_db="webserver"
table_names="final_org_results issue organization org_score"

read -s -p "Enter password for local database: " local_pass
echo ""
read -s -p "Enter password for remote database: " remote_pass
echo ""

mysqldump --password=$local_pass $local_db $table_names | ssh -i ~/MyKey.pem ubuntu@$web_server_ip sudo mysql --password=$remote_pass $remote_db
