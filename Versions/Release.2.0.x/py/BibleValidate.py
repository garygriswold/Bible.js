# This program reads the Bible table, and looks up the keys in dbp_prod.txt
# It reports any that it does not find.

import io
import sqlite3

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
sql = "SELECT bibleId, abbr, iso3, textId, otDamId, ntDamId FROM Bible ORDER BY bibleId"
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()

for row in rows:
	bibleId = row[0]
	textId = row[3]
	textKey = "text/" + bibleId + "/" + textId + "/" if textId != None else None
	otDamId = row[4]
	otKey = "audio/" + bibleId + "/" + otDamId + "/" if otDamId != None else None
	ntDamId = row[5]
	ntKey = "audio/" + bibleId + "/" + ntDamId + "/" if ntDamId != None else None

	if textKey != None and textKey not in textSet:
		print "missing text", bibleId, textKey

	if otKey != None and otKey not in audioSet:
		print "missing ot audio", bibleId, otKey

	if ntKey != None and ntKey not in audioSet:
		print "missing nt audio", bibleId, ntKey

db.close()