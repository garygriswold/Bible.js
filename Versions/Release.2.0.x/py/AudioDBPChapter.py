# This program collects verse meta data for all books and chapters that have this data
#

import io
import sqlite3
import urllib2
import json

HOST = "https://dbt.io/";
KEY = "key=b37964021bdd346dc602421846bf5683&v=2";

output = io.open("sql/AudioChapterTable.sql", mode="w", encoding="utf-8")

TEST_CASES = ['CHNUNVN2DA', 'ENGESVN2DA', 'ENGESVO2DA']

def getOsisBookCode(bookCode):
	books = {
		'GEN': 'Gen',
		'EXO': 'Exod',
		'LEV': 'Lev',
		'NUM': 'Num',
		'DEU': 'Deut',
		'JOS': 'Josh',
		'JDG': 'Judg',
		'RUT': 'Ruth',
		'1SA': '1Sam',
		'2SA': '2Sam',
		'1KI': '1Kgs',
		'2KI': '2Kgs',
		'1CH': '1Chr',
		'2CH': '2Chr',
		'EZR': 'Ezra',
		'NEH': 'Neh',
		'EST': 'Esth',
		'JOB': 'Job',
		'PSA': 'Ps',
		'PRO': 'Prov',
		'ECC': 'Eccl',
		'SNG': 'Song',
		'ISA': 'Isa',
		'JER': 'Jer',
		'LAM': 'Lam',
		'EZK': 'Ezek',
		'DAN': 'Dan',
		'HOS': 'Hos',
		'JOL': 'Joel',
		'AMO': 'Amos',
		'OBA': 'Obad',
		'JON': 'Jonah',
		'MIC': 'Mic',
		'NAM': 'Nah',
		'HAB': 'Hab',
		'ZEP': 'Zeph',
		'HAG': 'Hag',
		'ZEC': 'Zech',
		'MAL': 'Mal',
		'MAT': 'Matt',
		'MRK': 'Mark',
		'LUK': 'Luke',
		'JHN': 'John',
		'ACT': 'Acts',
		'ROM': 'Rom',
		'1CO': '1Cor',
		'2CO': '2Cor',
		'GAL': 'Gal',
		'EPH': 'Eph',
		'PHP': 'Phil',
		'COL': 'Col',
		'1TH': '1Thess',
		'2TH': '2Thess',
		'1TI': '1Tim',
		'2TI': '2Tim',
		'TIT': 'Titus',
		'PHM': 'Phlm',
		'HEB': 'Heb',
		'JAS': 'Jas',
		'1PE': '1Pet',
		'2PE': '2Pet',
		'1JN': '1John',
		'2JN': '2John',
		'3JN': '3John',
		'JUD': 'Jude',
		'REV': 'Rev'   
	}
	result = books[bookCode]
	if result == None:
		print "ERROR no OSIS code for", bookCode
	return result

def getVerseNumbers(damId, osisCode, chapter):
	chapStr = str(chapter)
	url = HOST + "audio/versestart?" + KEY + "&dam_id=" + damId + "&osis_code=" + osisCode + "&chapter_number=" + chapStr
	try:
		response = urllib2.urlopen(url)
		data = response.read()
		verses = json.loads(data)
		array = [None] * (len(verses) + 1)
		array[0] = 0
		for verse in verses:
			#print verse
			num = int(verse["verse_id"])
			pos = float(verse["verse_start"])
			#print "array[num] = pos", num, pos
			array[num] = pos

		for idx in range(1, len(array)):
			if array[idx] == None:
				array[idx] = array[idx - 1]

		numbers = json.dumps(array)
		numbers = numbers.replace(" ", "")
		output.write("INSERT INTO AudioChapter VALUES('%s', '%s', '%s', '%s');\n" % (damId, bookId, chapter, numbers))
		return True
	except Exception, err:
		print "ERROR", damId, osisCode, chapter, verses, err
		return False

db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT damId, bookId, numberOfChapters FROM AudioBook ORDER BY damId, bookOrder"
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()
for row in rows:
	damId = row[0]
	if damId in TEST_CASES:
		bookId = row[1]
		osisCode = getOsisBookCode(bookId)
		numberOfChapters = row[2]

		print damId, bookId, osisCode, numberOfChapters
		ok = getVerseNumbers(damId, osisCode, 1)

db.close()
output.close()
exit()


# iterate over the chapters
# form a query
# convert result to json
# convert result into a simple array
# write array to AudioChapterTable.sql








#	function doVerseListQuery(book, chapterNum, callback) {
#		var url = HOST + "audio/versestart?" + KEY + "&dam_id=" + book.dam_id + "&osis_code=" + book.book_id + "&chapter_number=" + chapterNum;
#		httpGet(url, function(json) {
#			var array = [];
#			array[0] = 0.0;
#			for (var i=0; i<json.length; i++) {
#				var item = json[i];
#				array[item.verse_id] = item.verse_start;
#			}
#			for (var j=1; j<array.length; j++) {
#				if (array[j] == null) {
#					array[j] = array[j - 1];
#				}
#			}
#			if (json.length > 0) {
#				var sql = "INSERT INTO AudioChapter VALUES('" + book.dam_id + "', '" + book.usfm_book_id + "', '" + chapterNum + "', '" + JSON.stringify(array) + "');"
#				console.log(sql);
#				audioChapterTableSql.push(sql);
#			}
#			callback(json.length);	
#		});	
#	}