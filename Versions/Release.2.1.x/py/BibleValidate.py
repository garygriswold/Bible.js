# This program reads the Bible table, and looks up the keys in dbp_prod.txt
# It reports any that it does not find.

import io
import os
import sqlite3

BUCKET = "dbp-prod"
PREFIX = "arn:aws:s3:::"
output = io.open("PermissionsRequest.txt", mode="w", encoding="utf-8")

textSet = set()
audioSet = set()
#input = io.open("metadata/FCBH/dbp_prod.txt", mode="r", encoding="utf-8")
input = io.open(os.environ['HOME'] + "/ShortSands/DBL/FCBH/dbp_prod.txt", mode="r", encoding="utf-8")
for line in input:

	parts = line.split("/")
	if len(parts) > 2:
		key = parts[0] + "/" + parts[1] + "/" + parts[2] #+ "/"

		if key.startswith("text"):
			textSet.add(key)

		elif key.startswith("audio"):
			audioSet.add(key)

input.close()

print len(textSet), len(audioSet)

db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT bibleId, textBucket, textId, audioBucket, otDamId, ntDamId FROM Bible ORDER BY bibleId"
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()

for row in rows:
	bibleId = row[0]
	textBucket = row[1]
	#if textBucket == BUCKET:
	textId = row[2]
	if textId != None:
		if textId in textSet:
			output.write(PREFIX + BUCKET + "/" + textId + "/*\n")
		else:
			print "missing text", bibleId, textId

for row in rows:
	bibleId = row[0]
	audioBucket = row[3]
	if audioBucket == BUCKET:
		otDamId = row[4]
		if otDamId != None:
			if otDamId in audioSet:
				output.write(PREFIX + BUCKET + "/" + otDamId + "/*\n")
			else:
				print "missing ot audio", bibleId, otDamId


		ntDamId = row[5]
		if ntDamId != None:
			if ntDamId in audioSet:
				output.write(PREFIX + BUCKET + "/" + ntDamId + "/*\n")
			else:
				print "missing nt audio", bibleId, ntDamId

db.close()