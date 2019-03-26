# This program reads files in data/KOGVideo and loads them into the Video table
# to populate the description column

import io
import os
import sqlite3

db = sqlite3.connect("Versions.db")
cursor = db.cursor()
source = "data/KOGVideo/"
filelist = sorted(os.listdir(source))
for filename in filelist:
	if filename[0:4] == 'KOG_':
		#print filename
		name = filename.split(".")[0]
		parts = name.split("-")
		mediaId = parts[0]
		languageId = parts[1].lower()
		print mediaId, languageId
		input = io.open(source + filename, mode="r", encoding="utf-8")
		description = input.read()
		cursor.execute("UPDATE Video SET description = ? WHERE mediaId = ? AND languageId = ?",
			(description, mediaId, languageId,))
		db.commit()
		input.close()

db.close()


