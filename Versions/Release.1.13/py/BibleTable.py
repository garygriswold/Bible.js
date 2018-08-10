#
# This program generates SQL statements to create and populate the Bible table
# This was previously called the Version table
#
import sys
import io
import json

out = io.open("sql/bible.sql", mode="w", encoding="utf-8")

out.write(u"DROP TABLE IF EXISTS Bible;\n")
out.write(u"CREATE TABLE Bible (\n")
out.write(u"  bibleId TEXT NOT NULL PRIMARY KEY,\n")
out.write(u"  abbr TEXT NOT NULL,\n")
out.write(u"  iso TEXT NOT NULL REFERENCES Language(iso),\n")
out.write(u"  name TEXT NOT NULL,\n")
out.write(u"  vname TEXT NULL,\n")
out.write(u"  date TEXT NULL,\n")
out.write(u"  recommended TEXT CHECK (recommended IN('T', 'F')) default('F'),\n")
out.write(u"  organizationId TEXT NULL REFERENCES Owner(ownerCode),\n")
out.write(u"  ssFilename TEXT NULL,\n")
out.write(u"  hasHistory TEXT CHECK (hasHistory IN('T','F')) default('F'),\n")
out.write(u"  copyright TEXT NULL,\n")
out.write(u"  introduction TEXT NULL);\n")

prefix = "INSERT INTO Bible (bibleId, abbr, iso, name, vname, date) VALUES"

data = sys.stdin.read()
print "Counted", len(data), "chars."
bibles = json.loads(data)['data']

for bible in bibles:
	bibleId = bible['abbr']
	abbr = bibleId[3:]
	iso = bible['iso']
	name = bible['name'].replace("\\", "").replace("'", "''")
	vname = bible['vname']
	if vname is None or len(vname) == 0:
		vname = 'null'
	else:
		vname = "'" + vname.replace("\\", "").replace("'", "''") + "'"
	date = bible['date']
	out.write("%s ('%s', '%s', '%s', '%s', %s, '%s');\n" % (prefix, bibleId, abbr, iso, name, vname, date))

out.close()

