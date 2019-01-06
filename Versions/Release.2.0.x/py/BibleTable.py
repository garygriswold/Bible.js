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
out.write(u"  bibleId TEXT NOT NULL PRIMARY KEY,\n") 					# info.json filename[5:18]
out.write(u"  code TEXT NOT NULL,\n")									# info.json abbr
out.write(u"  abbr TEXT NOT NULL,\n")									# info.json abbr char 4-6
out.write(u"  iso3 TEXT NOT NULL REFERENCES Language(iso3),\n")			# info.json lang
out.write(u"  name TEXT NOT NULL,\n")									# info.json name
out.write(u"  englishName TEXT NULL,\n")								# info.json nameEnglish
out.write(u"  localizedName TEXT NULL,\n")								# Google Translate API		
out.write(u"  direction TEXT CHECK (direction IN('ltr','rtl')) default('ltr'),\n") # info.json dir
out.write(u"  script TEXT NULL,\n")										# info.json script
out.write(u"  country TEXT NULL REFERENCES Country(code),\n")			# info.json countryCode
out.write(u"  s3Bucket TEXT NOT NULL,\n")								# this program
out.write(u"  s3KeyPrefix TEXT NOT NULL,\n")							# info.json filename
out.write(u"  s3Key TEXT NULL,\n")										# %I_%O_%B_%C.html
# I cannot find program, which generated this template: s3KeyTemplate.py
out.write(u"  s3CredentialId TEXT NULL,\n")								# TBD
out.write(u"  otDamId TEXT NULL,\n")									# TBD
out.write(u"  ntDamId TEXT NULL,\n")									# TBD
out.write(u"  ssFilename TEXT NULL);\n")								# TBD

prefix2 = "INSERT INTO Bible (bibleId, code, abbr, iso3, name, englishName, direction, script, country, s3Bucket, s3KeyPrefix, s3Key) VALUES"

# read and process all info.json files
source = "/Users/garygriswold/ShortSands/DBL/FCBH_info/"
filelist = sorted(os.listdir(source))
for filename in filelist:
	#if len(filename) != 28:
		#print(len(filename), filename)
	#else:
	if len(filename) == 28:
		#print(filename)
		input2 = io.open(source + filename, mode="r", encoding="utf-8")
		data = input2.read()
		bible = json.loads(data)
		bibleId = filename[5:18]

		# check type to see if == bible
		bType = bible['type']
		if bType != 'bible':
			print "?? Type = ", bType

		# check abbr to see if different from bibleId
		code = bible['abbr']

		# remove lang code from abbr
		abbr = code[3:]

		# check that lang == first 3 letters of bibleId
		iso3 = bible['lang']

		if iso3.upper() != code[0:3]:
			print "?? abbr=", code, "  iso3=", iso3

		iso3 = iso3.lower()
		name = bible['name'].replace("'", "''")
		englishName = bible['nameEnglish'].replace("'", "''")
		direction = bible['dir']

		# convert script to iso 15924 code
		script = bible.get('script')

		validScripts = [None, 'Arab', 'Beng', 'Bugi', 'Cans', 'Cyrl', 'Deva', 'Ethi', 'Geor', 
		'Hans', 'Hant', 'Java', 'Kore', 'Latn', 'Orya', 'Syrc', 'Taml', 'Thai' ]
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
				script = None
			else:
				print "ERROR: unknown script code", script, filename
		script = "'" + script + "'" if script != None else 'null'

		country = bible.get('countryCode')
		country = "'" + country.upper() + "'" if len(country) > 0 else 'null'

		bucket = "dbp-prod"
		keyPrefix = filename.replace("info.json", "").replace(":", "/")
		s3Key = '%I_%O_%B_%C.html'

		out.write("%s ('%s', '%s', '%s', '%s', '%s', '%s', '%s', %s, %s, '%s', '%s', '%s');\n" % 
		(prefix2, bibleId, code, abbr, iso3, name, englishName, direction, script, country, bucket, keyPrefix, s3Key))

out.close()