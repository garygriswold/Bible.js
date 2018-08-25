#
# This program is for reading the Bible.json file into SQL,
# so that it can be compared to info.json files using SQL.
#
import io
import json
import sqlite3

#out = io.open("sql/bibleJson.sql", mode="w", encoding="utf-8")

#out.write(u"DROP TABLE IF EXISTS BibleJson;\n")
#out.write(u"CREATE TABLE BibleJson (\n")
#out.write(u"  bibleId TEXT NOT NULL PRIMARY KEY,\n") 					# from id
#out.write(u"  abbr TEXT NOT NULL,\n")									# from abbr
#out.write(u"  iso3 TEXT NOT NULL REFERENCES Language(iso3),\n")			# from lang
#out.write(u"  name TEXT NOT NULL,\n")									# from name
#out.write(u"  englishName TEXT NULL);\n")								# from nameEnglish

#prefix = "INSERT INTO BibleJson (bibleId, abbr, iso3, name, englishName) VALUES"

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

