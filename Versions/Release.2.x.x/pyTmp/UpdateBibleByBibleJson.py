#
# This program is for reading the Bible.json file into SQL,
# so that it can be used to update the Bible table
# This is not currently being used. GNG 9/3/18
#
import io
import json
import sqlite3

# read and process bible.json
input = io.open("metadata/FCBH/bible.json", mode="r", encoding="utf-8")
data = input.read()
print "Counted", len(data), "chars."
bibles = json.loads(data)['data']

typeSet = set()
db = sqlite3.connect('Versions.db')
cursor = db.cursor()

abbrUpdateCount = 0
iso3UpdateCount = 0
nameUpdateCount = 0
englishUpdateCount = 0
mismatchCount = 0

for bible in bibles:
	bibleId = bible['abbr']
	abbr = bibleId[3:]
	iso3 = bible['iso']
	name = bible['name'].replace("\\", "").replace("'", "''")
	englishName = name
	vname = bible['vname']
	if type(vname) is unicode and len(vname) > 0:
		name = vname.replace("\\", "").replace("'", "''")
	filesets = bible['filesets']['dbp-dev']
	sql = "SELECT bibleId, abbr, iso3, name, englishName FROM Bible WHERE bibleId = ?"
	values = (bibleId, )
	cursor.execute(sql, values)
	row = cursor.fetchone()
	if row != None:
		if bibleId != row[0]:
			print "Error BibleIds do not match:", bibleId, row[0]
		if abbr != row[1]:
			print "Abbr does not match:", abbr, "->", row[1], bibleId
			cursor.execute("UPDATE Bible set abbr = ? WHERE bibleId = ?", (abbr, bibleId, ))
			db.commit()
			abbrUpdateCount += 1
		if iso3 != row[2]:
			print "iso3 does not match:", iso3, "->", row[2], bibleId
			cursor.execute("UPDATE Bible set iso3 = ? WHERE bibleId = ?", (iso3, bibleId, ))
			db.commit()
			iso3UpdateCount += 1
		if name != row[3]:
			print "name does not match:", name, "->", row[3], bibleId
			cursor.execute("UPDATE Bible set name = ? WHERE bibleId = ?", (name, bibleId, ))
			db.commit()
			nameUpdateCount += 1
		if englishName != row[4]:
			print "englishName does not match:", englishName, "->", row[4], bibleId
			cursor.execute("UPDATE Bible set englishName = ? WHERE bibleId = ?", (englishName, bibleId, ))
			db.commit()
			englishUpdateCount += 1
	else:
		print "No match", bibleId
		mismatchCount += 1

	#out.write("%s ('%s', '%s', '%s', '%s', '%s');\n" % (prefix, bibleId, abbr, iso3, name, englishName))
	#break

input.close()
db.close()

print '****** Unique Types ******'
for f in typeSet:
	print f
print "abbrUpdateCount=", abbrUpdateCount
print "iso3UpdateCount=", iso3UpdateCount
print "nameUpdateCount=", nameUpdateCount
print "englishUpdateCount=", englishUpdateCount
print "idMismatchCount=", mismatchCount

