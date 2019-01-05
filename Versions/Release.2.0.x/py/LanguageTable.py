#
# This program generates SQL statements to create and populate the Language table
# It reads SIL provided 639 tables to do this
#
# iso-639-3.txt
#	tab delimited, line 1 is heading
#	0. iso3
#	1. iso2B
#	2. iso2T
#	3. iso1
#	4. scope I=individual, M=metalanguage
#	5. type L, E, C, H, A
#	6. name
#
# iso-639-3-macrolanguages.txt
#	tab delimited, line 1 is heading
#	0. macro iso
#	1. iso
#	2. status A
#

import io

macroMap = {}
# Read in macrolanguage table, and create table of macro codes iso : macro
input1 = io.open("metadata/iso-639-3/iso-639-3-macrolanguages.txt", mode="r", encoding="utf-8")
for line in input1:
    row = line.split("\t")
    macroMap[row[1]] = row[0]
input1.close()

iso1Map = {}
isoTable = []
# Read in 639 table, lookup in macro table, add macro to table and create a map for ios1
input2 = io.open("metadata/iso-639-3/iso-639-3.txt", mode="r", encoding="utf-8")
for line in input2:
	row = line.split("\t")
	iso = row[0]
	if (iso != "Id"):
		iso1 = row[3]
		if (len(iso1) > 0):
			iso1Map[iso] = iso1
		name = row[6]
		macro = macroMap.get(iso, "")
		isoTable.append([iso, iso1, macro, name])
input2.close()

out = io.open("sql/language.sql", mode="w", encoding="utf-8")

out.write(u"DROP TABLE IF EXISTS Language;\n")
out.write(u"CREATE TABLE Language (\n")
out.write(u"  iso3 TEXT NOT NULL PRIMARY KEY,\n")
out.write(u"  iso1 TEXT NULL,\n")
out.write(u"  macro TEXT NULL,\n")
out.write(u"  name TEXT NOT NULL);\n")
prefix = "REPLACE INTO Language (iso3, iso1, macro, name) VALUES"

# Output table, and looking ios1 for any language with a macro language
for lang in isoTable:
	iso3 = lang[0]
	iso1 = lang[1]
	macro = lang[2]
	name = lang[3].replace("\\", "").replace("'", "''")
	if (len(iso1) == 0):
		iso1 = iso1Map.get(macro, "")
	iso3 = "'" + iso3 + "'"
	iso1 = "'" + iso1 + "'" if (len(iso1) > 0) else 'null'
	macro = "'" + macro + "'" if (len(macro) > 0) else 'null'
	name = "'" + name + "'"
	out.write("%s (%s, %s, %s, %s);\n" % (prefix, iso3, iso1, macro, name))

out.close()




