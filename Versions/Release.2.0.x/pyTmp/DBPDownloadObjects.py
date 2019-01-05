#
# This file will download all of the objects in a bucket that are
# associated with a specific BibleId/FileId
#
import boto3
import io
import os

media = "text"
bibleId = "ENGKJV"
target = "/Users/garygriswold/ShortSands/DBL/FCBH"
search = media + "/" + bibleId + "/"
searchLen = len(search)

session = boto3.Session(profile_name='FCBH_BibleApp')
client = session.client('s3')

input = io.open("metadata/FCBH/dbp_dev.txt", mode="r", encoding="utf-8")
for line in input:
	if line[0:searchLen] == search:
		line = line.strip()
		row = line.split("/")
		numDirs = len(row) - 1
		directory = target
		for index in range(1, numDirs):
			directory += "/" + row[index]
			print directory
			if not os.path.exists(directory):
				os.makedirs(directory)
		last = row[-1]
		filename = directory + "/" + last
		client.download_file('dbp-prod', line, filename)

input.close()

