# The Bible table has been created from info.json files
# This program reads that table and dbp-prod in order to compare to insure correctness
# and to find audio files related to the text files.
# 1. Read dbp-prod and build two maps of bibleId's and damId's one for text another for audio
# 2. Read Bible and build a map of bibleId's
# 3. Iterate over dbpTextMap and lookup bibleMap, and report entries not found
# 4. Iterate over bibleMap and lookup dbpTextMap, and report entries not found
# 5. Iterate over dbpAudioMap and lookup bibleMap, and report entries not found
# 6. Iterate over bibleMap and lookup dbpAudioMap, and report entries not found
# 7. When bibleMap matches dbpAudioMap, find the damIds and collection codes
# 8. Select the dramatic audio when it exists, generate update statement to update Bible with audio damId's

import io
import json
import sqlite3

dbpTextMap = {}
dbpAudioMap = {}
bibleMap = {}
codeMap = {}
input = io.open("metadata/FCBH/dbp_prod.txt", mode="r", encoding="utf-8")
for line in input:
	line = line.strip()
	parts = line.split("/")
	if parts[0] == 'text' and len(parts) > 3 and len(parts[1]) == 6 and len(parts[2]) == 6:
		key = parts[1] + ":" + parts[2]
		dbpTextMap[key] = line

	elif parts[0] == 'audio' and len(parts) > 3 and len(parts[1]) == 6 and len(parts[2]) >= 6:
		key = parts[1]# + ":" + parts[2][0:6]
		dbpAudioMap[key] = line

	elif parts[0] in ['app', 'fonts', 'languages', 'mp3audiobibles2', 'test.txt']:
		# do nothing
		a = 1

	#else:
	#	print line

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


db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT bibleId, code, abbr, iso3 FROM Bible ORDER BY code"
##values = (bibleId, )
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()

for row in rows:
	bibleId = row[0]
	bibleMap[bibleId] = row
	code = row[1]
	codeMap[code] = row
	#print "Bible", code, row

db.close()

#exit()

count = 0
for key, row in bibleMap.items():
	count += 1
	#print key, row
print "Bible Count=", count

# Iterate over dbpTextMap, lookup in bibleMap, and report missing entries
count = 0
for key, line in dbpTextMap.items():
	if key not in bibleMap:
		count += 1
		print "In dbpText, but not in Bible table", line
print "Count In dbpText, but not in Bible table", count

# Iterate over bibleMap, lookup in dbpTextMap, and report missing entries
count = 0
for key, row in bibleMap.items():
	if key not in dbpTextMap:
		count += 1
		print "In bible table, not in dbpText", row
print "Count In bible table, not in dbpText", count

# Iterate over bibleMap, lookup in dbpAudioMap to match, and report missing
inCount = 0
outCount = 0
for key, line in dbpAudioMap.items():
	if key in codeMap:
		inCount += 1
		parts = line.split("/")
		print "match audio", key, parts[2]
	else:
		outCount += 1
		#print "In dbpAudio, not in Bible table", line
print "Count in both dbpAudio and Bible table", inCount
print "Count In dbpAudio, not in Bible table", outCount

# Iterate over bibleMap, lookup in dbpAudioMap, and report missing entries
count = 0
#for key, row in bibleMap.items():
for key, row in codeMap.items():
	if key not in dbpAudioMap:
		count += 1
		#print "In Bible table, not in dbpAudio", row
print "Count In Bible table, not in dbpAudio", count
