#
# Validate the permissions of the Audio Bibles listed in Versions.db Audio tables.
# And verify that the S3 key generation logic can correctly generate a key for
# each chapter of each book.
#
import sqlite3
import io
import boto3

dbpProd = io.open("Release.1.13/metadata/FCBH/dbp_prod.txt", mode="r", encoding="utf-8")
session = boto3.Session(profile_name='FCBH_BibleApp')
client = session.client('s3')
target = "/Users/garygriswold/Downloads/FCBH/"

def zeroPadChapter(chapter):
	chapStr = str(chapter)
	if len(chapStr) == 1:
		return "00" + chapStr
	elif len(chapStr) == 2:
		return "0" + chapStr
	else:
		return chapStr

def generateS3Key(book, chap):
	abbr = book[5] + book[6]
	if book[1] != "PSA":
		chap = "_" + chap[1:]
	name = book[3].replace(" ", "_")
	name = name + "____________"[0:(12 - len(name))]
	key = "audio/%s/%s/%s__%s_%s%s.%s" % (abbr, book[0], book[2], chap, name, book[0], "mp3")
	return key

def searchDbpProd(key):
	for line in dbpProd:
		if line.strip() == key:
			return True
	return False

versions = []
db = sqlite3.connect('Versions.db')
cursor = db.cursor()
sql = "SELECT ssVersionCode, dbpLanguageCode, dbpVersionCode FROM AudioVersion WHERE dbpLanguageCode = 'CMN'"
values = ( )
cursor.execute(sql, values)
for row in cursor:
	versions.append(row)

audioFiles = []
for version in versions:
	sql = "SELECT damId, dbpLanguageCode, dbpVersionCode, collectionCode, mediaType" \
	+ " FROM Audio WHERE dbpLanguageCode = ? AND dbpVersionCode = ? ORDER BY damId"
	values = (version[1], version[2], )
	cursor.execute(sql, values)
	if cursor.rowcount == 0:
		print("NO Audio: " + version)
	for row in cursor:
		#print row
		audioFiles.append(row)

books = []
for audio in audioFiles:
	#print audio
	sql = "SELECT damId, bookId, bookOrder, bookName, numberOfChapters" \
	+ " FROM AudioBook WHERE damId = ? ORDER BY damId, bookOrder"
	values = (audio[0], )
	cursor.execute(sql, values)
	if cursor.rowcount == 0:
		print("NO AudioBook: " + audio)
	for row in cursor:
		#print row
		book = (row[0], row[1], row[2], row[3], row[4], audio[1], "UNV")#audio[2])
		books.append(book)

for book in books:
	# For each chapter of each book generate a key, and search for it in dbp_prod.txt
	numChap = int(book[4])
	for ch in range(numChap):
		chap = zeroPadChapter(ch + 1)
		key = generateS3Key(book, chap)
		#print key
		found = searchDbpProd(key)
		if not found:
			print "NOT FOUND: " + key
	# For GEN:1, MAL:1, MAT:1, REV:1 attempt a download and report any error
	bookId = book[1]
	if bookId == "GEN" or bookId == "MAL" or bookId == "MAT" or bookId == "REV":
		key = generateS3Key(book, "001")
		filename = target + book[0] + "_" + bookId
		#print key
		try:
			client.download_file('dbp-prod', key, filename)
			#print "Done ", key
		except:
			print "Error Failed ", key


dbpProd.close()


















