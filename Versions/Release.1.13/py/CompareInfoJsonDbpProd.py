#
# This program reads each info.json file, and compares the content of the
# file to the S3 keys as stored in dbp_prod.
# This is done to validate the correctness of the info.json file.
#
# In the distant future, this program might be rewritten to access
# info.json and object heads over the Internet.
#
import io
import os
import json
import sys

fontSet = set()
scriptSet = set()

# read and process all info.json files
directory = "/Users/garygriswold/ShortSands/DBL/FCBH_info/"
for filename in os.listdir(directory):
	if filename[0] != ".":
		#print filename
		input = io.open(directory + filename, mode="r", encoding="utf-8")
		data = input.read()
		try:
			info = json.loads(data)
		except Exception, err:
			print "Could not parse", str(err), filename

		# extract info.json related parts and compare to related parts
		bibleId = info['id']
		haiolaId = info.get('haiola_id', '')
		if bibleId != haiolaId:
			print "id=", bibleId, "haiola_id=", haiolaId
		type = info['type']
		if type != "bible":
			print "type=", type, bibleId
		name = info.get('name', '')
		if name == '':
			print "blank name", bibleId
		nameEnglish = info.get('nameEnglish', '')
		if nameEnglish == '':
			print "blank nameEnglish", bibleId
		hasLemma = info.get('hasLemma', '')
		if hasLemma != True and hasLemma != False:
			print "hasLemma not True or False", bibleId
		abbr = info['abbr']
		if abbr != bibleId:
			print "abbr=", abbr, "bibleId=", bibleId
		dir = info['dir']
		if dir != 'ltr' and dir != 'rtl':
			print "dir=", dir, "bibleId=", bibleId
		lang = info['lang'].lower()
		if lang != bibleId[0:3].lower():
			print "lang=", lang, "bibleId=", bibleId[0:3]
		font = info.get('fontClass', 'none')
		fontSet.add(font)
		if font == 'none':
			print "font=none", "bibleId=", bibleId
		script = info.get('script', 'none')
		scriptSet.add(script)
		if script == 'none':
			print "script=none", "bibleId=", bibleId
		dialect = info.get('dialectCode', 'none')
		dialectLangPart = dialect[0:3].lower()
		dialectScriptPart = dialect[3:]
		if dialectLangPart != lang:
			print "dialectLangPart=", dialectLangPart, "bibleId=", bibleId
		if dialectScriptPart != 'Latin':
			print "dialectScriptPart=", dialectScriptPart, "script=", script, "bibleId=", bibleId
		audioDir = info.get('audioDirectory', 'none')
		if audioDir != bibleId:
			print "audioDirectory=", audioDir, "bibleId=", bibleId

		# parse the filename into parts and compare with info.json
		parts = filename.split("|")
		media = parts[0]
		if media != 'text' and media != 'audio':
			print "media=", media, "bibleId=", bibleId
		fileId = parts[1]
		if fileId != bibleId:
			print "fileId=", fileId, "bibleId=", bibleId
		someId = parts[2]
		if someId != "info.json" and someId != bibleId:
			print "someId=", someId, "bibleId=", bibleId

		// investiagate everything about the fileId, someId differences

#for f in fontSet:
#	print "font=", f

#for s in scriptSet:
#	print "script=", s

