#!/bin/sh -ve

python py/LanguageTable.py

python py/BibleTable.py < metadata/bible.json

sqlite Versions.db <<END_SQL
DROP TABLE IF EXISTS Bible;
DROP TABLE IF EXISTS Owner;
DROP TABLE IF EXISTS Language;
END_SQL

sqlite Versions.db < sql/language.sql
sqlite Versions.db < sql/copied_owner.sql
sqlite Versions.db < sql/bible.sql

sqlite Versions.db <<END_SQL
select count(*) AS Language_Count from Language;
select count(*) AS Bibles_Count from Bible;
delete from Language where iso1 is null;
delete from Bible where iso not in (select iso from Language);
delete from Language where iso not in (select iso from Bible);
select count(*) AS Language_Count from Language;
select count(*) AS Bibles_Count from Bible;
END_SQL

