#!/bin/sh -ve

python py/LanguageTable.py < metadata/language_prod.json

python py/BibleTable.py < metadata/bible.json

sqlite Versions.db < sql/language.sql
sqlite Versions.db < sql/copied_owner.sql
sqlite Versions.db < sql/bible.sql

