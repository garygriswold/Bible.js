#
# This file will download all of the objects in a bucket that are
# associated with a specific BibleId/FileId
#
import boto3
import io
import os

media = "text/ENGESV"
mediaLen = len(media)
filename1 = "about.html"
filename2 = "info.json"
target = "/Users/garygriswold/ShortSands/DBL/FCBH_info"

session = boto3.Session(profile_name='FCBH_BibleApp')
client = session.client('s3')

input = io.open("metadata/FCBH/dbp_dev.txt", mode="r", encoding="utf-8")
for line in input:
	if line[0:mediaLen] == media:
		line = line.strip()
		row = line.split("/")
		last = row[-1]
		if last == filename1 or last == filename2:
			directory = target + "/" + row[1]
			if not os.path.exists(directory):
				os.makedirs(directory)
			path = directory + "/" + last
			try:
				client.download_file('dbp-prod', line, path)
				print "Sucessfully downloaded", path
			except:
				print "Failed ", line

input.close()
