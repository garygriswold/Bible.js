#
# Verify the Bible names in info.json files by doing a translate back to English
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

def generateRequest2(langCode, name):
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


out = io.open("CheckInfoJsonNames.out", mode="w", encoding="utf-8")

# read and process all info.json files
source = "/Users/garygriswold/ShortSands/DBL/FCBH_info/"
for filename in os.listdir(source):
	if filename[0] != ".":
		input2 = io.open(source + filename, mode="r", encoding="utf-8")
		displayName = filename.replace(":", "/")
		data = input2.read()
		bible = json.loads(data)
		bibleId = bible['id']
		iso3 = bible['lang'].lower()
		name = bible['name'].replace("'", "''")
		englishName = bible['nameEnglish'].replace("'", "''")
		script = bible.get('script')
		validScripts = [None, 'Arab', 'Beng', 'Cyrl', 'Deva', 'Ethi', 'Geor', 'Latn', 'Orya', 'Syrc', 'Taml', 'Thai' ]
		if script in validScripts:
			a = 1
		else:
			if script == 'Latin':
				script = 'Latn'
			elif script == 'Cyrillic':
				script = 'Cyrl'
			elif script == 'Arabic':
				script = 'Arab'
			elif script == 'Devangari':
				script = 'Deva'
			elif script == 'Devanagari (Nagari)':
				script = 'Deva'
			elif script == 'CJK':
				script = ''
			else:
				print "ERROR: unknown script code", script, filename

		country = bible.get('countryCode')

		iso1 = lookupIso3Language(iso3)

		if iso1 != None:
			request = generateRequest2(iso1, name)
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

			out.write("%s\t%s\t%s\t%s-%s-%s\t%s\t%s\t%s\n" %
			(displayName, bibleId, iso3, iso1, script, country, englishName, name, translation))

out.close()
db.close()
