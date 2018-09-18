#
# The purpose of this program is to validate the book code
# associated with each audio bible in dbp-prod
#

# TO Do
# 1. Write a program that parses each bookname, and looks it up in this table to report missing names
# 2. Also build a table of Book Order associated with each BookName or usfm bookCode if possible
# 3. Output any name mismatches
# 4. Output order codes for usfm bookCodes, and for bookNames
# 5. Put the resulting corresponding usfm -> [Order Code, Name]

import io
import sys

# This table controls what Audio versions will be included, and what
# text versions that are associated with
versions = [
	['ERV-ARB', 'ARB', 'WTC', True ], 	# ARBWTC/ARBWTCN1DA, ARBWTCO1DA
	['ARBVDPD', 'ARB', 'VDV', True ], 	# ARBVDV/ARZVDVN2DA, ARZVDVO2DA
	['ERV-AWA', 'AWA', 'WTC', True ], 	# AWAWTC/AWAWTCN2DA,
	['ERV-BEN', 'BEN', 'WTC', True ], 	# BENWTC/BNGWTCN1DA, BNGWTCN2DA
	['ERV-BUL', 'BUL', 'PRB', False ], 	# BULPRB/BLGAMBN1DA
	['ERV-CMN', 'CMN', 'UN1', True ], 	# CMNUN1/CHNUNVN2DA, CMNUNV/CHNUNVO2DA
	['ERV-ENG', 'ENG', 'ESV', False ], 	# ENGESV/ENGESVN2DA, ENGESVO2DA
	['KJVPD', 	'ENG', 'KJV', True ], 	# ENGKJV/ENGKJVN2DA, ENGKJVO2DA
	['WEB', 	'ENG', 'WEB', True ], 	# ENGWEB/ENGWEBN2DA, ENGWEBO2DA
	['ERV-HRV', 'SRC', None, False ],
	['ERV-HIN', 'HIN', 'WTC', True], 	# HINWTC/HNDWTCN2DA
	['ERV-HUN', 'HUN', 'HBS', False ],	# HUNHBS/HUNHBSN1DA
	['ERV-IND', 'IND', 'SHL', False ],	# INDSHL/INZSHLN2DA
	['ERV-KAN', 'KAN', 'WTC', True ],	# KANWTC/ERVWTCN1DA, ERVWTCN2DA
	['ERV-MAR', 'MAR', 'WTC', True ],	# MARWTC/MARWTCN1DA, MARWTCN2DA
	['ERV-NEP', 'NEP', None, False ],
	['ERV-ORI', 'ORY', 'WTC', True ],	# ORYWTC/ORYWTCN1DA, ORYWTCN2DA
	['ERV-PAN', 'PAN', None, False ],
	['ERV-POR', 'POR', 'BAR', False ],	# PORBAR/PORARAN2DA
	['ERV-RUS', 'RUS', 'S76', False ],	# RUSS76/RUSS76N2DA, RUSS76O2DA
	['ERV-SPA', 'SPA', 'WTC', True ],	# SPAWTC/SPNWTCN2DA
	['ERV-SRP', 'SRP', None, False ],
	['ERV-TAM', 'TAM', 'WTC', True ],	# TAMWTC/TCVWTCN1DA
	['ERV-THA', 'THA', None, False ],
	['ERV-UKR', 'UKR', 'N39', False ],	# UKRN39/UKRO95N2DA
	['ERV-URD', 'URD', 'WTC', True ],	# URDWTC/URDWTCN2DA
	['ERV-VIE', 'VIE', None, False ],
	['NMV', 	'PES', None, False ]
]

#for version in versions:
#	print version

