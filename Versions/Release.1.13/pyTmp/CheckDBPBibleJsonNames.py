#
# Verify the Bible names in Bible.json file by doing a translate back to English
# using Google translate.
#
import httplib
import urllib
import sys
import io
import json
import os
import sqlite3

db = sqlite3.connect('Versions.db')
cursor = db.cursor()

def lookupIso3Language(iso3):
	sql = "SELECT iso1 FROM Language WHERE iso3 = ?"
	values = (iso3, )
	cursor.execute(sql, values)
	row = cursor.fetchone()
	return row[0] if row != None else None

def generateRequest(langCode, name):
	line = u'{ "source":"%s", "target":"en", "q":"%s" }' % (langCode, name)
	return line


# submits a request to Google for translation
def getTranslation(body):
	conn = httplib.HTTPSConnection("translation.googleapis.com")
	path = "/language/translate/v2?key=AIzaSyAl5-Sk0A8w7Qci93-SIwerWS7lvP_6d_4"
	headers = {"Content-Type": "application/json; charset=utf-8"}
	content = body.encode('utf-8')
	try:
		conn.request("POST", path, content, headers)
		response = conn.getresponse()
		print response.status, response.reason
		return response
	except Exception, err:
		print "Error: ", str(err), body
		return None


out = io.open("CheckDBPBibleJsonNames.out", mode="w", encoding="utf-8")

# read and process all info.json files
source = "metadata/FCBH/bible.json"
input2 = io.open(source, mode="r", encoding="utf-8")
data = input2.read()
bibles = json.loads(data)['data']
for bible in bibles:
	#print bible
	bibleId = bible['abbr']
	iso3 = bible['iso']
	language = bible['language']
	englishName = bible['name']
	name = bible['vname']
	print bibleId, iso3, language, englishName, name
	iso1 = lookupIso3Language(iso3)

	if iso1 != None:
		request = generateRequest(iso1, name)
		print request, type(request)
		response = getTranslation(request)
		if response == None:
			translation = "ERROR in Google Translate"
		elif response.status != 200:
			translation = response.status
		else:
			obj = json.JSONDecoder().decode(response.read())
			print obj
			translations = obj["data"]["translations"]
			translation = translations[0]['translatedText']

		out.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\n" %
		(bibleId, language, iso3, iso1, englishName, name, translation))

out.close()
db.close()
