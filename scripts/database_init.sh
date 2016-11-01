#!/bin/bash

#Initializing tables in database

read -s -p "Please enter the password for database admin: " pass

sudo mysql --password=$pass dataprocessing < ../db_utils/TableDeclarations.sql

#sudo mysql --password=$pass test < testingscript.sql
