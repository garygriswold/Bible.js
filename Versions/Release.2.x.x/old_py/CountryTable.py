#
# This program generates SQL statements to create and populate the Country table
# This table is only for informational purposes in working with language / locale data
#
import io

out = io.open("sql/country.sql", mode="w", encoding="utf-8")

out.write(u"DROP TABLE IF EXISTS Country;\n")
out.write(u"CREATE TABLE Country (\n")
out.write(u"  code TEXT NOT NULL PRIMARY KEY,\n")
out.write(u"  name TEXT NOT NULL);\n")

prefix = "INSERT INTO Country (code, name) VALUES"

input = io.open("metadata/sil/CountryCodes.tab", mode="r", encoding="utf-8")
for line in input:
    row = line.split("\t")
    if (len(row[0]) == 2):
    	out.write("%s ('%s', '%s');\n" % (prefix, row[0], row[1]))
input.close()
out.close()

