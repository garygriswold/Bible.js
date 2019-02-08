# This program reads one Bible database.  Reads the chapters one at a time, 
# and uploads the chapter to AWS S3 as an object with an appropriate key.
# It only uploads to one bucket text-us-east-1-shortsands, and replication
# copies it to other regions.

import sys
import io
import sqlite3
import os
import boto3
import json
from collections import OrderedDict

SOURCE_DIR = os.environ['HOME'] + "/ShortSands/DBL/5ready/"
#BUCKET = "text-us-east-1-shortsands" # AWS S3 will replicate to other regions
BUCKET = "text-us-west-2-shortsands" # Test bucket

versionMap = {
	"ARBVDPD.db": ["ARBVDV"], # FCBH has, and also has ARZVDV
	"ERV-ARB.db": ["ARBERV"], # FCBH has, and also has ARBWTC
	"ERV-AWA.db": ["AWAERV"], # FCBH has, and also has AWAWTC
	"ERV-BEN.db": ["BENERV"], # FCBH has, also has BENWTC/BNGWTC
	"ERV-BUL.db": ["BULERV"], # FCBH has
	"ERV-CMN.db": ["CMNERV"], # FCBH has
	"ERV-ENG.db": ["ENGERU"], # FCBH has
	"ERV-HIN.db": ["HINERV"], # FCBH has, also has HINWTC/HNDWTC
	"ERV-HRV.db": ["HRVERV"], # FCBH has
	"ERV-HUN.db": ["HUNERV"], # FCBH has
	"ERV-IND.db": ["INDERV"], # FCBH has
	"ERV-KAN.db": ["KANERV"], # FCBH has, also has KANWTC
	"ERV-MAR.db": ["MARERV"], # FCBH has
	"ERV-NEP.db": ["NEPERV"], # FCBH has
	"ERV-ORI.db": ["ORIERV"], # FCBH has, also has ORYWTC
	"ERV-PAN.db": ["PANERV"], # FCBH has
	"ERV-POR.db": ["PORERV"], # FCBH has
	"ERV-RUS.db": ["RUSWTC"], # FCBH has
	"ERV-SPA.db": ["SPAWTC", "SPNWTC"], # FCBH has, also has SPNWTC
	"ERV-SRP.db": ["SRPERV"], # FCBH has
	"ERV-TAM.db": ["TAMERV"], # FCBH has, also has TABWTC/TCVWTC
	"ERV-THA.db": ["THAERV"], # FCBH has
	"ERV-UKR.db": ["UKRBLI", "URKERV"], # FCBH has
	"ERV-URD.db": ["URDWTC"], # FCBH has, also has URDWTC/URDERV
	"ERV-VIE.db": ["VIEWTC"], # FCBH has
	"KJVPD.db": ["ENGKJV"], # FCBH does not have text
	"NMV.db": ["PESNMV", "PESEMV"], # FCBH has
	"WEB.db": ["ENGWEB"] # FCBH has
}

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


filename = SOURCE_DIR + sys.argv[1]
print filename
if not os.path.isfile(filename):
	print "Database does not exist", sys.argv[1]
	exit()

versionArray = versionMap[sys.argv[1]]
versionId = versionArray[0]
versionId2 = versionArray[1] if len(versionArray) > 1 else versionId
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
		(versionId, versionId2, versionId2, sequence, book, chapter)
	else:
		key = "text/%s/%s/%s_%s_%s.html" % \
		(versionId, versionId2, versionId2, sequence, book)
	print key
	#s3.put_object(Bucket=BUCKET, Key=key, Body=html, ContentType="text/html; charset=utf-8")

bookNames = []
bookIds = []
chapters = []
sql = "SELECT code, heading, title, name, abbrev, lastChapter FROM tableContents"
cursor.execute(sql, values)
rows = cursor.fetchall()
for row in rows:
	bookId = row[0]
	heading = row[1]
	lastChapter = row[5]
	bookIds.append(bookId)
	bookNames.append(heading)
	for chapter in range(1, lastChapter + 1): 
		chapters.append(bookId + str(chapter))

info = OrderedDict()
info["id"] = versionId
info["divisionNames"] = bookNames
info["divisions"] = bookIds
info["sections"] = chapters

string = json.dumps(info)
#print string
key = "text/%s/%s/info.json" % (versionId, versionId2)
print key
#s3.put_object(Bucket=BUCKET, Key=key, Body=string, ContentType="application/json")

db.close()





