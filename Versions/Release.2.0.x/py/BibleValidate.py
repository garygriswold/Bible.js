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
sql = "SELECT bibleId, abbr, iso3, s3KeyPrefix, otDamId, ntDamId FROM Bible2 ORDER BY bibleId"
##values = (bibleId, )
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()

for row in rows:
	bibleId = row[0]
	s3KeyPrefix = row[3]
	otDamId = row[4]
	ntDamId = row[5]

	if s3KeyPrefix != None and s3KeyPrefix not in textSet:
		print "missing text", bibleId, s3KeyPrefix
	#else:
	#	print "*** found", bibleId, s3KeyPrefix

	if otDamId != None and otDamId not in audioSet:
		print "missing ot audio", bibleId, otDamId

	if ntDamId != None and ntDamId not in audioSet:
		print "missing nt audio", bibleId, ntDamId

db.close()