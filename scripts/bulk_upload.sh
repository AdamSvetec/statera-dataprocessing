#!/bin/bash

#Bash script for data upload to remote server

read -p "Pulling on server: 's' or pushing from local: 'l'? " prompt

if [ "$prompt" = "s" ]; then
    echo "Pulling data from govtrack: "
    foldername="~/BulkData"
    rsync_command="rsync -avz"
    basepath="govtrack.us::govtrackdata"

    $rsync_command $basepath/congress-legislators/legislators-historic.csv $foldername/
    $rsync_command --exclude='*.xml' $basepath/congress/114/votes/ $foldername/votes
    $rsync_command --exclude='*.xml' $basepath/congress/113/votes/ $foldername/votes
    $rsync_command --exclude='*.xml' $basepath/congress/112/votes/ $foldername/votes
    $rsync_command --exclude='*.xml' $basepath/congress/111/votes/ $foldername/votes
    $rsync_command --exclude='*.xml' $basepath/congress/110/votes/ $foldername/votes
    $rsync_command --exclude='*.xml' $basepath/congress/109/votes/ $foldername/votes

    echo "govtrack pull complete"

elif [ "$prompt" = "l" ]; then
    read -p "Enter path to zip file holding open secrets data: " filename
    read -p "Enter path to ssh key file: " pemfile
    
    scp -i $pemfile $filename ubuntu@ec2-54-84-23-217.compute-1.amazonaws.com:~/BulkData

fi
