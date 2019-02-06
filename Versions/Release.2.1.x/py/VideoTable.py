# This program reads data from the Jesus Film tables, and combined it with the Language table
# It is important to run this after the Language table has been reduced to only those
# languages that will be included in the App, so that information about the Jesus Film will
# be limited to the same languages.

import io
import sqlite3
import json
import urllib2

MEDIAID = ["1_jf-0-0", "1_wl-0-0", "1_cl-0-0"]

out = io.open("sql/video.sql", mode="w", encoding="utf-8")
out.write(u"DROP TABLE IF EXISTS Video;\n")
out.write(u"CREATE TABLE Video (\n")
out.write(u"languageId TEXT NOT NULL,\n")		# should be the Jesus languageCode or iso3 if none
out.write(u"mediaId TEXT NOT NULL,\n")			# KOG_OT, KOG_NT, 1_cl-0-0, 1_jf-0-0, 1_wl-0-0
out.write(u"mediaSource TEXT NOT NULL,\n")		# should be JFP or ROCK
out.write(u"title TEXT NOT NULL,\n")			# localized to language
out.write(u"lengthMS INT NOT NULL,\n")
out.write(u"HLS_URL TEXT NOT NULL,\n")
out.write(u"description TEXT NULL,\n")
out.write(u"PRIMARY KEY (languageId, mediaId));\n")

db = sqlite3.connect("Versions.db")
cursor = db.cursor()
sql = "SELECT distinct j.languageId, l.iso1 FROM JesusFilm j, Language l WHERE l.iso3=j.iso3 ORDER BY j.languageId"
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()
count = 0
for row in rows:
	count += 1
	languageId = row[0]
	iso1 = row[1]

	# Get Jesus Film media available for languageId
	url = "https://api.arclight.org/v2/media-components?limit=10&subTypes=featureFilm&languageIds=" 
	url += languageId + "&metadataLanguageTags=en"
	url += "&apiKey=585c557d846f52.04339341"
	try:
		answer = urllib2.urlopen(url)
		response = json.loads(answer.read())
	except Exception, err:
		print "Could not process", languageId, str(err)
	components = response["_embedded"]["mediaComponents"]
	for component in components:
		mediaId = component["mediaComponentId"]
		print mediaId
		if mediaId in MEDIAID:

			# Get Jesus Film description data from media and iso1 language code
			url = "https://api.arclight.org/v2/media-components/" + mediaId 
			url += "?metadataLanguageTags=" + iso1 + ",en"
			url += "&apiKey=585c557d846f52.04339341"
			try:
				answer = urllib2.urlopen(url)
				descrip = json.loads(answer.read())
			except Exception, err:
				print "Could not process", mediaId, str(err)
			title = descrip["title"].replace("'", "''")
			description = descrip["longDescription"].replace("'", "''").replace("\n", " ")
			lengthMS = descrip["lengthInMilliseconds"]
			print title

			# Get Jesus Film URL for media and languageId
			url = "https://api.arclight.org/v2/media-components/" + mediaId
			url += "/languages/" + languageId + "?platform=ios"
			url += "&apiKey=585c557d846f52.04339341"	
			try:
				answer = urllib2.urlopen(url)
				target = json.loads(answer.read())
			except Exception, err:
				print "Could not process", mediaId, languageId, str(err)
			HLS_URL = target["streamingUrls"]["m3u8"][0]["url"]
			print HLS_URL

			# Generate insert statement for Video table
			sql = "INSERT INTO VIDEO (languageId, mediaId, mediaSource, title, lengthMS, HLS_URL, description)"
			sql += " VALUES ('%s', '%s', 'JFP', '%s', %s, '%s', '%s');\n"
			out.write(sql % (languageId, mediaId, title, lengthMS, HLS_URL, description))

	#if count > 11:
	#	exit()

db.close()
print "rows", count

