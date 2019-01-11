#!/bin/sh -ve

# Create Support Tables
python py/CountryTable.py
python py/LanguageTable.py
python py/ISO3PriorityTable.py

# Create Bible Table
python py/ListBucket.py > metadata/FCBH/dbp_prod.txt
python py/DownloadBible.py > metadata/FCBH/bible.json
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

# Validate Bible Table keys against dbp-prod bucket
python py/BibleValidate.py

# Merge ISO3Priority into Language
sqlite Versions.db <<END_SQL1
DROP TABLE IF EXISTS Language;
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

# Create A Copy of DB before Deletions
cp Versions.db VersionsFull.db

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

drop table LanguageTemp;
drop table ISO3Priority;
vacuum;
END_SQL

# Patch some with bad entries
sqlite Versions.db <<END_SQL3
update Bible set textBucket='inapp', textId='ENGKJV' where bibleId='ENGKJV';
update Bible set otDamId='ENGESVO2DA', ntDamId='ENGESVN2DA' where bibleId='ENGESV';
delete from Bible where textId is null;
INSERT INTO Bible (bibleId, abbr, iso3, name, englishName, textBucket, textId, keyTemplate, audioBucket, otDamId, ntDamId) VALUES 
('KMRIBT', 'IBT', 'kmr', 'Încîl Mizgînî', 'Kurmanji Kurdish New Testament (Latin)', 'dbp-prod', 'KM2IBT', '%I_%O_%B_%C.html', 'dbp-prod', null, 'KMRIBTN2DA');
select count(*) from Bible;
vacuum;
END_SQL3

# In Bible, update direction, script, country
python py/BibleUpdateInfo.py
sqlite Versions.db < sql/bible_update.sql

# Run a final validation to make sure that problems are removed
python py/BibleValidate.sh

# Make any needed deletions from Bible based upon errors in validation
sqlite Versions.db <<END_SQL4


END_SQL4

# Use Google Translate to improve the Bible names
python py/TranslateBibleNames.py
sqlite Versions.db < sql/LocalizedBibleNames.sql
sqlite Versions.db <<END_SQL2
UPDATE Bible SET localizedName = name WHERE localizedName is NULL;
END_SQL2

############# Video #####################

# Pulls data from JFP web service, and generates JesusFilm table
python py/JesusFilmImporter.js

sqlite Versions.db < sql/jesus_film.sql

# Create Video table by extracting data from Jesus Film Project
python py/VideoTable.py

sqlite Versions.db < sql/video.sql

#NOTE: should delete duplicate english rows in VideoTable




