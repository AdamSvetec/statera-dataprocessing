DROP TABLE IF EXISTS stance, political_issue, vote, bill, contribution_pac_to_pol, contribution_corp_to_pac, contribution_corp_to_pol, pac, politician, political_party, corporation;

CREATE TABLE corporation
(
id numeric(10),
name varchar(30) not null,
description varchar(140) not null,
location varchar(40) not null,
primary key(id)
);

CREATE TABLE political_party
(
id numeric(10),
name varchar(20),
primary key(id)
);

CREATE TABLE politician
(
id numeric(10),
name varchar(30) not null,
state varchar(2) not null,
party_id numeric(10),
primary key(id),
foreign key(party_id) references political_party(id)
);

CREATE TABLE pac
(
id numeric(10),
name varchar(30) not null,
primary key(id)
);

CREATE TABLE contribution_corp_to_pol
(
id numeric(10),
politician_id numeric(10),
corporation_id numeric(10),
amount numeric(10),
contribution_date date not null,
primary key(id),
foreign key(politician_id) references politician(id),
foreign key(corporation_id) references corporation(id)
);

CREATE TABLE contribution_corp_to_pac
(
id numeric(10),
pac_id numeric(10),
corporation_id numeric(10),
amount numeric(10),
contribution_date date not null,
primary key(id),
foreign key(pac_id) references pac(id),
foreign key(corporation_id) references corporation(id)
);

CREATE TABLE contribution_pac_to_pol
(
id numeric(10),
politician_id numeric(10),
pac_id numeric(10),
amount numeric(10),
contribution_date date not null,
primary key(id),
foreign key(politician_id) references politician(id),
foreign key(pac_id) references pac(id)
);

CREATE TABLE bill
(
id numeric(10),
name varchar(20),
primary key(id)
);

CREATE TABLE vote
(
vote_for boolean,
politician_id numeric(10),
bill_id numeric(10),
primary key(politician_id, bill_id),
foreign key(politician_id) references politician(id),
foreign key(bill_id) references bill(id)
);

CREATE TABLE political_issue
(
id numeric(10),
name varchar(30),
description varchar(140),
primary key(id)
);

CREATE TABLE stance
(
bill_id numeric(10),
pol_issue numeric(10),
lean numeric(3),
primary key(bill_id, pol_issue),
foreign key(bill_id) references bill(id),
foreign key(pol_issue) references political_issue(id)
);
