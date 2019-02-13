
############################ Upload Bibles ############################

python py/UploadBibleText.py ARBVDPD.db
python py/UploadBibleText.py ERV-ARB.db
python py/UploadBibleText.py ERV-AWA.db
python py/UploadBibleText.py ERV-BEN.db
python py/UploadBibleText.py ERV-BUL.db
python py/UploadBibleText.py ERV-CMN.db
python py/UploadBibleText.py ERV-ENG.db
python py/UploadBibleText.py ERV-HIN.db
python py/UploadBibleText.py ERV-HRV.db
python py/UploadBibleText.py ERV-HUN.db
python py/UploadBibleText.py ERV-IND.db
python py/UploadBibleText.py ERV-KAN.db
python py/UploadBibleText.py ERV-MAR.db
python py/UploadBibleText.py ERV-NEP.db
python py/UploadBibleText.py ERV-ORI.db
python py/UploadBibleText.py ERV-PAN.db
python py/UploadBibleText.py ERV-POR.db
python py/UploadBibleText.py ERV-RUS.db
python py/UploadBibleText.py ERV-SPA.db
python py/UploadBibleText.py ERV-SRP.db
python py/UploadBibleText.py ERV-TAM.db
python py/UploadBibleText.py ERV-THA.db
python py/UploadBibleText.py ERV-UKR.db
python py/UploadBibleText.py ERV-URD.db
python py/UploadBibleText.py ERV-VIE.db
python py/UploadBibleText.py KJVPD.db
python py/UploadBibleText.py NMV.db
python py/UploadBibleText.py WEB.db

# To validate the naming in the Upload:
# sh extract_dbp_prod.sh # to extract these bibles from dbp
# python py/ListBucket.py > west_2.out # to List uploaded Bibles
# diff dbp_prod.out west_2.out

############################ Support Tables ############################

# Create and Load Credentials Table
sqlite Versions.db < Credentials.sql

# Create and Load Owner Table
sqlite Versions.db < sql/Owners.sql

#Create and Lood Region Table
sqlite Versions.db << END_SQL1
CREATE TABLE Region (
countryCode TEXT NOT NULL PRIMARY KEY,
continentCode TEXT NOT NULL CHECK (continentCode IN('AF','EU','AS','NA','SA','OC','AN')),
geoschemeCode TEXT NOT NULL CHECK (geoschemeCode IN(
		'AF-EAS','AF-MID','AF-NOR','AF-SOU','AF-WES',
		'SA-CAR','SA-CEN','SA-SOU','NA-NOR',
		'AS-CEN','AS-EAS','AS-SOU','AS-SEA','AS-WES',
		'EU-EAS','EU-NOR','EU-SOU','EU-WES',
		'OC-AUS','OC-MEL','OC-MIC','OC-POL','AN-ANT')),
awsRegion TEXT NOT NULL REFERENCES AWSRegion(awsRegion),
countryName TEXT NOT NULL	
);
CREATE INDEX Region_awsRegion_index ON Region(awsRegion);
.separator '|'
.import data/Region.txt Region
END_SQL1
# Continent Code
# AF|Africa
# EU|Europe
# AS|Asia
# NA|North America
# SA|South America
# OC|Oceana
# AN|Antartica

# United Nations geoschema
# AF-EAS|Eastern Africa
# AF-MID|Middle Africa
# AF-NOR|Northern Africa
# AF-SOU|Southern Africa
# AF-WES|Western Africa
# SA-CAR|Caribbean
# SA-CEN|Central America
# SA-SOU|South America
# NA-NOR|North America
# AS-CEN|Central Asia
# AS-EAS|Eastern Asia
# AS-SOU|Southern Asia
# AS-SEA|South-Eastern Asia
# AS-WES|Western Asia
# EU-EAS|Eastern Europe
# EU-NOR|Northern Europe
# EU-SOU|Southern Europe
# EU-WES|Western Europe
# OC-AUS|Australia and New Zealeand
# OC-MEL|Melanesia
# OC-MIC|Micronesia
# OC-POL|Polynesia

# Rules for bucket assignment:
# 1) AF -> eu-west-1
# 2) EU -> eu-west-1
# 3) OC -> ap-southeast-2
# 4) AN -> ap-southeast-2
# 5) NA -> us-east-1
# 6) SA -> us-east-1
# 7) AS-WES -> eu-west-1
# 8) AS-SOU -> ap-southeast-1
# 9) AS-SEA -> ap-southeast-1
# 10) AS-CEN -> ap-northeast-1
# 11) AS-EAS -> ap-northeast-1

# Create and Load LanguageTemp and ISO3Priority
python py/LanguageTable.py
python py/ISO3PriorityTable.py

sqlite Versions.db < sql/language.sql
sqlite Versions.db < sql/iso3Priority.sql

# Create and Load Language
sqlite Versions.db <<END_SQL2
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
END_SQL2

############################ Bible Text ############################

