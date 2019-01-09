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
out.write(u"  s3Bucket TEXT NULL,\n")									# bible.json filesets
out.write(u"  s3KeyPrefix TEXT NULL,\n")								# bible.json id/abbr
out.write(u"  s3Key TEXT NOT NULL,\n")									# %I_%O_%B_%C.html
out.write(u"  otDamId TEXT NULL,\n")									# bible.json abbr/id
out.write(u"  ntDamId TEXT NULL,\n")									# bible.json abbr/id
out.write(u"  stylesheet TEXT NULL);\n")								# this program 

prefix2 = "INSERT INTO Bible2 (bibleId, abbr, iso3, name, englishName, s3Bucket, s3KeyPrefix, s3Key, otDamId, ntDamId, stylesheet) VALUES"

# read and process bible.json file created by Bibles query from DBPv4
input = io.open("metadata/FCBH/bible.json", mode="r", encoding="utf-8")
data = input.read()
try:
	bibles = json.loads(data)['data']
except Exception, err:
	print "Could not parse bible.json", str(err)
input.close()

for bible in bibles:
	bibleId = bible["abbr"]
	abbr = checkNull(bible["abbr"][3:])
	iso3 = checkNull(bible["iso"])
	name = checkNull(bible["vname"])

	englishName = checkNull(bible["name"])
	buckets = bible["filesets"]
	s3KeyPrefix = "null"
	audioOTDrama = None
	audioNTDrama = None
	audioOT = None
	audioNT = None
	for bucket, resources in buckets.items():
		#print bucket
		for resource in resources:
			rid = resource["id"]
			rtype = resource["type"]
			rscope = resource["size"]

			if rtype == "text_format":
				s3KeyPrefix = "'text/" + rid + "/" + bibleId + "/'"

			if len(rid) == 10:
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
		otDamId = "'audio/" + bibleId + "/" + audioOTDrama + "/'"
	elif audioOT != None:
		otDamId = "'audio/" + bibleId + "/" + audioOT + "/'"
	else:
		otDamId = "null"

	if audioNTDrama != None:
		ntDamId = "'audio/" + bibleId + "/" + audioNTDrama + "/'"
	elif audioNT != None:
		ntDamId = "'audio/" + bibleId + "/" + audioNT + "/'"
	else:
		ntDamId = "null"

	#print bibleId, abbr, iso3, name, englishName

	s3Key = "%I_%O_%B_%C.html"

	if bucket == "dbp-prod":
		stylesheet = "BibleApp2.css"
	else:
		stylesheet = None

	out.write("%s ('%s', %s, %s, %s, %s, '%s', %s, '%s', %s, %s, '%s');\n" % 
	(prefix2, bibleId, abbr, iso3, name, englishName, bucket, s3KeyPrefix, s3Key, otDamId, ntDamId, stylesheet))

out.close()
