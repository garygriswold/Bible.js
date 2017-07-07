#!/bin/sh -ev

sqlite DownloadERV.db <<END_SQL1

.output total.csv
select count(*) from DownloadERV;

DROP TABLE IF EXISTS VersionByMonth;
CREATE TABLE VersionByMonth AS
SELECT version, year || '-' || month as period, count(*) AS count from DownloadERV 
WHERE datetime >= '2016' and datetime < '2017-07'
group by version, year || '-' || month;

END_SQL1