def usfmBookId(bookName):
	books = {
		'Genesis':   	'GEN',
		'Exodus':  		'EXO',
		'Leviticus':   	'LEV',
		'Numbers':   	'NUM',
		'Deuteronomy':  'DEU',
		'Joshua':  		'JOS',
		'Judges':  		'JDG',
		'Ruth':  		'RUT',
		'1Samuel':  	'1SA',
		'2Samuel':  	'2SA',
		'1Kings':  		'1KI',
		'2Kings':  		'2KI',
		'1Chronicles':  '1CH',
		'2Chronicles':  '2CH',
		'Ezra':  		'EZR',
		'Nehemiah':   	'NEH',
		'Esther':  		'EST',
		'Job':   		'JOB',
		'Psalms':    	'PSA',
		'Proverbs':  	'PRO',
		'Ecclesiastes': 'ECC',
		'SongofSongs':  'SNG',
		'Isaiah':   	'ISA',
		'Jeremiah':   	'JER',
		'Lamentations': 'LAM',
		'Ezekiel':  	'EZK',
		'Daniel':   	'DAN',
		'Hosea':   		'HOS',
		'Joel':  		'JOL',
		'Amos':  		'AMO',
		'Obadiah':  	'OBA',
		'Jonah': 		'JON',
		'Micah':   		'MIC',
		'Nahum':   		'NAM',
		'Habakkuk':   	'HAB',
		'Zephaniah':  	'ZEP',
		'Haggai':   	'HAG',
		'Zechariah':  	'ZEC',
		'Malachi':   	'MAL',
		'Matthew':  	'MAT',
		'Mark':  		'MRK',
		'Luke':  		'LUK',
		'John':  		'JHN',
		'Acts':  		'ACT',
		'Romans':   	'ROM',
		'1Corinthians': '1CO',
		'2Corinthians': '2CO',
		'Galatians':   	'GAL',
		'Ephesians':   	'EPH',
		'Philippians':  'PHP',
		'Colossians':   'COL',
		'1Thess':		'1TH',
		'2Thess':		'2TH',
		'1Timothy':  	'1TI',
		'2Timothy':  	'2TI',
		'Titus': 		'TIT',
		'Philemon':  	'PHM',
		'Hebrews':   	'HEB',
		'James':   		'JAS',
		'1Peter':  		'1PE',
		'2Peter':  		'2PE',
		'1John': 		'1JN',
		'2John': 		'2JN',
		'3John': 		'3JN',
		'Jude':  		'JUD',
		'Revelation':   'REV',
		# Spanish
		'San Mateo':	'MAT',
		'San Marcos':	'MRK',
		'San Lucas':	'LUK',
		'San Juan':		'JHN',
		'Hechos':		'ACT',
		'Romanos':		'ROM',
		'1Corintios':	'1CO',
		'2Corintios':	'2CO',
		'Galatas':		'GAL',
		'Efesios':		'EPH',
		'Filipenses':	'PHP',
		'Colosenses':	'COL',
		'1Tes':			'1TH',
		'2Tes':			'2TH',
		'1Timoteo':		'1TI',
		'2Timoteo':		'2TI',
		'Tito':			'TIT',
		'Filemon':		'PHM',
		'Hebreos':		'HEB',
		'Santiago':		'JAS',
		'1San Pedro':	'1PE',
		'2San Pedro':	'2PE',
		'1San Juan':	'1JN',
		'2San Juan':	'2JN',
		'3San Juan':	'3JN',
		'Judas':		'JUD',
		'Apocalipsis':	'REV',
		# Portuguese
		'S Mateus':		'MAT',
		'S Marcos':		'MRK',
		'S Lucas':		'LUK',
		'S Joao':		'JHN',
		'Atos':			'ACT',
		'Colossenses':	'COL',
		'1Tess':		'1TH',
		'2Tess':		'2TH',
		'Hebreus':		'HEB',
		'S Tiago':		'JAS',
		'1Pedro':		'1PE',
		'2Pedro':		'2PE',
		'1S Joao':		'1JN',
		'2S Joao':		'2JN',
		'3S Joao':		'3JN',
		'S Judas':		'JUD',
		'Apocalipse':	'REV',
		# Indonesian
		'Matius':		'MAT',
		'Markus':		'MRK',
		'Lukas':		'LUK',
		'Yohanes':		'JHN',
		'Kisah Rasul':	'ACT',
		'Roma':			'ROM',
		'1Korintus':	'1CO',
		'2Korintus':	'2CO',
		'Galatia':		'GAL',
		'Efesus':		'EPH',
		'Filipi':		'PHP',
		'Kolose':		'COL',
		'1Tesalonika':	'1TH',
		'2Tesalonika':	'2TH',
		'1Timotius':	'1TI',
		'2Timotius':	'2TI',
		'Ibrani':		'HEB',
		'Yakobus':		'JAS',
		'1Petrus':		'1PE',
		'2Petrus':		'2PE',
		'1Yohanes':		'1JN',
		'2Yohanes':		'2JN',
		'3Yohanes':		'3JN',
		'Yudas':		'JUD',
		'Wahyu':		'REV'
	}
	result = books.get(bookName, None)
	return result

underscores = "_______________"

abbrDict = dict()	
for version in versions:
	if version[2] != None:
		abbr = version[1] + version[2]
		abbrDict[abbr] = version[0]

