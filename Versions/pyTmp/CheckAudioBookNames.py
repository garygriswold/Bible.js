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

abbrSet = {
	'ARBWTC',
	'ARBVDV',
	'AWAWTC',
	'BENWTC',
	'BULPRB',
	'CMNUN1',
	'ENGESV',
	'ENGKJV',
	'ENGWEB',
	'HINWTC',
	'HUNHBS',
	'INDSHL',
	'KANWTC',
	'MARWTC',
	'ORYWTC',
	'PORBAR',
	'RUSS76',
	'SPAWTC',
	'TAMWTC',
	'UKRN39',
	'URDWTC'
}

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
		'SanMateo':		'MAT',
		'SanMarcos':	'MRK',
		'SanLucas':		'LUK',
		'SanJuan':		'JHN',
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
		'1SanPedro':	'1PE',
		'2SanPedro':	'2PE',
		'1SanJuan':		'1JN',
		'2SanJuan':		'2JN',
		'3SanJuan':		'3JN',
		'Judas':		'JUD',
		'Apocalipsis':	'REV',
		# Portuguese
		'SMateus':		'MAT',
		'SMarcos':		'MRK',
		'SLucas':		'LUK',
		'SJoao':		'JHN',
		'Atos':			'ACT',
		'Colossenses':	'COL',
		'1Tess':		'1TH',
		'2Tess':		'2TH',
		'Hebreus':		'HEB',
		'STiago':		'JAS',
		'1Pedro':		'1PE',
		'2Pedro':		'2PE',
		'1SJoao':		'1JN',
		'2SJoao':		'2JN',
		'3SJoao':		'3JN',
		'SJudas':		'JUD',
		'Apocalipse':	'REV'
	}
	result = books[bookName]
	if (result == None):
		print("UNKNOWN BOOK NAME ", bookName)
	return result

#def filterArray(list):
#	parts = list.split('_')
#	row = []
#	for part in parts:
#		if len(part) > 0:
#			row.append(part)
#	return row

underscores = "_______________"

orderSet = set()
chapterSet = dict()
bookSet = set()
dbpProd = io.open("Release.1.13/metadata/FCBH/dbp_prod.txt", mode="r", encoding="utf-8")
for line in dbpProd:
	line = line.strip()
	parts = line.split("/")
	numParts = len(parts)
	if parts[0] == 'audio' and parts[numParts -1][-4:] == ".mp3":
		abbr = parts[1]
		damId = parts[2]
		if len(abbr) == 6 and len(damId) == 10 and numParts == 4 and abbr in abbrSet:
			#print line
			book = parts[3]
			testament = book[0:1]
			if testament == 'A' or testament == 'B':
				#print line
				order = book[1:3]
				orderSet.add(order)
				chapter = book[5:8]
				chapter = chapter.replace("_", "")
				chapterCount = chapterSet.get(chapter, 0)
				chapterSet[chapter] = chapterCount + 1
				name = book[9:21]
				name = name.replace("_", " ").strip()
				bookSet.add(name)
				damId2 = book[21:31].replace("_", " ").strip()
				if damId == damId2:
					#print damId, damId2, line
					if len(chapter) < 3:
						chapter = "_" + chapter
					name = name.replace(" ", "_")
					name = name + underscores[0: 12 - len(name)]
					generated = "audio/%s/%s/%s%s__%s_%s%s.mp3" % (abbr, damId, testament, order, chapter, name, damId)
					if line != generated:
						print line
						print generated
						print ""
					




dbpProd.close()

#for order in orderSet:
#	print order

#for chapter in chapterSet.keys():
#	print chapter, chapterSet[chapter]

for book in bookSet:
	print book

