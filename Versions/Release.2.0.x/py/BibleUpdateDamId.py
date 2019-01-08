# The Bible table has been created from info.json files
# This program reads that table and dbp-prod in order to compare to insure correctness
# and to find audio files related to the text files.
# 1. Read dbp-prod and build two maps of bibleId's and damId's one for text another for audio
# 2. Read Bible and build a map of bibleId's
# 3. Iterate over dbpAudioMap and lookup bibleMap, and report entries not found
# 4. Iterate over bibleMap and lookup dbpAudioMap, and report entries not found
# 5. When bibleMap matches dbpAudioMap, find the damIds and collection codes
# 6. Select the dramatic audio when it exists, generate update statement to update Bible with audio damId's

import io
import json
import sqlite3

output = io.open("sql/bible_damId_update.sql", mode="w", encoding="utf-8")

# build map of dbp text resources
dbpTextMap = {}
input = io.open("metadata/FCBH/dbp_text.txt", mode="r", encoding="utf-8")
for line in input:
	line = line.strip()
	parts = line.split(" ")
	dbpTextMap[parts[1]] = parts

input.close()

# build map of dbp audio resources
dbpAudioMap = {}
input = io.open("metadata/FCBH/dbp_audio.txt", mode="r", encoding="utf-8")
for line in input:
	line = line.strip()
	parts = line.split(" ")
	dbpAudioMap[parts[0]] = parts

input.close()

#count = 0
#for key, line in sorted(dbpTextMap.items()):
#	count += 1
#	print "text", key, line
#print "Text Count=", count

#count = 0
#for key, line in sorted(dbpAudioMap.items()):
#	count += 1
#	print "audio", key, line
#print "Audio Count=", count

bibleMap1 = {}
bibleMap2 = {}
db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT bibleId, code, abbr, iso3 FROM Bible ORDER BY code"
##values = (bibleId, )
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()

for row in rows:
	#code = row[1]
	bits = row[0].split(":")
	#code = bits[1]
	bibleMap1[bits[0]] = row
	bibleMap2[bits[1]] = row

db.close()

#count = 0
#for key, row in sorted(bibleMap.items()):
#	count += 1
#	print key, row
#print "Bible Count=", count

# Iterate over bibleMap, lookup in dbpAudioMap to match, and report missing
inCount = 0
outCount = 0
for key, lines in sorted(dbpAudioMap.items()):
	if key in bibleMap1 or key in bibleMap2:
		inCount += 1
		if key in bibleMap1:
			bibleId = bibleMap1[key][0]
		else:
			bibleId = bibleMap2[key][0]
		print "match audio", key, lines
		damIds = sorted(lines[1:])
		#print damIds
		oldTest = None
		newTest = None
		partTest = None
		for damId in damIds:
			if len(damId) == 10:
				collection = damId[6:7]
				#print collection
				if collection == 'O':
					oldTest = damId
				elif collection == 'N':
					newTest = damId
				elif collection == 'P':
					partTest = damId
				else:
					print "*******", collection

		sql = "UPDATE Bible SET %s = '%s' WHERE bibleId = '%s';\n"	
		if oldTest != None:
			output.write(sql % ('otDamId', oldTest, bibleId))
		if newTest != None:
			output.write(sql % ('ntDamId', newTest, bibleId))
		#if partTest != None:
		#	output.write(sql % ('partDamId', partTest, bibleId))

		print key, oldTest, newTest, partTest
		output.write(u"")


	else:
		outCount += 1
		#print "In dbpAudio, not in Bible table", lines
print "Count in both dbpAudio and Bible table", inCount
print "Count In dbpAudio, not in Bible table", outCount

output.close()

# Iterate over bibleMap, lookup in dbpAudioMap, and report missing entries
count = 0
for key, row in sorted(bibleMap1.items()):
	if key not in dbpAudioMap:
		count += 1
		#print "In Bible table, not in dbpAudio", row
print "Count In Bible table, not in dbpAudio", count
