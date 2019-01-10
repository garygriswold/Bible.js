# This program reads the Bible table, and generates a list of AWS-S3 key prefixes

import sqlite3
import io

output = io.open("PermissionsRequest.txt", mode="w", encoding="utf-8")

db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT bibleId, textBucket, textId, audioBucket, otDamId, ntDamId FROM Bible ORDER BY bibleId"
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()

for row in rows:
	bibleId = row[0]
	textBucket = row[1]
	textId = row[2]
	if textId != None:
		output.write("text/" + bibleId + "/" + textId + "/*\n")

for row in rows:
	bibleId = row[0]
	audioBucket = row[3]
	otDamId = row[4]
	if otDamId != None:
		output.write("audio/" + bibleId + "/" + otDamId + "/*\n")
	ntDamId = row[5]
	if ntDamId != None:
		output.write("audio/" + bibleId + "/" + ntDamId + "/*\n")

output.close()

