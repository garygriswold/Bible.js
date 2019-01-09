# This program checks the Bibles table to identify rows that are not public, and generate
# row delete transactions for them.  It does a public check by doing a lookup in
# volume_list.txt

import io
import json
import sqlite3

input = io.open("metadata/FCBH/bible.json", mode="r", encoding="utf-8")
data = input.read()
try:
	volumes = json.loads(data)['data']
except Exception, err:
	print "Could not parse volume_list.txt", str(err)
input.close()

assetIds = dict()
for volume in volumes:
	abbr = volume["abbr"]
	filesets = volume["filesets"]
	dbps = filesets["dbp-dev"]
	assets = []
	for dbp in dbps:
		damId = dbp["id"]
		assets.append(damId)
	assetIds[abbr] = assets

#print assetIds
print len(assetIds)

db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT bibleId, code, abbr, iso3, otDamId, ntDamId FROM Bible ORDER BY code"
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()
foundCount = 0
for row in rows:

	code = row[0].split(":")[0]
	if code in assetIds:
		print "found", code
		foundCount += 1

		assets = assetIds[code]
		if row[4] != None:
			otDamId = row[4].split("/")[2]
			if otDamId not in assets:
				print "missing", otDamId
			else:
				print "ok", otDamId
		if row[5] != None: 
			ntDamId = row[5].split("/")[2]
			if ntDamId not in assets:
				print "missing", ntDamId
			else:
				print "ok", ntDamId
	else:
		print "not found", code
	


print "found", foundCount
# using code 357 found
# using bibleId[1] 357 found
# using bibleId[0] 456 found




