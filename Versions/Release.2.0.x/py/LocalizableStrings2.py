#
# This program is used to process .xliff files and do an automated translation
# using Google translate, and insert the result into the <target> element.
# I think the translation process should skip over any element that already has a
# target element.
#
# 1. Select Languages to be localized in the xCode project
# 2. Add any new languages to the Languages array below
# 3. in xCode run Edition -> Export Localization, put into Downloads
# 4. Run this program which will update the .xliff files
# 5. For each Language inport the .xcloc directory
# PS. There are commandline options for generating and importing the language
#
#
import httplib
import io
import os
import sys
import json
import xml.dom.minidom

sourceDir = "/Users/garygriswold/Downloads/Settings/"
targetDir = "/Users/garygriswold/Downloads/Output/"

# item 0 is Apple code for language
# item 1 is Google code for language
# item 2 is common name for language
languages = [
['ar', 'ar', 'Arabic'],
['ca', 'ca', 'Catalan'],
['zh-Hans', 'zh-CN', 'Chinese Simplified'],
['zh-Hant', 'zh-TW', 'Chinese Traditional'],
['hr', 'hr', 'Croatian'],
['cs', 'cs', 'Czech'],
['da', 'da', 'Danish'],
['nl', 'nl', 'Dutch'],
['fi', 'fi', 'Finnish'],
['fr', 'fr', 'French'],
['de', 'de', 'German'],
['el', 'el', 'Greek'],
['he', 'he', 'Hebrew'],
['hi', 'hi', 'Hindi'],
['hu', 'hu', 'Hungarian'],
['id', 'id', 'Indonesian'],
['it', 'it', 'Italian'],
['ja', 'ja', 'Japanese'],
['ko', 'ko', 'Korean'],
['ms', 'ms', 'Malay'],
['nb', 'no', 'Norwegian Bokmal'], # changed nb to no
['pl', 'pl', 'Polish'],
['pt-BR', 'pt', 'Portuguese Brazil'],
['pt-PT', 'pt', 'Portuguese'],
['ro', 'ro', 'Romanian'],
['ru', 'ru', 'Russian'],
['sk', 'sk', 'Slovak'],
['es', 'es', 'Spanish'],
['es-419', 'es', 'Spanish Latin Amer'], # same as Spanish
['sv', 'sv', 'Swedish'],
['th', 'th', 'Thai'],
['tr', 'tr', 'Turkish'],
['uk', 'uk', 'Ukrainian'],
['vi', 'vi', 'Vietnamese']
]

# Parse an XLIFF file to extract keys, and comments to be translated
#[ Key, Value, None, Comment]
def parseXLIFF(langCode):
	parsedFile = []
	filename = sourceDir + langCode + ".xliff"
	doc = xml.dom.minidom.parse(filename)
	body = doc.getElementsByTagName("body")[1]
	for transUnit in body.childNodes:
		if transUnit.nodeType == transUnit.ELEMENT_NODE:
			key = transUnit.getAttribute("id")
			for item in transUnit.childNodes:
				if item.nodeType == item.ELEMENT_NODE:
					nodeName = item.nodeName
					for text in item.childNodes:
						textValue = text.nodeValue
					if nodeName == "source":
						value = textValue
					elif nodeName == "note":
						comment = textValue
			parsedFile.append([key, value, None, comment])
	return parsedFile

# Deprecated, but keep this method, it would be useful if I were writing a merge feature
# Parse a Localizable.strings file into an array of items
# [ Key, Value, None, CommentArray ]
def parseLocalizableString(langCode):
	parsedFile = []
	BEGIN = 0
	COMMENT = 1
	KEY_VALUE = 2
	state = BEGIN
	input = io.open(sourceDir + langCode + ".lproj/Localizable.strings", mode="r", encoding="utf-8")
	for line in input:
		line = line.strip()
		if len(line) == 0:
			state = state
		elif state == BEGIN:
			comment = [line]
			if line[0:2] == "/*" and line[-2:] == "*/":
				state = KEY_VALUE
			elif line[0:2] == "/*":
				state = COMMENT
			else:
				print("UNEXPECTED LINE in BEGIN " + line)
				sys.exit()
		elif state == COMMENT:
			comment.append(line)
			if line[-2:] == "*/":
				state = KEY_VALUE
		elif state == KEY_VALUE:
			parts = line.split("=")
			if len(parts) != 2:
				print("UNEXPECTED LINE in KEY_VALUE " + line)
				sys.exit()
			key = parts[0].strip()
			value = parts[1].strip()
			parsedFile.append([key, value, None, comment])
			state = BEGIN
		else:
			print("UNKNOWN STATE " + state)
	input.close()
	return parsedFile

def generateGenericRequest(parsedFile):
	request = '{ "source":"en", "target":"**"'
	for item in parsedFile:
		request += ', "q":"' + item[0] + '"'
	request += ' }'
	return request


# submits a request to Google for translation
def getTranslation(body):
	conn = httplib.HTTPSConnection("translation.googleapis.com")
	path = "/language/translate/v2?key=AIzaSyAl5-Sk0A8w7Qci93-SIwerWS7lvP_6d_4"
	headers = {"Content-Type": "application/json; charset=utf-8"}
	conn.request("POST", path, body, headers)
	response = conn.getresponse()
	print response.status, response.reason
	return response.read()

# generate result Localizable.String file and write
def generateLocalizableStringFile(langCode, parsedFile, response):
	obj = json.JSONDecoder().decode(response)
	translations = obj["data"]["translations"]
	if len(translations) != len(parsedFile):
		print("num translations not correct", len(translations), len(parsedFile))
		sys.exit()
	else:
		directory = targetDir + langCode + ".lproj/"
		if not os.path.exists(directory):
			os.mkdir(directory)
		output = io.open(directory + "Localizable.strings", mode="w", encoding="utf-8")
		for index in range(0, len(translations)):
			parsedItem = parsedFile[index]
			translation = translations[index]['translatedText']
			output.write('/* ' + parsedItem[3] + ' */\n')
			output.write('"%s" = "%s";\n\n' % (parsedItem[0], translation))
		output.close()


parsedFile = parseXLIFF("en")
#parsedFile = parseLocalizableString("en")
genericRequest = generateGenericRequest(parsedFile)
for lang in languages:
	appleCode = lang[0]
	googleCode = lang[1]
	print appleCode, googleCode
	request = genericRequest.replace("**", googleCode)
	response = getTranslation(request)
	generateLocalizableStringFile(appleCode, parsedFile, response)



