# This program reads one Bible database.  Reads the chapters one at a time, 
# and uploads the chapter to AWS S3 as an object with an appropriate key.
# It only uploads to one bucket text-us-east-1-shortsands, and replication
# copies it to other regions.

import sys
import io
import sqlite3
import os
import boto3

SOURCE_DIR = os.environ['HOME'] + "/ShortSands/DBL/5ready/"
#BUCKET = "text-us-east-1-shortsands" # AWS S3 will replicate to other regions
BUCKET = "text-us-west-2-shortsands" # Test bucket

bookMap = {
        "FRT": "0",
        "INT": "1",
        "GEN": "2",
        "EXO": "3",
        "LEV": "4",
        "NUM": "5",
        "DEU": "6",
        "JOS": "7",
        "JDG": "8",
        "RUT": "9",
        "1SA": "10",
        "2SA": "11",
        "1KI": "12",
        "2KI": "13",
        "1CH": "14",
        "2CH": "15",
        "EZR": "16",
        "NEH": "17",
        "EST": "18",
        "JOB": "19",
        "PSA": "20",
        "PRO": "21",
        "ECC": "22",
        "SNG": "23",
        "ISA": "24",
        "JER": "25",
        "LAM": "26",
        "EZK": "27",
        "DAN": "28",
        "HOS": "29",
        "JOL": "30",
        "AMO": "31",
        "OBA": "32",
        "JON": "33",
        "MIC": "34",
        "NAM": "35",
        "HAB": "36",
        "ZEP": "37",
        "HAG": "38",
        "ZEC": "39",
        "MAL": "40",
        "TOB": "41",
        "JDT": "42",
        "ESG": "43",
        "WIS": "45",
        "SIR": "46",
        "BAR": "47",
        "LJE": "48",
        "S3Y": "49",
        "SUS": "50",
        "BEL": "51",
        "1MA": "52",
        "2MA": "53",
        "1ES": "54",
        "MAN": "55",
        "3MA": "57",
        "4MA": "59",
        "MAT": "70",
        "MRK": "71",
        "LUK": "72",
        "JHN": "73",
        "ACT": "74",
        "ROM": "75",
        "1CO": "76",
        "2CO": "77",
        "GAL": "78",
        "EPH": "79",
        "PHP": "80",
        "COL": "81",
        "1TH": "82",
        "2TH": "83",
        "1TI": "84",
        "2TI": "85",
        "TIT": "86",
        "PHM": "87",
        "HEB": "88",
        "JAS": "89",
        "1PE": "90",
        "2PE": "91",
        "1JN": "92",
        "2JN": "93",
        "3JN": "94",
        "JUD": "95",
        "REV": "96",
        "BAK": "97",
        "OTH": "98",
        "XXA": "99",
        "XXB": "100",
        "XXC": "101",
        "XXD": "102",
        "XXE": "103",
        "XXF": "104",
        "XXG": "105",
        "GLO": "106",
        "CNC": "107",
        "TDX": "108",
        "NDX": "109"
         }


#filename = SOURCE_DIR + sys.argv[1] + ".db"
filename = SOURCE_DIR + "WEB.db"
print filename
if not os.path.isfile(filename):
	print "Database does not exist", sys.argv[1]
	exit()

versionId = sys.argv[1]
s3 = boto3.client('s3')

db = sqlite3.connect(filename)
cursor = db.cursor()
sql = "SELECT reference, html FROM chapters"
values = ()
cursor.execute(sql, values)
rows = cursor.fetchall()
for row in rows:
	book = row[0][0:3]
	sequence = bookMap[book]
	chapter = row[0][4:]
	html = row[1]
	#key %I_%O_%B_%C.html
	if chapter != "0":
		key = "text/%s/%s/%s_%s_%s_%s.html" % \
		(versionId, versionId, versionId, sequence, book, chapter)
	else:
		key = "text/%s/%s/%s_%s_%s.html" % \
		(versionId, versionId, versionId, sequence, book)
	print key

	s3.put_object(Bucket=BUCKET, Key=key, Body=html, ContentType="text/html; charset=utf-8")

db.close()





