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
numPartsCount = dict()
bibleDict = dict()
fileDict = dict()
someDict = dict()
bookNum = { 
	"FRT":"0", "INT":"1", "GEN":"2", "EXO":"3", "LEV":"4", "NUM":"5", "DEU":"6", "JOS":"7", "JDG":"8", "RUT":"9", 
	"1SA":"10", "2SA":"11", "1KI":"12", "2KI":"13", "1CH":"14", "2CH":"15", "EZR":"16", "NEH":"17", "EST":"18", 
	"JOB":"19", "PSA":"20", "PRO":"21", "ECC":"22", "SNG":"23", "ISA":"24", "JER":"25", "LAM":"26", "EZK":"27",
	"DAN":"28", "HOS":"29", "JOL":"30", "AMO":"31", "OBA":"32", "JON":"33", "MIC":"34", "NAM":"35", "HAB":"36",
	"ZEP":"37", "HAG":"38", "ZEC":"39", "MAL":"40", "TOB":"41", "JDT":"42", "ESG":"43", "WIS":"45", "SIR":"46", 
	"BAR":"47", "LJE":"48", "S3Y":"49", "SUS":"50", "BEL":"51", "1MA":"52", "2MA":"53", "1ES":"54", "MAN":"55",
	"PS2":"56", "3MA":"57", "2ES":"58", "4MA":"59", "DAG":"66",
	"MAT":"70", "MRK":"71", "LUK":"72", "JHN":"73", "ACT":"74", "ROM":"75", "1CO":"76", "2CO":"77",
	"GAL":"78", "EPH":"79", "PHP":"80", "COL":"81", "1TH":"82", "2TH":"83", "1TI":"84", "2TI":"85", "TIT":"86",
	"PHM":"87", "HEB":"88", "JAS":"89", "1PE":"90", "2PE":"91", "1JN":"92", "2JN":"93", "3JN":"94", "JUD":"95",
	"REV":"96", "BAK":"97", "OTH":"98", "XXA":"99", "XXB":"100", "XXC":"101", "XXD":"102", "XXF":"104", 
	"GLO":"106", "CNC":"107",
	"TDX":"108", "NDX":"109" 
	}

# read and process all info.json files
directory = "/Users/garygriswold/ShortSands/DBL/FCBH_info/"
for filename in os.listdir(directory):
	if filename[0] != ".":
	#if filename[0] != "." and filename.count(":") == 3:
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
		#if lang != bibleId[0:3].lower():
		#	print "lang=", lang, "bibleId=", bibleId[0:3]
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
		parts = filename.split(":")
		media = parts[0]
		if media != 'text' and media != 'audio':
			print "media=", media, "bibleId=", bibleId
		fileId = parts[1]
		someId = parts[2]
		if bibleId == fileId and bibleId != someId and someId != "info.json":
			print "bibleId=", bibleId, "someId=", someId, "bibleId=fileId", "lang=", lang
		#if bibleId == someId and bibleId != fileId:
		#	print "bibleId=", bibleId, "fileId=", fileId, "bibleId=someId", "lang=", lang
		if bibleId != fileId and bibleId != someId and someId != fileId and someId != "info.json":
			print "bibleId=", bibleId, "fileId=", fileId, "someId=", someId, "lang=", lang
		#if lang != fileId[0:3].lower():
		#	print "lang=", lang, "fileId[0:3]=", fileId[0:3], "bibleId=", bibleId
		#if lang != someId[0:3].lower() and someId != "info.json":
		#	print "lang=", lang, "someId[0:3]=", someId[0:3], "bibleId=", bibleId
		if media == "text":
			numParts = len(parts)
			count = numPartsCount.get(numParts, 0)
			numPartsCount[numParts] = count + 1

		# test Uniqueness of BibleId, fileId and someId
		#bibleExists = bibleDict.get(media + bibleId)
		#if bibleExists != None:
		#	print "Duplicate bibleId=", bibleId, "first=", bibleExists, "next=", filename
		#	if bibleExists.count(":") != 3 and filename.count(":") != 3:
		#		print("*** NEITHER HAS 4 PARTS ***")
		#else:
		#	bibleDict[media + bibleId] = filename

		# test Uniqueness of fileId, second element of filename
		#fileExists = fileDict.get(media + fileId)
		#if fileExists != None:
		#	print "Duplicate fileId=", filename, "first=", fileExists
		#fileDict[media + fileId] = filename

		#compare division names and divisions to be certain they are present and equal
		divisions = info['divisions']
		divisionNames = info['divisionNames']
		if len(divisions) != len(divisionNames):
			print "divisions=", len(divisions), "divisionNames=", len(divisionNames), "bibleId=", bibleId

		print filename
		baseFilename = media + "/" + fileId + "/" + someId + "/"
		for division in divisions:
			if len(division) == 2:
				item = baseFilename + division + ".html"
			else:
				sequence = bookNum[division]
				item = baseFilename + someId + "_" + sequence + "_" + division + ".html"
			print item
			# using the filename


#for f in fontSet:
#	print "font=", f

#for s in scriptSet:
#	print "script=", s

for numParts, count in numPartsCount.iteritems():
	print "numParts=", numParts, "count=", count


