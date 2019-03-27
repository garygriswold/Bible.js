#
# This program generates SQL statements to create and populate the ISO3Priority table
# This table is used to generate the final Language table.
#
import io

out = io.open("sql/iso3Priority.sql", mode="w", encoding="utf-8")

out.write(u"DROP TABLE IF EXISTS ISO3Priority;\n")
out.write(u"CREATE TABLE ISO3Priority (\n")
out.write(u"  iso3 TEXT NOT NULL PRIMARY KEY REFERENCES Language(iso3),\n")
out.write(u"  country TEXT NOT NULL,\n")
out.write(u"  pop REAL NOT NULL,\n")
out.write(u"  comment TEXT NULL);\n")

prefix = "INSERT INTO ISO3Priority (iso3, country, pop, comment) VALUES"

input = io.open("metadata/shortsands/iso3Priority.txt", mode="r", encoding="utf-8")
for line in input:
    row = line.split("\t")
    pop = row[2].replace("\n", "").replace("\r", "")
    comment = 'null'
    if (len(row) > 3 and len(row[3]) > 0):
    	comment = "'" + row[3] + "'"
    	comment = comment.replace("\n", "").replace("\r", "")
    out.write("%s ('%s', '%s', %s, %s);\n" % (prefix, row[0], row[1], pop, comment))
input.close()

