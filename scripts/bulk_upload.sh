#!/bin/bash

#Bash script for data upload to remote server

read -p "Pulling on server: 's' or pushing from local: 'l' or unzipping files: 'u'? " prompt

if [ "$prompt" = "s" ]; then
    echo "Pulling data from govtrack: "
    foldername="/home/ubuntu/BulkData"
    rsync_command="rsync -avz"
    basepath="govtrack.us::govtrackdata"

    $rsync_command $basepath/congress-legislators/legislators-historic.csv $foldername/
    $rsync_command $basepath/congress-legislators/legislators-current.csv $foldername/
    $rsync_command --exclude='*.xml' $basepath/congress/114/votes/ $foldername/votes
    $rsync_command --exclude='*.xml' $basepath/congress/113/votes/ $foldername/votes
    $rsync_command --exclude='*.xml' $basepath/congress/112/votes/ $foldername/votes
    $rsync_command --exclude='*.xml' $basepath/congress/111/votes/ $foldername/votes
    #$rsync_command --exclude='*.xml' $basepath/congress/110/votes/ $foldername/votes
    #$rsync_command --exclude='*.xml' $basepath/congress/109/votes/ $foldername/votes

    echo "govtrack pull complete"

elif [ "$prompt" = "l" ]; then
    read -p "Enter path to zip file holding open secrets data: " filename
    read -p "Enter path to ssh key file: " pemfile
    
    scp -i $pemfile $filename ubuntu@ec2-54-84-23-217.compute-1.amazonaws.com:~/BulkData/CampaignFin16.zip

elif [ "$prompt" = "u" ]; then
    
    unzip ~/BulkData/CampaignFin16.zip -d ~/BulkData/CampaignFin16/

fi
