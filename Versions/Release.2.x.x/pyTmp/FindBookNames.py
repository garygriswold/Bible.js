# This program reads a bucket listing, and summarizes it down one
# finding a unique list of bookNames and bookOrders and chapter numbers
# This was done to study consistency of the data.

import io

keyLen = dict()
bookOrders = set()
bookChapters = set()
bookNames = set()

input = io.open("metadata/FCBH/dbp_prod.txt", mode="r", encoding="utf-8")
for line in input:
	line = line.strip()
	if line[0:6] == "audio/" and line[-4:] == ".mp3":
		line = line[0:-4]
		parts = line.split("/")
		if len(parts) == 4:
			bibleId = parts[1]
			damId = parts[2]
			key = parts[3]
			scope = damId[6:7]
			#print scope
			if len(key) == 31 and scope in ['O', 'N']:# 'P']:
				bookOrder = key[0:3]
				bookChapter = int(key[5:8].replace("_", ""))
				bookName = key[9:21]
				damId2 = key[21:]
				#if damId != damId2:
				#	print "inconsistent damId", damId, damId2
				bookOrders.add(bookOrder)
				bookChapters.add(bookChapter)
				bookNames.add(bookName)
				#else:
				#	"ERROR not 3 pieces", first

input.close()

#for l, num in keyLen.items():
#	print l, num
print "BOOK ORDER"
for book in sorted(bookOrders):
	print book

print "BOOK CHAPTERS"
for book in sorted(bookChapters):
	print book

print "BOOK NAMES"
for book in sorted(bookNames):
	print book



