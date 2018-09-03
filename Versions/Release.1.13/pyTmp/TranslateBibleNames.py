#
# This program is for translating Bible names that are in English
# into the language of that Bible.  It is strange that so many
# Bible names are only in English
#
import httplib
import sys
import io
import json
import sqlite3

# submits a request to Google for translation
def getTranslation(body):
	conn = httplib.HTTPSConnection("translation.googleapis.com")
	path = "/language/translate/v2?key=AIzaSyAl5-Sk0A8w7Qci93-SIwerWS7lvP_6d_4"
	headers = {"Content-Type": "application/json; charset=utf-8"}
	content = body.encode('utf-8')
	try:
		conn.request("POST", path, content, headers)
		response = conn.getresponse()
		#print response.status, response.reason
		return response
	except Exception, err:
		print "Error: ", str(err), body
		return None


out = io.open("sql/LocalizedBibleNames.sql", mode="w", encoding="utf-8")
db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT b.bibleId, b.iso3, b.name, b.englishName, l.iso1"
sql += " FROM Bible b, Language l WHERE b.iso3 = l.iso3"
values = ( )
cursor.execute(sql, values)
for row in cursor:
	bibleId = row[0]
	iso3 = row[1]
	name = row[2].replace("[", "").replace("]", "")
	englishName = row[3].replace("[", "").replace("]", "")
	iso1 = row[4]
	translated = None
	if iso1 == "en":
		translated = englishName
	elif iso1 != None:
		if englishName == None or englishName.strip() == '':
			print "ERROR no EnglishName for", bibleId
		request = u'{ "source":"en", "target":"%s", "q":"%s" }' % (iso1, englishName)
		#print request
		response = getTranslation(request)
		if response != None:
			if response.status == 200:
				obj = json.JSONDecoder().decode(response.read())
				translations = obj["data"]["translations"]
				translated = translations[0]['translatedText']
				if englishName == translated:
					print "200, but no translation ", bibleId, iso3, iso1, name, englishName
				#print bibleId, name, translated
			elif response.status == 400:
				#print "400", bibleId, name, englishName
				if name != englishName:
					translated = name
				else:
					print "400", name, englishName
					out.write("400 matching names %s\n" % bibleId)
			else:
				print "ERROR", response.status, bibleId, name, englishName
				out.write("ERROR %s %s" % response.status, name)
		else:
			print "ERROR in translation", bibleId, request
			out.write("ERROR in translation %s \n" % (bibleId))
	else:
		translated = None
		#print "No iso1 code for Translation ", bibleId
	if translated != None:
		translated = translated.replace("'", "''")
		out.write("UPDATE Bible set localizedName = '%s' WHERE bibleId = '%s'; -- %s %s %s -> %s\n" % 
		(translated, bibleId, iso1, iso3, name, englishName))

db.close()
out.close()




