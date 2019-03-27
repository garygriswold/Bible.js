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
iso3Map = {} # This is only needed for macro
# Read in 639 table, lookup in macro table, add macro to table and create a map for ios1
input2 = io.open("metadata/iso-639-3/iso-639-3.txt", mode="r", encoding="utf-8")
for line in input2:
	row = line.split("\t")
	iso3 = row[0]
	if (iso3 != "Id"):
		iso1 = row[3]
		name = row[6]
		macro = macroMap.get(iso3, "")
		if (len(iso1) > 0):
			iso1Map[iso1] = [iso3, macro, name]
		iso3Map[iso3] = [iso3, macro, name]
input2.close()

out = io.open("sql/language.sql", mode="w", encoding="utf-8")

out.write(u"DROP TABLE IF EXISTS Language;\n")
out.write(u"CREATE TABLE LanguageTemp (\n")
out.write(u"  locale TEXT NOT NULL PRIMARY KEY,\n")
out.write(u"  iso3 TEXT NOT NULL,\n")
out.write(u"  macro TEXT NULL,\n")
out.write(u"  name TEXT NOT NULL);\n")
prefix = "INSERT INTO Language VALUES"

# Read in the AppleLang.txt table
input3 = io.open("metadata/AppleLang.txt", mode="r", encoding="utf-8")
for line in input3:
	row = line.split("|")
	locale = row[0]
	iso1 = row[1]
	script = row[2]
	name = row[3].strip()
	#print(row[0], row[1], row[2], row[3])
	if len(iso1) == 2:
		silData = iso1Map.get(iso1, None)
		if silData == None:
			exit()
	else:
		silData = iso3Map.get(iso1, None)
		if silData == None:
			exit()
	iso3 = silData[0]
	macro = "'" + silData[1] + "'" if (silData[1] != None) else 'null'
	nameSIL = silData[2]
	print(locale, iso3, iso1, macro, script, name)

	out.write("%s ('%s', '%s', %s, '%s');\n" % (prefix, locale, iso3, macro, name))

input3.close()
out.close()


## ?? I need locale for linkage to iOS and Android
## ?? I need iso3 for linkage to DBP
## ?? Do I need iso1 and script ??
## ?? The macro code might prove useful for finding related languages, when one is not available

## ?? Skip Population For Now.  If, I use locale matching logic in iOS, I might be able to 
## totally rewrite InitialBibleSelect

