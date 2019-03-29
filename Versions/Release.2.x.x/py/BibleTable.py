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

out = io.open("sql/bible.sql", mode="w", encoding="utf-8")

out.write(u"DROP TABLE IF EXISTS Bible;\n")
out.write(u"CREATE TABLE Bible (\n")
out.write(u"  bibleId TEXT NOT NULL PRIMARY KEY,\n") 					# bible.json abbr
out.write(u"  abbr TEXT NOT NULL,\n")									# bible.json abbr char 3-6
out.write(u"  iso3 TEXT NOT NULL REFERENCES Language(iso3),\n")			# bible.json iso
out.write(u"  name TEXT NULL,\n")										# bible.json vname
out.write(u"  englishName TEXT NULL,\n")								# bible.json name
out.write(u"  localizedName TEXT NULL,\n")								# Google Translate API
out.write(u"  textBucket TEXT NULL,\n")									# bible.json filesets
out.write(u"  textId TEXT NULL,\n")										# bible.json abbr/id
out.write(u"  keyTemplate TEXT NOT NULL,\n")							# %I_%O_%B_%C.html
out.write(u"  audioBucket TEXT NULL,\n")								# bible.json filesets
out.write(u"  otDamId TEXT NULL,\n")									# bible.json abbr/id
out.write(u"  ntDamId TEXT NULL,\n")									# bible.json abbr/id
out.write(u"  direction TEXT NULL CHECK (direction IN('ltr','rtl')),\n")# TBD
out.write(u"  script TEXT NULL,\n")										# TBD
out.write(u"  country TEXT NULL REFERENCES Country(code));\n")			# TBD

prefix2 = "INSERT INTO Bible (bibleId, abbr, iso3, name, englishName, textBucket, textId, keyTemplate, audioBucket, otDamId, ntDamId) VALUES"

# read and process bible.json file created by Bibles query from DBPv4
#input = io.open("metadata/FCBH/bible.json", mode="r", encoding="utf-8")
input = io.open(os.environ['HOME'] + "/ShortSands/DBL/FCBH/bible.json", mode="r", encoding="utf-8")
data = input.read()
try:
	bibles = json.loads(data)['data']
except Exception, err:
	print "Could not parse bible.json", str(err)
input.close()

for bible in bibles:
	bibleId = bible["abbr"]
	abbr = bible["abbr"][3:]
	iso3 = checkNull(bible["iso"])
	name = checkNull(bible["vname"])

	englishName = checkNull(bible["name"])
	buckets = bible["filesets"]
	textBucket = "null"
	textId = "null"
	audioBucket = "null"
	audioOTDrama = None
	audioNTDrama = None
	audioOT = None
	audioNT = None
	for bucket, resources in buckets.items():

		for resource in resources:
			rid = resource["id"]
			rtype = resource["type"]
			rscope = resource["size"]

			if rtype == "text_format":
				textId = "'" + rid + "'"
				textBucket = "'" + bucket + "'"

			if len(rid) == 10:
				audioBucket = "'" + bucket + "'"
				if rscope == "OT":
					if rtype == "audio_drama":
						audioOTDrama = rid
					if rtype == "audio":
						audioOT = rid

				if rscope == "NT":
					if rtype == "audio_drama":
						audioNTDrama = rid
					if rtype == "audio":
						audioNT = rid

	# coming back to this tab assumes there is only one bucket
	if audioOTDrama != None:
		otDamId = "'" + audioOTDrama + "'"
	elif audioOT != None:
		otDamId = "'" + audioOT + "'"
	else:
		otDamId = "null"

	if audioNTDrama != None:
		ntDamId = "'" + audioNTDrama + "'"
	elif audioNT != None:
		ntDamId = "'" + audioNT + "'"
	else:
		ntDamId = "null"

	keyTemplate = "%I_%O_%B_%C.html"

	out.write("%s ('%s', '%s', %s, %s, %s, %s, %s, '%s', %s, %s, %s);\n" % 
	(prefix2, bibleId, abbr, iso3, name, englishName, textBucket, textId, keyTemplate,
		audioBucket, otDamId, ntDamId))

out.close()
