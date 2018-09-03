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

def generateRequest(langCode, englishName):
	request = '{ "source":"en", "target":"' + langCode + '"'
	#for item in parsedFile:
	request += ', "q":"' + englishName + '"'
	request += ' }'
	return request


# submits a request to Google for translation
def getTranslation(body):
	conn = httplib.HTTPSConnection("translation.googleapis.com")
	path = "/language/translate/v2?key=AIzaSyAl5-Sk0A8w7Qci93-SIwerWS7lvP_6d_4"
	headers = {"Content-Type": "application/json; charset=utf-8"}
	try:
		conn.request("POST", path, body, headers)
		response = conn.getresponse()
		print response.status, response.reason
		return response
	except Exception, err:
		print "Error: ", str(err), body
		return None


out = io.open("TranslatedBibleNames.out", mode="w", encoding="utf-8")
db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT b.bibleId, b.iso3, b.script, b.country, b.name, b.englishName, l.iso1, l.country, l.name"
sql += " FROM Bible b, Language l WHERE b.iso3 = l.iso3"
values = ( )
cursor.execute(sql, values)
for row in cursor:
	bibleId = row[0]
	print bibleId
	iso3 = row[1]
	script = row[2]
	bibleCountry = row[3]
	name = row[4]
	englishName = row[5].replace("[", "").replace("]", "")
	iso1 = row[6]
	langCountry = row[7]
	langName = row[8]
	if iso1 == "en":
		out.write("%s ; %s-%s-%s %s-%s %s ; %s ; %s ; %s\n" % 
			(bibleId, iso1, script, bibleCountry, iso3, langCountry, langName, englishName, name, englishName))
	else:
		request = generateRequest(iso1, englishName)
		response = getTranslation(request)
		if response != None and response.status == 200:
			obj = json.JSONDecoder().decode(response.read())
			translations = obj["data"]["translations"]
			translation = translations[0]['translatedText']
			out.write("%s ; %s-%s-%s %s-%s %s ; %s ; %s ; %s\n" % 
				(bibleId, iso1, script, bibleCountry, iso3, langCountry, langName, englishName, name, translation))
		else:
			out.write("%s ; %s-%s-%s %s-%s %s ; %s ; %s ; ??\n" % 
				(bibleId, iso1, script, bibleCountry, iso3, langCountry, langName, englishName, name))

db.close()
out.close()


## 			cursor.execute("UPDATE Bible set abbr = ? WHERE bibleId = ?", (abbr, bibleId, ))
##			db.commit()



