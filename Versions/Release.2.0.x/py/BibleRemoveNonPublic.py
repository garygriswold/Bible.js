# This program checks the Bibles table to identify rows that are not public, and generate
# row delete transactions for them.  It does a public check by doing a lookup in
# volume_list.txt

import io
import json
import sqlite3

input = io.open("metadata/FCBH/volume_list.txt", mode="r", encoding="utf-8")
data = input.read()
try:
	volumes = json.loads(data)
except Exception, err:
	print "Could not parse volume_list.txt", str(err)
input.close()

assetIds = set()
for volume in volumes:
	damId = volume["dam_id"]
	assetIds.add(damId)

print len(assetIds)

db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT bibleId, code, abbr, iso3, otDamId, ntDamId FROM Bible ORDER BY code"
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()
for row in rows:
	
	if row[4] != None:
		otDamId = row[4].split("/")[2]
		if otDamId not in assetIds:
			print "missing", otDamId
		else:
			print "ok", otDamId
	if row[5] != None: 
		ntDamId = row[5].split("/")[2]
		if ntDamId not in assetIds:
			print "missing", ntDamId
		else:
			print "ok", ntDamId




