#!/bin/bash

#Initializing tables in database

read -s -p "Please enter the username for database admin: " pass

sudo mysql --password=$pass dataprocessing < ../src/DatabaseUtilities/TableDeclarations.sql

#sudo mysql --password=$pass test < testingscript.sql
