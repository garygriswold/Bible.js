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
out.write(u"  countryCode TEXT NULL REFERENCES Country(code),\n")		# from countryCode
out.write(u"  stylesheet TEXT NULL,\n")									# from stylesheet
out.write(u"  redistribute TEXT CHECK (redistribute IN('T', 'F')) default('F'),\n")
out.write(u"  audioDirectory TEXT NULL,\n")								# from audioDirectory
out.write(u"  organizationId TEXT NULL REFERENCES Owner(ownerCode),\n")	# unknown source
out.write(u"  ssFilename TEXT NULL,\n")									# from me
out.write(u"  hasHistory TEXT CHECK (hasHistory IN('T','F')) default('F'),\n") # from me
out.write(u"  copyright TEXT NULL,\n")									# from me
# consider adding numbers, and array of numeric values in string form
out.write(u"  introduction TEXT NULL);\n")								# about.html (should be in own table)

prefix1 = "INSERT INTO Bible (bibleId, abbr, iso3, name, englishName) VALUES"
prefix2 = "REPLACE INTO Bible (bibleId, abbr, iso3, name, englishName, direction, fontClass, script, countryCode, stylesheet, redistribute, audioDirectory) VALUES"

# read and process bible.json
input = io.open("metadata/FCBH/bible.json", mode="r", encoding="utf-8")
data = input.read()
print "Counted", len(data), "chars."
bibles = json.loads(data)['data']

for bible in bibles:
	bibleId = bible['abbr']
	abbr = bibleId[3:]
	iso3 = bible['iso']
	name = bible['name'].replace("\\", "").replace("'", "''")
	englishName = name
	vname = bible['vname']
	if type(vname) is unicode and len(vname) > 0:
		name = vname.replace("\\", "").replace("'", "''")
	out.write("%s ('%s', '%s', '%s', '%s', '%s');\n" % (prefix1, bibleId, abbr, iso3, name, englishName))

# read and process all info.json files
source = "/Users/garygriswold/ShortSands/DBL/FCBH_info"
for bibleDir in os.listdir(source):
	if bibleDir[0] != ".":
		filename = source + "/" + bibleDir + "/info.json"
		input2 = io.open(filename, mode="r", encoding="utf-8")
		data = input2.read()
		bible = json.loads(data)
		bibleId = bible['id']
		print bibleId

		# check type to see if == bible
		bType = bible['type']
		if bType != 'bible':
			print "?? Type = ", bType

		# check abbr to see if different from bibleId
		abbr = bible['abbr']
		print abbr
		if abbr != bibleId:
			print "?? bibleId=", bibleId, "  abbr=", abbr

		# remove lang code from abbr
		abbr = abbr[3:]

		# check that lang == first 3 letters of bibleId
		iso3 = bible['lang']
		if iso3.upper() != bibleId[0:3]:
			print "?? bibleId=", bibleId, "  iso3=", iso3

		iso3 = iso3.lower()
		name = bible['name']
		englishName = bible['nameEnglish']
		directory = bible['dir']
		font = bible.get('fontClass', '')

		# convert script to iso 15924 code
		script = bible.get('script', '')
		if script == 'Latin':
			script = 'Latn'
		elif script == 'Cyrillic':
			script = 'Cyrl'
		elif script == 'Arabic':
			script = 'Arab'
		elif script != '':
			print "ERROR: unknown script code", script
		print script

		countryCode = bible.get('countryCode', '')
		stylesheet = bible.get('stylesheet', '')
		redistribute = 'T' if (bible.get('redistributable', False)) else 'F'
		print "redistribute", redistribute
		audioDir = bible.get('audioDirectory', '')
		if audioDir != '' and audioDir != bibleId:
			print "?? bibleId=", bibleId, "  audioDirectory=", audioDir

		out.write("%s ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');\n" % 
		(prefix2, bibleId, abbr, iso3, name, englishName, directory, font, script, countryCode, stylesheet, redistribute, audioDir))

out.close()