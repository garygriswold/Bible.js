#
# ComparePermissionAllowed.py
#
# This program compares a generated file of permissions (PermissionsRequest.txt)
# that I generated to an apiallowed.csv file given by FCBH.  The purpose is to
# identify any permissions that I am not allowed.
#
# Layout of apiallowed.csv
# column 0 - line number
# column 1 - LangName
# column 2 - Reg NT Text DamId
# column 3 - Reg OT Text DamId
# column 4 - ND NT Text DamId
# column 5 - ND OT Text DamId
# column 6 - Reg NT Audio DamId
# column 7 - Reg OT Audio DamId
# column 8 - ND NT Audio DamId
# column 9 - ND OT Audio DamId
#
# Process
# 1. Read the csv file one line at a time
# 2. Create Set of Col 2 NT Text
# 3. Create Set of Col 3 OT Text
# 4. Create Set of Col 6 and 8 NT Audio
# 5. Create Set of Col 7 and 9 OT Audio
# 6. Read PermissionsRequest.txt, and parse records
# 7. For each row lookup bibleId in NT Text
# 8. For each text lookup textId in NT Text
# 9. For each audio lookup NT damId in NT Audio
# 10. For each audio lookup OT damId in OT Audio
# 11. Report any differences in bibleId to textId
# 12. Report any differences in damId to textId
# 13. Report any differences in language id.

import io
import os
import csv

def unicode_csv_reader(utf8_data, dialect=csv.excel, **kwargs):
    csv_reader = csv.reader(utf8_data, dialect=dialect, **kwargs)
    for row in csv_reader:
        yield [unicode(cell, 'utf-8') for cell in row]

def add(str, expectLen, addLen, aset):
	if len(str) == 0:
		return None
	if str == "NA":
		return None
	if len(str) != expectLen:
		print "Length Error", expectLen, str
		return None
	aset.add(str[0:addLen])


ntTextSet = set()
otTextSet = set()
ntAudioSet = set()
otAudioSet = set()
filename = os.environ['HOME'] + "/ShortSands/DBL/FCBH/apiallowed.csv"
reader = unicode_csv_reader(open(filename))
for row in reader:
	add(row[2], 10, 6, ntTextSet)
	add(row[3], 10, 6, otTextSet)
	add(row[6], 10, 10, ntAudioSet)
	add(row[8], 10, 10, ntAudioSet)
	add(row[7], 10, 10, otAudioSet)
	add(row[9], 10, 10, otAudioSet)

reader.close()

#print otAudioSet

input1 = io.open("PermissionsRequest.txt", mode="r", encoding="utf-8")
for line in input1:
	if line.startswith('\"arn:aws:s3:::'):
		row = line.split("/")
		#print row[1]
		if row[1] == "text":
			row[4] = row[4].split("_")[0]
			if row[2] not in ntTextSet and row[3] not in ntTextSet and row[4] not in ntTextSet:
				print row[1], row[2], row[3], row[4]
		elif row[1] == "audio":
			#print row[2], row[3], row[4]
			if row[3] not in ntAudioSet and row[3] not in otAudioSet:
				print row[1], row[2], row[3], row[4]
