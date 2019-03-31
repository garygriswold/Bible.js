
############################ Copy Release 2.0.x ############################
# Use the prior release as a starting point

cp ../Release.2.0.x/Versions.db .


############################ Language Table ############################

# Create and Load Language
python py/LanguageTable.py
sqlite Versions.db < sql/language.sql

############################ Bible Table ############################

# Create and Load Bible table
sqlite Versions.db < sql/BibleTable.sql

# In Bible, update script, country
# An error occurs with KJV, because the text file is not in dbp-prod
python py/BibleUpdateInfo.py
sqlite Versions.db < sql/bible_update.sql

# In Bible, populate iso1 using SIL Language tables
python py/BibleLanguageCode.py
sqlite Versions.db < sql/Bible_lang.sql

# Remove script when it is not needed.
# In order that Language and Bible can match on iso1/script, the Bible table
# must include script for those languages where it is appropriate, 
# and it must exclude script for all those languages where it is not appropriate
sqlite Versions.db <<END_SQL1
-- delete script from those that should not have one
update Bible set script='' where iso1 not in (select iso1 from Language where script != '');
-- select those that MUST have a script
select bibleId, script from Bible where iso1 in (select iso1 from Language where script != '');
-- double check results are the same
select bibleId, script from Bible where script != '';
-- correct script codes that are in error
update Bible set script='Hans' where bibleId = 'ERV-CMN.db';
update Bible set script='Guru' where bibleId = 'ERV-PAN.db';
update Bible set script='Cyrl' where bibleId = 'ERV-SRP.db';
END_SQL1

# Create A Copy of DB before Deletions
cp Versions.db VersionsFull.db

# Remove Languages and Bibles that are not used.
sqlite Versions.db <<END_SQL2
select count(*) from Language;
select count(*) from Bible;
delete from Language where iso1 || script not in (select iso1 || script from Bible);
select count(*) from Language;

-- all bibles returned will be ignored, they have no language
select bibleId from Bible where iso1 || script not in (select iso1 || script from Language);

vacuum;
END_SQL2

# Validate Bible Table keys against dbp-prod bucket
python py/BibleValidate.sh

# Validate the lookup of info.json files and the last chapter
python py/BibleValidate2.sh

# Patch some with bad entries
sqlite Versions.db <<END_SQL3
select count(*) from Bible;
vacuum;
END_SQL3

# Make any needed deletions from Bible based upon errors in validation
sqlite Versions.db <<END_SQL5
UPDATE Bible SET country='RU' WHERE bibleId='ERV-RUS.db';
UPDATE Bible SET country='IR' WHERE bibleId='NMV.db';
UPDATE Bible SET country='GB' WHERE bibleId='KJVPD.db';
UPDATE Bible SET country='ES' WHERE bibleId='ERV-SPA.db';
END_SQL5

# Use Google Translate to improve the Bible names
python py/TranslateBibleNames.py
sqlite Versions.db < sql/LocalizedBibleNames.sql

sqlite Versions.db <<END_SQL6
SELECT * FROM Bible WHERE localizedName is NULL;
UPDATE Bible SET localizedName = name WHERE localizedName is NULL;
END_SQL6