# Create and Load Bible table
sqlite Versions.db < sql/BibleTable.sql

# Validate Bible Table keys against dbp-prod bucket
python py/BibleValidate.py
# Note: The above program only matches against one bucket
# tweek it to text every bucket involved.

# Create A Copy of DB before Deletions
cp Versions.db VersionsFull.db

# Remove Languages and Bibles that are not used.
sqlite Versions.db <<END_SQL3
select count(*) AS Language_Count from Language;
select count(*) AS Bibles_Count from Bible;
delete from Language where iso1 is null;
select count(*) AS Language_Count from Language;
select bibleId from Bible where iso3 not in (select iso3 from Bible);

create index language_iso1_idx on Language(iso1);
-- create index bible_iso3_idx on Bible(iso3);

drop table LanguageTemp;
drop table ISO3Priority;
vacuum;
END_SQL3

# Patch some with bad entries
sqlite Versions.db <<END_SQL4
select count(*) from Bible;
vacuum;
END_SQL4

# In Bible, update direction, script, country
python py/BibleUpdateInfo.py
sqlite Versions.db < sql/bible_update.sql

# Run a final validation to make sure that problems are removed
python py/BibleValidate.sh

# Make any needed deletions from Bible based upon errors in validation
sqlite Versions.db <<END_SQL5
UPDATE Bible SET direction='ltr', script='Latn', country=null WHERE bibleId='KJVPD.db';
UPDATE Bible SET country='RU' WHERE bibleId='ERV-RUS.db';
UPDATE Bible SET country='IR' WHERE bibleId='NMV.db';
END_SQL5

# Use Google Translate to improve the Bible names
python py/TranslateBibleNames.py
sqlite Versions.db < sql/LocalizedBibleNames.sql
sqlite Versions.db <<END_SQL6
SELECT * FROM Bible WHERE localizedName is NULL;
UPDATE Bible SET localizedName = name WHERE localizedName is NULL;
END_SQL6

###################### Audio Player ######################

# Generate AudioBook table by parse of dbp-prod
python py/AudioDBImporter.py

sqlite Versions.db < sql/AudioBookTable.sql

# Generate AudioChapter table by DBP API
python py/AudioDBPChapter.py

sqlite Versions.db < sql/AudioChapterTable.sql

# Validate the generated keys
python py/AudioDBPValidator.py

# patch problems in damId selection
sqlite Versions.db <<END_SQL7
UPDATE Bible SET otDamId='ENGWEBO2DA', ntDamId='ENGWEBN2DA' WHERE bibleId='ENGWEB'
update AudioBook set damId='ENGWEBN2DA' where damId='EN1WEBN2DA';
update AudioBook set damId='ENGWEBO2DA' where damId='EN1WEBO2DA';
END_SQL7

###################### Video Player ######################

# Pulls data from JFP web service, and generates JesusFilm table
python py/JesusFilmImporter.js

sqlite Versions.db < sql/jesus_film.sql

# Create Video table by extracting data from Jesus Film Project
python py/VideoTable.py

sqlite Versions.db < sql/video.sql

# Erase video descriptions in English for non-English languages
sqlite Versions.db <<END_SQL8
update Video set description=null where languageId != '529' and mediaId='1_jf-0-0' and description = (select description from Video where languageId='529' and mediaId='1_jf-0-0');
update Video set description=null where languageId != '529' and mediaId='1_wl-0-0' and description = (select description from Video where languageId='529' and mediaId='1_wl-0-0');
update Video set description=null where languageId != '529' and mediaId='1_cl-0-0' and description = (select description from Video where languageId='529' and mediaId='1_cl-0-0');
vacuum;
END_SQL8

# Edit VideoUpdate.sql for changes in ROCK videos
sqlite Versions.db < sql/VideoUpdate.sql

# Loads KOG Descriptions into Video table
python py/UpdateVideo.py

# Add a table that contols the sequence of Video Presentation in App
sqlite Versions.db <<END_SQL9
DROP TABLE IF EXISTS VideoSeq;
CREATE TABLE VideoSeq (mediaId TEXT PRIMARY KEY, sequence INT NOT NULL);
INSERT INTO VideoSeq VALUES ('1_jf-0-0', 1);
INSERT INTO VideoSeq VALUES ('1_cl-0-0', 2);
INSERT INTO VideoSeq VALUES ('1_wl-0-0', 3);
INSERT INTO VideoSeq VALUES ('KOG_OT', 4);
INSERT INTO VideoSeq VALUES ('KOG_NT', 5);
END_SQL9

###################### String Localization ######################

# Make certain that all desired languages are included in xCode project
# Make certain that py/LocalizableStrings2.py contains a google lang code for each
# Using xCode project, Editor -> Export Localization, put into Downloads
# Select only the languages that need work, which might be all

python py/LocalizableStrings2.py

# Using xCode project, Editor -> Import Localization, import each converted language



