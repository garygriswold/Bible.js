# This program reads the Bible table, and looks up the keys in dbp_prod.txt
# It reports any that it does not find.

import io
import sqlite3

BUCKET = "dbp-prod"
PREFIX = "arn:aws:s3:::"
output = io.open("PermissionsRequest.txt", mode="w", encoding="utf-8")

textSet = set()
audioSet = set()
input = io.open("metadata/FCBH/dbp_prod.txt", mode="r", encoding="utf-8")
for line in input:

	parts = line.split("/")
	if len(parts) > 2:
		key = parts[0] + "/" + parts[1] + "/" + parts[2] + "/"

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
	if textBucket == BUCKET:
		textId = row[2]
		if textId != None:
			textKey = "text/" + bibleId + "/" + textId + "/"
			if textKey in textSet:
				output.write(PREFIX + BUCKET + "/" + textKey + "*\n")
			else:
				print "missing text", bibleId, textKey

for row in rows:
	bibleId = row[0]
	audioBucket = row[3]
	if audioBucket == BUCKET:
		otDamId = row[4]
		if otDamId != None:
			otKey = "audio/" + bibleId + "/" + otDamId + "/"
			if otKey in audioSet:
				output.write(PREFIX + BUCKET + "/" + otKey + "*\n")
			else:
				print "missing ot audio", bibleId, otKey


		ntDamId = row[5]
		if ntDamId != None:
			ntKey = "audio/" + bibleId + "/" + ntDamId + "/"
			if ntKey in audioSet:
				output.write(PREFIX + BUCKET + "/" + ntKey + "*\n")
			else:
				print "missing nt audio", bibleId, ntKey

db.close()