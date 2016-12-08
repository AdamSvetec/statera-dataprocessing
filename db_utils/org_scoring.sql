ALTER TABLE legislator_score MODIFY leg_id varchar(10);
CREATE INDEX IF NOT EXISTS legislator_score_leg ON legislator_score (leg_id);
CREATE INDEX IF NOT EXISTS indiv_pol_id ON contribution (pol_id);

DROP TABLE IF EXISTS org_score;

CREATE TABLE org_score (
org_id NUMERIC(7),
issue_id NUMERIC(2),
score NUMERIC (6,5),
PRIMARY KEY(org_id, issue_id)
);

INSERT INTO org_score
SELECT organization.Id, issue.Id, 0
FROM organization, issue;

REPLACE INTO org_score 
SELECT org_id, issue_id, (sum(score*amount))/(count(amount)*sum(amount))
FROM legislator_score, contribution
WHERE contribution.pol_id = legislator_score.leg_id
GROUP BY contribution.org_id, legislator_score.issue_id;
