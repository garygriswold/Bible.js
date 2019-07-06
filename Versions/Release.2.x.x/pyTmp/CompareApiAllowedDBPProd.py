# CompareApiAllowedDBPProd.py
#
# This program reads the API Allowed.csv file and looks up audio
# damId's in dbp-prod to see if they are present.
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

import io
import os
import csv

def unicode_csv_reader(utf8_data, dialect=csv.excel, **kwargs):
    csv_reader = csv.reader(utf8_data, dialect=dialect, **kwargs)
    for row in csv_reader:
        yield [unicode(cell, 'utf-8') for cell in row]

def check(str, expectLen):
	if len(str) == 0:
		return None
	if str == "NA":
		return None
	if len(str) != expectLen:
		print "Unexpected length", expectLen, str
		return None
	searchDBPProd(str)
	return str

def searchDBPProd(damId):
	filename = os.environ['HOME'] + "/ShortSands/DBL/FCBH/dbp_prod.txt"
	input1 = io.open(filename, mode="r", encoding="utf-8")
	for line in input1:
		if "audio/" in line and damId in line:
			#print "Found", damId, line
			input1.close()
			return
	print "Not Found", damId
	input1.close()
	return

filename = os.environ['HOME'] + "/ShortSands/DBL/FCBH/apiallowed.csv"
reader = unicode_csv_reader(open(filename))
for row in reader:
	ntDrama = check(row[6], 10)
	otDrama = check(row[8], 10)
	ntAudio = check(row[7], 10)
	otAudio = check(row[9], 10)


reader.close()