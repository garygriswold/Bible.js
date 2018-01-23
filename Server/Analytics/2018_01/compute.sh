#!/bin/sh



sqlite3 DownloadERV.db <<END_SQL1

DROP TABLE IF EXISTS VersionByCountry;
CREATE TABLE VersionByCountry AS
SELECT v.version AS version, v.country AS countryCode, r.countryName AS countryName, count(*) AS count
FROM DownloadERV v, Region r
WHERE v.country=r.countryCode
GROUP BY v.version, v.country;

DROP TABLE IF EXISTS VersionByDeviceOS;
CREATE TABLE VersionByDeviceOS AS
SELECT version, osType, count(*) AS count
FROM DownloadERV
GROUP BY version, osType;

DROP TABLE IF EXISTS VersionByLanguage;
CREATE TABLE VersionByLanguage AS
SELECT v.version AS version, v.language AS langCode, l.englishName AS englishName, count(*) AS count
FROM DownloadERV v, Language l
WHERE v.language=l.langCode
GROUP BY v.version, v.language;

DROP TABLE IF EXISTS VersionByMonth;
CREATE TABLE VersionByMonth AS
SELECT version, year || '-' || month AS period, count(*) AS count
FROM DownloadERV
GROUP BY version, year, month

END_SQL1

# Pivot3: databaseName, tableName, xAxisColumn, yAxisColumn, value

## Versions by Month -> VersionByMonth.csv
node Pivot3 DownloadERV.db VersionByMonth version period count

## Version by Country -> VersionByCountry.csv
node Pivot3 DownloadERV.db VersionByCountry countryName version count

## Version by Language -> VersionByLanguage.csv
node Pivot3 DownloadERV.db VersionByLanguage englishName version count

## Version by DeviceOS -> VersionByDeviceOS.csv
node Pivot3 DownloadERV.db VersionByDeviceOS version osType count



