#!/bin/sh -ve

python py/LanguageTable.py
python py/ISO3PriorityTable.py 
python py/BibleTable.py < metadata/FCBH/bible.json

sqlite Versions.db <<END_SQL
DROP TABLE IF EXISTS Bible;
DROP TABLE IF EXISTS Owner;
DROP TABLE IF EXISTS IOS3Priority;
DROP TABLE IF EXISTS Language;
DROP TABLE IF EXISTS Country;
END_SQL

sqlite Versions.db < sql/country.sql
sqlite Versions.db < sql/language.sql
sqlite Versions.db < sql/iso3Priority.sql
sqlite Versions.db < sql/copied_owner.sql
sqlite Versions.db < sql/bible.sql

# Merge ISO3Priority into Language
sqlite Versions.db <<END_SQL1
DROP TABLE IF EXISTS LanguageTemp;
ALTER TABLE Language RENAME TO LanguageTemp;

CREATE TABLE Language (
  iso3 TEXT NOT NULL PRIMARY KEY,
  iso1 TEXT NULL,
  macro TEXT NULL,
  name TEXT NOT NULL,
  country TEXT NULL REFERENCES Country(code),
  pop REAL NULL);

INSERT INTO Language
select l.iso3, l.iso1, l.macro, l.name, p.country, p.pop 
FROM LanguageTemp l LEFT OUTER JOIN ISO3Priority p 
ON p.iso3=l.iso3;
END_SQL1

# Remove Languages and Bibles that are not used.
sqlite Versions.db <<END_SQL
select count(*) AS Language_Count from Language;
select count(*) AS Bibles_Count from Bible;
delete from Language where iso1 is null;
delete from Bible where iso3 not in (select iso3 from Language);
delete from Language where iso3 not in (select iso3 from Bible);
select count(*) AS Language_Count from Language;
select count(*) AS Bibles_Count from Bible;
vacuum;
END_SQL

