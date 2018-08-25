#
# This program generates SQL statements to create and populate the Bible table
# This was previously called the Version table
#
import io
import os
import json

out = io.open("sql/bible.sql", mode="w", encoding="utf-8")

out.write(u"DROP TABLE IF EXISTS Bible;\n")
out.write(u"CREATE TABLE Bible (\n")
out.write(u"  bibleId TEXT NOT NULL PRIMARY KEY,\n") 					# from id
out.write(u"  abbr TEXT NOT NULL,\n")									# from abbr
out.write(u"  iso3 TEXT NOT NULL REFERENCES Language(iso3),\n")			# from lang
out.write(u"  name TEXT NOT NULL,\n")									# from name
out.write(u"  englishName TEXT NULL,\n")								# from nameEnglish
out.write(u"  direction TEXT CHECK (direction IN('ltr','rtl')) default('ltr'),\n") # from dir
out.write(u"  fontClass TEXT NULL,\n")									# from fontClass
out.write(u"  script TEXT NULL,\n")										# from script
out.write(u"  country TEXT NULL REFERENCES Country(code),\n")			# from countryCode
out.write(u"  stylesheet TEXT NULL,\n")									# from stylesheet
out.write(u"  redistribute TEXT CHECK (redistribute IN('T', 'F')) default('F'),\n")
out.write(u"  objectKey TEXT NOT NULL,\n")									# from info.json filename
out.write(u"  organizationId TEXT NULL REFERENCES Owner(ownerCode),\n")	# unknown source
out.write(u"  ssFilename TEXT NULL,\n")									# from me
out.write(u"  hasHistory TEXT CHECK (hasHistory IN('T','F')) default('F'),\n") # from me
out.write(u"  copyright TEXT NULL,\n")									# from me
# consider adding numbers, and array of numeric values in string form
out.write(u"  introduction TEXT NULL);\n")								# about.html (should be in own table)

prefix2 = "REPLACE INTO Bible (bibleId, abbr, iso3, name, englishName, direction, fontClass, script, country, stylesheet, redistribute, objectKey) VALUES"

# read and process all info.json files
source = "/Users/garygriswold/ShortSands/DBL/FCBH_info/"
for filename in os.listdir(source):
	if filename[0] != ".":
		input2 = io.open(source + filename, mode="r", encoding="utf-8")
		data = input2.read()
		bible = json.loads(data)
		bibleId = bible['id']

		# check type to see if == bible
		bType = bible['type']
		if bType != 'bible':
			print "?? Type = ", bType

		# check abbr to see if different from bibleId
		abbr = bible['abbr']
		if abbr != bibleId:
			print "?? bibleId=", bibleId, "  abbr=", abbr

		# remove lang code from abbr
		abbr = abbr[3:]

		# check that lang == first 3 letters of bibleId
		iso3 = bible['lang']
		if iso3.upper() != bibleId[0:3]:
			print "?? bibleId=", bibleId, "  iso3=", iso3

		iso3 = iso3.lower()
		name = bible['name'].replace("'", "''")
		englishName = bible['nameEnglish'].replace("'", "''")
		direction = bible['dir']
		font = bible.get('fontClass')
		font = "'" + font + "'" if font != None else 'null'

		# convert script to iso 15924 code
		script = bible.get('script')
		validScripts = [None, 'Arab', 'Beng', 'Cyrl', 'Deva', 'Ethi', 'Geor', 'Latn', 'Orya', 'Syrc', 'Taml', 'Thai' ]
		#if validScripts.index(script) < 0:
		if script in validScripts:
			a = 1
		else:
			if script == 'Latin':
				script = 'Latn'
			elif script == 'Cyrillic':
				script = 'Cyrl'
			elif script == 'Arabic':
				script = 'Arab'
			elif script == 'Devangari':
				script = 'Deva'
			elif script == 'Devanagari (Nagari)':
				script = 'Deva'
			elif script == 'CJK':
				script = ''
			else:
				print "ERROR: unknown script code", script, filename
		script = "'" + script + "'" if script != None else 'null'

		country = bible.get('countryCode')
		country = "'" + country + "'" if country != None else 'null'
		stylesheet = bible.get('stylesheet')
		stylesheet = "'" + stylesheet + "'" if stylesheet != None else 'null'
		redistribute = 'T' if (bible.get('redistributable', False)) else 'F'
		objectKey = filename.replace("info.json", "").replace(":", "/")

		out.write("%s ('%s', '%s', '%s', '%s', '%s', '%s', %s, %s, %s, %s, '%s', '%s');\n" % 
		(prefix2, bibleId, abbr, iso3, name, englishName, direction, font, script, country, stylesheet, redistribute, objectKey))

out.close()