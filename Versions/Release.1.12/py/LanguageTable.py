#
# This program generates SQL statements to create and populate the Language table
#
import sys
import io
import json

out = io.open("sql/language.sql", mode="w", encoding="utf-8")

#line1 = "DROP TABLE IF EXISTS Language;\n".encode('utf-8')
#out.write(line1)
out.write(u"DROP TABLE IF EXISTS Language;\n")
out.write(u"CREATE TABLE Language (\n")
out.write(u"  iso TEXT NOT NULL PRIMARY KEY,\n")
out.write(u"  name TEXT NOT NULL,\n")
out.write(u"  iso1 TEXT NULL,\n")
out.write(u"  english TEXT NULL);\n")
prefix = "INSERT INTO Language (iso, name, iso1, english) VALUES"

data = sys.stdin.read()
print "Counted", len(data), "chars."
langs = json.loads(data)

for lang in langs:
	iso = lang['language_iso']
	name = lang['language_name'].replace("\\", "").replace("'", "''")
	iso1 = lang['language_iso_1']
	english = lang['english_name'].replace("\\", "").replace("'", "''")
	iso1 = 'null' if (iso1 is None or len(iso1) == 0) else  "'" + iso1 + "'"
	english = 'null' if (english is None or english == name) else "'" + english + "'"
	line = "%s ('%s', '%s', %s, %s)\n" % (prefix, iso, name, iso1, english)
	out.write(line)


	#print("%s ('%s', '%s', %s, %s)" % (prefix, iso, name.encode('utf-8'), iso1, english.encode('utf-8')))

