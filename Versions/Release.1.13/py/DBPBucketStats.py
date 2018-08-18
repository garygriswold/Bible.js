#
# This program reads a list of keys in a DBP bucket, and produces counts
# of the number of various kinds of objects.
#
import io

element1 = set()
bibles = dict()
input = io.open("metadata/FCBH/dbp_dev.txt", mode="r", encoding="utf-8")
for line in input:
    row = line.split("/")
    numelements = len(row)
    element1.add(row[0])
    if row[0] == "text":
    	bibleId = row[1] + "-" + str(numelements)
    	if bibleId in bibles:
    		last = row[-1].strip()
    		if last == "about.html":
    			bibles[bibleId]["about"] = "Y"
    		if last == "index.html":
    			bibles[bibleId]["index"] = "Y"
    		if last == "info.json":
    			bibles[bibleId]["info"] = "Y"
    		if last == "mobile.css":
    			bibles[bibleId]["css"] = "Y"
    		if last == "title.json":
    			bibles[bibleId]["title"] = "Y"
    		bibles[bibleId]["files"] += 1
    	else:
    		bibles[bibleId] = {}
    		bibles[bibleId]["files"] = 1

input.close()

for item in element1:
	print item

for id in bibles:
	iso3 = id[0:3].lower()
	abbr = id[3:]
	data = bibles[id]
	print id, iso3, abbr, data

#bibleIds	1136
#about.html	1352
#index.html	1378
#info.json	1347
#mobile.css	1377
#title.json	1351
