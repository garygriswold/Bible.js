#
# This program generates SQL statements to create and populate the Bible table
# This was previously called the Version table
#
import io
import os
import json

def checkNull(field):
	if field == None:
		return "null"
	else:
		return "'" + field.replace("'", "''") + "'"



out = io.open("sql/bible2.sql", mode="w", encoding="utf-8")

out.write(u"DROP TABLE IF EXISTS Bible2;\n")
out.write(u"CREATE TABLE Bible2 (\n")
out.write(u"  bibleId TEXT NOT NULL PRIMARY KEY,\n") 					# bible.json abbr
out.write(u"  abbr TEXT NOT NULL,\n")									# bible.json abbr char 4-6
out.write(u"  iso3 TEXT NOT NULL REFERENCES Language(iso3),\n")			# bible.json iso
out.write(u"  name TEXT NULL,\n")										# bible.json vname
out.write(u"  englishName TEXT NULL,\n")								# bible.json name
out.write(u"  localizedName TEXT NULL,\n")								# Google Translate API		
out.write(u"  direction TEXT NULL CHECK (direction IN('ltr','rtl')),\n")# TBD
out.write(u"  script TEXT NULL,\n")										# TBD
out.write(u"  country TEXT NULL REFERENCES Country(code),\n")			# TBD
out.write(u"  s3Bucket TEXT NOT NULL,\n")								# bible.json filesets
out.write(u"  s3KeyPrefix TEXT NULL,\n")								# TBD
out.write(u"  s3Key TEXT NOT NULL,\n")									# %I_%O_%B_%C.html
out.write(u"  otDamId TEXT NULL,\n")									# BibleUpdateDamId.py
out.write(u"  ntDamId TEXT NULL,\n")									# BibleUpdateDamId.py
out.write(u"  stylesheet TEXT NULL);\n")								# this program 

prefix2 = "INSERT INTO Bible2 (bibleId, abbr, iso3, name, englishName, s3Bucket, s3Key, otDamId, ntDamId, stylesheet) VALUES"

# read and process bible.json file created by Bibles query from DBPv4
input = io.open("metadata/FCBH/bible2.json", mode="r", encoding="utf-8")
data = input.read()
try:
	bibles = json.loads(data)['data']
except Exception, err:
	print "Could not parse bible.json", str(err)
input.close()

for bible in bibles:
	bibleId = checkNull(bible["abbr"])
	abbr = checkNull(bible["abbr"][4:])
	iso3 = checkNull(bible["iso"])
	name = checkNull(bible["vname"])

	englishName = checkNull(bible["name"])
	buckets = bible["filesets"]
	audioOTDrama = None
	audioNTDrama = None
	audioOT = None
	audioNT = None
	for bucket, resources in buckets.items():
		#print bucket
		for resource in resources:

			if len(resource["id"]) == 10:
				if resource["size"] == "OT":
					if resource["type"] == "audio_drama":
						audioOTDrama = resource["id"]
					if resource["type"] == "audio":
						audioOT = resource["id"]

				if resource["size"] == "NT":
					if resource["type"] == "audio_drama":
						audioNTDrama = resource["id"]
					if resource["type"] == "audio":
						audioNT = resource["id"]

	# coming back to this tab assumes there is only one bucket
	otDamId = audioOT
	if audioOTDrama != None:
		otDamId = audioOTDrama
	otDamId = checkNull(otDamId)

	ntDamId = audioNT
	if audioNTDrama != None:
		ntDamId = audioNTDrama 
	ntDamId = checkNull(ntDamId)

	#print bibleId, abbr, iso3, name, englishName

	s3Key = "%I_%O_%B_%C.html"

	if bucket == "dbp-prod":
		stylesheet = "BibleApp2.css"
	else:
		stylesheet = None

	out.write("%s (%s, %s, %s, %s, %s, '%s', '%s', %s, %s, '%s');\n" % 
	(prefix2, bibleId, abbr, iso3, name, englishName, bucket, s3Key, otDamId, ntDamId, stylesheet))

out.close()
