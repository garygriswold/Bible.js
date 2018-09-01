#
# This program is used to generate Localizable.strings files using Google Translate
# to perform the translation.
#
import httplib
import io
import sys

sourceDir = "/Users/garygriswold/ShortSands/BibleApp/Plugins/Settings/Settings_ios/Settings/"
targetDir = "/Users/garygriswold/Downloads/"

# item 0 is Apple code for language
# item 1 is Google code for language
# item 2 is common name for language
languages = [
#['ar', 'ar', 'Arabic'],
#['ca', 'ca', 'Catalan'],
['zh-Hans', 'zh-CN', 'Chinese Simplified']#,
#['zh-Hant', 'zh-TW', 'Chinese Traditional'],
#['hr', 'hr', 'Croatian'],
#['cs', 'cs', 'Czech'],
#['da', 'da', 'Danish'],
#['nl', 'nl', 'Dutch'],
#['fi', 'fi', 'Finnish'],
#['fr', 'fr', 'French'],
#['de', 'de', 'German'],
#['el', 'el', 'Greek'],
#['he', 'he', 'Hebrew'],
#['hi', 'hi', 'Hindi'],
#['hu', 'hu', 'Hungarian'],
#['id', 'id', 'Indonesian'],
#['it', 'it', 'Italian'],
#['ja', 'ja', 'Japanese'],
#['ko', 'ko', 'Korean'],
#['ms', 'ms', 'Malay'],
#['nb', 'no', 'Norwegian Bokmal'], # changed nb to no
#['pl', 'pl', 'Polish'],
#['pt-BR', 'pt', 'Portuguese Brazil'],
#['pt-PT', 'pt', 'Portuguese'],
#['ro', 'ro', 'Romanian'],
#['ru', 'ru', 'Russian'],
#['sk', 'sk', 'Slovak'],
#['es', 'es', 'Spanish'],
#['es-419', 'es', 'Spanish Latin Amer'], # same as Spanish
#['sv', 'sv', 'Swedish'],
#['th', 'th', 'Thai'],
#['tr', 'tr', 'Turkish'],
#['uk', 'uk', 'Ukrainian'],
#['vi', 'vi', 'Vietnamese']
]

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

def generateGenericRequest(parseFile):
	request = '{ "source":"en", "target":"**"'
	for item in parsedFile:
		request += ', "q":' + item[0]
		print item
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

parsedFile = parseLocalizableString("es")
genericRequest = generateGenericRequest(parsedFile)
for lang in languages:
	appleCode = lang[0]
	googleCode = lang[1]
	request = genericRequest.replace("**", googleCode)
	print request
	response = getTranslation(request)
	print response




# Build up the Generic Google Translate Request






# Generate the body of a request