versionOut = io.open("output/AudioVersionTable.sql", mode="w", encoding="utf-8")
versionOut.write(u"DROP TABLE IF EXISTS AudioVersion;\n")
versionOut.write(u"CREATE TABLE AudioVersion(\n")
versionOut.write(u"  ssVersionCode TEXT NOT NULL PRIMARY KEY,\n")
versionOut.write(u"  dbpLanguageCode TEXT NOT NULL,\n")
versionOut.write(u"  dbpVersionCode TEXT NOT NULL);\n")

audioOut = io.open("output/AudioTable.sql", mode="w", encoding="utf-8")
audioOut.write(u"DROP TABLE IF EXISTS Audio;\n")
audioOut.write(u"CREATE TABLE Audio(\n")
audioOut.write(u"  damId TEXT NOT NULL PRIMARY KEY,\n")
audioOut.write(u"  dbpLanguageCode TEXT NOT NULL,\n")
audioOut.write(u"  dbpVersionCode TEXT NOT NULL,\n")
audioOut.write(u"  collectionCode TEXT NOT NULL,\n")
audioOut.write(u"  mediaType TEXT NOT NULL);\n")

bookOut = io.open("output/AudioBookTable.sql", mode="w", encoding="utf-8")
bookOut.write(u"DROP TABLE IF EXISTS AudioBook;\n")
bookOut.write(u"CREATE TABLE AudioBook(\n")
bookOut.write(u"  damId TEXT NOT NULL REFERENCES Audio(damId),\n")
bookOut.write(u"  bookId TEXT NOT NULL,\n")
bookOut.write(u"  bookOrder TEXT NOT NULL,\n")
bookOut.write(u"  bookName TEXT NOT NULL,\n")
bookOut.write(u"  numberOfChapters INTEGER NOT NULL,\n")
bookOut.write(u"  PRIMARY KEY (damId, bookId));\n")


versionIdSet = set()
damIdSet = set()
lastDamId = None
lastUsfm = None
bookLine = None

dbpProd = io.open("Release.1.13/metadata/FCBH/dbp_prod.txt", mode="r", encoding="utf-8")
for line in dbpProd:
	line = line.strip()
	parts = line.split("/")
	numParts = len(parts)
	if parts[0] == 'audio' and parts[numParts -1][-4:] == ".mp3":
		abbr = parts[1]
		damId = parts[2]
		if len(abbr) == 6 and len(damId) == 10 and numParts == 4 and abbr in abbrDict.keys():
			if not abbr in versionIdSet:
				versionIdSet.add(abbr)
				ssVersionCode = abbrDict[abbr]
				versionOut.write(u"INSERT INTO AudioVersion VALUES ('%s', '%s', '%s');\n"
				% (ssVersionCode, abbr[0:3], abbr[3:]))
			book = parts[3]
			testament = book[0:1]
			if testament == 'A' or testament == 'B':
				order = book[0:3]
				chapter = book[5:8]
				chapter = chapter.replace("_", "")
				name = book[9:21]
				name = name.replace("_", " ").strip()
				damId2 = book[21:31].replace("_", " ").strip()
				if damId == damId2:
					usfm = usfmBookId(name)
					if usfm == None:
						print "ERROR", line, name
					checkChapter = chapter
					if len(checkChapter) < 3:
						checkChapter = "_" + checkChapter
					checkName = name.replace(" ", "_")
					checkName = checkName + underscores[0: 12 - len(name)]
					generated = "audio/%s/%s/%s__%s_%s%s.mp3" % (abbr, damId, order, checkChapter, checkName, damId)
					if line != generated:
						print "ERROR"
						print line
						print generated
					collectionCode = damId[6:7] + "T"
					if collectionCode == 'OT' or collectionCode == 'NT':
						mType = damId[7:]
						if mType != '1DA' and mType != '2DA':
							print "ERROR mediaType", line
						mediaType = 'Drama' if (mType == '2DA') else 'Non-Drama'
						if not damId in damIdSet:
							damIdSet.add(damId)
							audioOut.write(u"REPLACE INTO Audio VALUES('%s', '%s', '%s', '%s', '%s');\n"
							% (damId, abbr[0:3], abbr[3:6], collectionCode, mediaType))
						bookIdKey = damId + usfm
						if usfm != lastUsfm or damId != lastDamId:
							if bookLine != None:
								bookOut.write(bookLine)
							lastUsfm = usfm
							lastDamId = damId
						bookLine = u"REPLACE INTO AudioBook VALUES('%s', '%s', '%s', '%s', '%s');\n" % (damId, usfm, order, name, chapter)


dbpProd.close()
versionOut.close()
audioOut.close()
bookOut.write(bookLine)
bookOut.close()

#for order in orderSet:
#	print order

#for chapter in chapterSet.keys():
#	print chapter, chapterSet[chapter]

#for book in bookSet:
#	print book
