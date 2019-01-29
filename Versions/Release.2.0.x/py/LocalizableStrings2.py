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
# https://developer.apple.com/videos/play/wwdc2018/404/
#
import httplib
import io
import os
import sys
import json
import xml.dom.minidom

sourceDir = "/Users/garygriswold/Downloads/SafeBible/"

# item 0 is Apple code for language
# item 1 is Google code for language
# item 2 is common name for language
languages = {
	'ar': ['ar', 'Arabic'],
	'ca': ['ca', 'Catalan'],
	'zh-Hans': ['zh-CN', 'Chinese Simplified'],
	'zh-Hant': ['zh-TW', 'Chinese Traditional'],
	'hr': ['hr', 'Croatian'],
	'cs': ['cs', 'Czech'],
	'da': ['da', 'Danish'],
	'nl': ['nl', 'Dutch'],
	'fi': ['fi', 'Finnish'],
	'fr': ['fr', 'French'],
	'de': ['de', 'German'],
	'el': ['el', 'Greek'],
	'he': ['he', 'Hebrew'],
	'hi': ['hi', 'Hindi'],
	'hu': ['hu', 'Hungarian'],
	'id': ['id', 'Indonesian'],
	'it': ['it', 'Italian'],
	'ja': ['ja', 'Japanese'],
	'ko': ['ko', 'Korean'],
	'ms': ['ms', 'Malay'],
	'nb': ['no', 'Norwegian Bokmal'], # changed nb to no
	'pl': ['pl', 'Polish'],
	'pt-BR': ['pt', 'Portuguese Brazil'],
	'pt-PT': ['pt', 'Portuguese'],
	'ro': ['ro', 'Romanian'],
	'ru': ['ru', 'Russian'],
	'sk': ['sk', 'Slovak'],
	'es': ['es', 'Spanish'],
	'es-419': ['es', 'Spanish Latin Amer'], # same as Spanish
	'sv': ['sv', 'Swedish'],
	'th': ['th', 'Thai'],
	'tr': ['tr', 'Turkish'],
	'uk': ['uk', 'Ukrainian'],
	'vi': ['vi', 'Vietnamese']
}

# This function returns an array of child elements
def getChildElements(node):
	elements = []
	for item in node.childNodes:
		if item.nodeType == item.ELEMENT_NODE:
			elements.append(item)
	return elements

# Parse an XLIFF file to extract keys, and comments to be translated
#[ Key, Source, hasTarget]
#def parseXLIFF(langCode):
def parseXLIFF(doc):
	parsedFile = []
	body = doc.getElementsByTagName("body")[1]
	for transUnit in body.childNodes:
		if transUnit.nodeType == transUnit.ELEMENT_NODE:
			key = transUnit.getAttribute("id")
			children = getChildElements(transUnit)
			if children[0].nodeName == "source":
				source = children[0].firstChild.nodeValue
				print "source=", source
			else:
				print "source is not first child", transUnit.toxml()
				exit()
			hasTarget = (children[1].nodeName == "target")
			parsedFile.append([key, source, hasTarget])
	return parsedFile

# generate a request message
def generateRequest(parsedFile, langCode):
	request = '{ "source":"en", "target":"' + langCode + '"'
	for item in parsedFile:
		request += ', "q":"' + item[1] + '"'
	request += ' }'
	return request

# submit a request to Google for translation
def getTranslation(body):
	conn = httplib.HTTPSConnection("translation.googleapis.com")
	path = "/language/translate/v2?key=AIzaSyAl5-Sk0A8w7Qci93-SIwerWS7lvP_6d_4"
	headers = {"Content-Type": "application/json; charset=utf-8"}
	conn.request("POST", path, body, headers)
	response = conn.getresponse()
	print response.status, response.reason
	obj = json.JSONDecoder().decode(response.read())
	translations = obj["data"]["translations"]
	return translations

# generate result and update the XML Document with translated text
def updateXliff(doc, parsedFile, translations):
	index = -1
	body = doc.getElementsByTagName("body")[1]
	for transUnit in body.childNodes:
		if transUnit.nodeType == transUnit.ELEMENT_NODE:
			children = getChildElements(transUnit)
			numChildren = len(children)
			index += 1
			parsedItem = parsedFile[index]
			hasTarget = parsedItem[2]
			if hasTarget:
				print "NodeName", parsedItem[0]
				#target = children[1]
				children[1].innerHTML = translations[index]['translatedText']
			else:
				target = doc.createElement("target")
				target.innerHTML = translations[index]['translatedText']
				transUnit.insertBefore(target, children[numChildren - 1])
			#translatedText = doc.createTextNode(translations[index]['translatedText'])	
			#target.innerHTML = translatedText
			#target.innerHTML = translations[index]['translatedText']
			

for langDir in os.listdir(sourceDir):
	if langDir[-6:] == ".xcloc":
		appleLang = langDir[0:-6]
		print appleLang
		filename = sourceDir + langDir + "/Localized Contents/" + appleLang + ".xliff"
		print filename
		xmlDoc = xml.dom.minidom.parse(filename)
		#print xmlDoc.toxml("utf-8")
		parsedFile = parseXLIFF(xmlDoc)
		print parsedFile
		googleLang = languages[appleLang][0]
		print googleLang
		request = generateRequest(parsedFile, googleLang)
		print request
		translations = getTranslation(request)
		print translations
		if len(translations) != len(parsedFile):
			print("num translations not correct", len(translations), len(parsedFile))
			sys.exit()
		updateXliff(xmlDoc, parsedFile, translations)
		print xmlDoc.toxml("utf-8")
		output = io.open(filename + ".out", mode="w", encoding="utf-8")
		output.write(xmlDoc.toxml())
		output.close()

