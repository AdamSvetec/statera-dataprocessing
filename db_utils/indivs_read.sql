#Read in contribution records
DROP TABLE IF EXISTS contribution;

CREATE TABLE contribution (
pol_id varchar(10),
orgname varchar(30),
amount numeric(10),
org_id numeric(10),
real_code VARCHAR(1)
);

LOAD DATA INFILE '/home/ubuntu/BulkData/CampaignFin16/indivs16.txt'
INTO TABLE contribution
FIELDS TERMINATED BY ','
ENCLOSED BY '|'
LINES TERMINATED BY '\r\n'
(@dummy,@dummy,@dummy,@dummy,pol_id,orgname,@dummy,real_code,@dummy,amount,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy);

#Remove unwanted contributions
DELETE FROM contribution
WHERE amount <= 0;

DELETE FROM contribution
WHERE orgname IN (
      "", "Retired", "[24T Contribution]"
      );

#Group into organizations
DROP TABLE IF EXISTS organization;

CREATE TABLE organization ( 
Orgname VARCHAR(30), 
total_amount NUMERIC(12), 
total_contr NUMERIC(10)
);

INSERT INTO organization 
SELECT Orgname, SUM(Amount), COUNT(*) 
FROM contribution 
GROUP BY Orgname;

#Create indexes on orgnames to speed up join
CREATE INDEX org_orgname ON organization (Orgname);
CREATE INDEX indiv_orgname ON contribution (orgname);

ALTER TABLE organization ADD Id INT AUTO_INCREMENT PRIMARY KEY;

#Update contributions with organization's id instead of name
UPDATE contribution
SET org_id =
    (SELECT Id
    FROM organization
    WHERE organization.Orgname = contribution.orgname);

#ALTER TABLE contribution DROP COLUMN orgname;

#Direct committee to candidate mappings are done already in data
#DROP TABLE IF EXISTS committee;

#CREATE TABLE committee (
#id varchar(9),
#rec_id varchar(9)
#);

#LOAD DATA INFILE '/home/ubuntu/BulkData/CampaignFin16/cmtes16.txt'
#INTO TABLE committee
#FIELDS TERMINATED BY ','
#ENCLOSED BY '|'
#LINES TERMINATED BY '\n'
#(@dummy,id,@dummy,@dummy,@dummy,rec_id,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy,@dummy);

#CREATE INDEX pol_id_cmte ON committee (id);

#UPDATE indiv_to_pol_copy
#SET pol_id = CASE
#    WHEN pol_id LIKE "C%" THEN "FOUND" 
#    	 #(
#    	 #SELECT rec_id
#    	 #FROM committee
#    	 #WHERE id = pol_id)
#    ELSE pol_id
#END;

#create table indiv_to_pol_copy like indiv_to_pol;
#INSERT indiv_to_pol_copy SELECT * FROM indiv_to_pol;
