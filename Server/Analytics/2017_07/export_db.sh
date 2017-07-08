#!/bin/sh -ev

sqlite DownloadERV.db <<END_SQL1

.output total.csv
select count(*) from DownloadERV;

DROP TABLE IF EXISTS VersionByMonth;
CREATE TABLE VersionByMonth AS
SELECT version, year || '-' || month as period, count(*) AS count 
from DownloadERV 
WHERE datetime >= '2016' and datetime < '2017-07'
group by version, year || '-' || month;

DROP TABLE IF EXISTS VersionByCountry;
CREATE TABLE VersionByCountry AS
SELECT v.version as version, c.countryCode, c.countryName as countryName, count(*) as count 
FROM DownloadERV v JOIN Region c ON v.country=c.countryCode 
GROUP by v.version, c.countryCode 
ORDER by v.version, c.countryName;

DROP TABLE IF EXISTS VersionByLanguage;
CREATE TABLE VersionByLanguage AS
SELECT v.version as version, c.langCode, c.englishName as englishName, count(*) as count
FROM downloadERV v JOIN Language c ON v.language=c.langCode
GROUP BY v.version, c.langCode
ORDER BY v.version, c.englishName;

DROP TABLE IF EXISTS VersionByDeviceOS;
CREATE TABLE VersionByDeviceOS AS
SELECT version, osType, count(*) as count
FROM DownloadERV
GROUP BY version, osType
ORDER BY version, osType;

END_SQL1

node Pivot3.js DownloadERV.db VersionByMonth version period count

node Pivot3.js DownloadERV.db VersionByCountry version countryName count

node Pivot3.js DownloadERV.db VersionByLanguage englishName version count

node Pivot3.js DownloadERV.db VersionByDeviceOS version osType count