# This program reads files in data/KOGVideo and loads them into the Video table
# I first loads VideoTable.txt, which is loaded this way in order to support
# unicode escape characters.  Next, it loads some long text into the description column
# from individual files.

import io
import os
import sqlite3

db = sqlite3.connect("Versions.db")
cursor = db.cursor()
#cursor.execute(''' DELETE FROM Video WHERE mediaSource = ? ''', ('KOG',))
#db.commit()

input = io.open("data/KOGVideo/VideoTable.txt", mode="r", encoding="utf-8")
output = io.open("data/KOGVideo/VideoTable2.txt", mode="w", encoding="utf-8")
for line in input:
	#line = line.strip() 
	output.write(line)
#	if len(line) > 0 and line[0:2] != "--":
#		parts = line.split(",")
#		languageId = parts[0].strip()[1:-1]
#		mediaId = parts[1].strip()[1:-1]
#		source = parts[2].strip()[1:-1]
#		title = parts[3].strip()[1:-1]
#		print title
#		length = parts[4].strip()
#		url = parts[5].strip()[1:-1]
#		print languageId, mediaId, source
#		print title, length
#		print url
#		cursor.execute("INSERT INTO Video VALUES(?,?,?,?,?,?,?)", (languageId, mediaId, source, title, length, url, None,))
#		db.commit()
#
#
#db.close()
output.close()
input.close()

source = "data/KOGVideo/"
filelist = sorted(os.listdir(source))
for filename in filelist:
	if filename[0:4] == 'KOG_':
		print filename
		name = filename.split(".")[0]
		parts = name.split("-")
		mediaId = parts[0]
		languageId = parts[1].lower()
		print mediaId, languageId
		input = io.open(source + filename, mode="r", encoding="utf-8")
		description = input.read()
		#input.close()
		print description
		cursor.execute("UPDATE Video SET description = ? WHERE mediaId = ? AND languageId = ?",
			(description, mediaId, languageId,))
		db.commit()
		input.close()

db.close()


