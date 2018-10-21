#!/bin/sh -ve

# Create SQL Files to populate database
# I think missing py/CountryTable.py
python py/LanguageTable.py
python py/ISO3PriorityTable.py 
python py/BibleTable.py

sqlite Versions.db <<END_SQL
DROP TABLE IF EXISTS Bible;
DROP TABLE IF EXISTS Owner;
DROP TABLE IF EXISTS IOS3Priority;
DROP TABLE IF EXISTS Language;
DROP TABLE IF EXISTS Country;
DROP TABLE IF EXISTS Region;
END_SQL

# Load database
sqlite Versions.db < sql/country.sql
sqlite Versions.db < sql/language.sql
sqlite Versions.db < sql/iso3Priority.sql
sqlite Versions.db < sql/copied_owner.sql
sqlite Versions.db < sql/bible.sql
# Add Region table for AWS to know SS Regions
sqlite Versions.db < sql/copied_region.sql


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

-- cleanup null fields
update Bible set script=null where script = '';
update Bible set country=null where country = '';
vacuum;
END_SQL1

# Use Google Translate to improve the Bible names
python py/TranslateBibleNames.py
sqlite Versions.db < sql/LocalizedBibleNames.sql
sqlite Versions.db <<END_SQL2
UPDATE Bible SET localizedName = name WHERE localizedName is NULL;
END_SQL2

# Create A Copy of DB before Deletions
cp Versions.db VersionsFull.db

# Read Bible.json and use to update Bible table
# Removed 9/3/18 i.e. use only json.info
#python py/UpdateBibleByBibleJson.py

# Remove Languages and Bibles that are not used.
sqlite Versions.db <<END_SQL
select count(*) AS Language_Count from Language;
select count(*) AS Bibles_Count from Bible;
delete from Language where iso1 is null;
delete from Bible where iso3 not in (select iso3 from Language);
delete from Language where iso3 not in (select iso3 from Bible);
select count(*) AS Language_Count from Language;
select count(*) AS Bibles_Count from Bible;

create index language_iso1_idx on Language(iso1);
create index bible_iso3_idx on Bible(iso3);
vacuum;
END_SQL

