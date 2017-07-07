#!/bin/sh -ev

sqlite3 ../../Analytics.db <<END_SQL1
.output downloadERV.sql
.schema BibleDownload
.schema DownloadERV
.mode insert BibleDownload
select * from BibleDownload where datetime > '2016-12' and datetime < '2017-07';
.output stdout
END_SQL1

sqlite ../../../Versions/Versions.db <<END_SQL2
.output versions.sql
.schema Language
.mode insert Language
select * from Language;
.schema AWSRegion
.mode insert AWSRegion
select * from AWSRegion;
.schema Region
.mode insert Region
select * from Region;
.output stdout
END_SQL2

sqlite DownloadERV.db <<END_SQL3
drop view IF EXISTS DownloadERV;
drop table IF EXISTS BibleDownload;
drop table IF EXISTS Language;
drop table IF EXISTS Region;
drop table IF EXISTS AWSRegion;
END_SQL3

sqlite DownloadERV.db < downloadERV.sql
sqlite DownloadERV.db < versions.sql
