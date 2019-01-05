#
# This file will download one object and create a file by the same name
#
#import cmd
import boto3

#import io
#import os

#media = "text"
#bibleId = "ENGKJV"
target = "/Users/garygriswold/Desktop/"
#search = media + "/" + bibleId + "/"
#searchLen = len(search)

session = boto3.Session(profile_name='FCBH_BibleApp')
client = session.client('s3')

objectName = raw_input("Enter object key to download: ")
print objectName
filename = target + objectName.replace("/", ":")
print filename
client.download_file('dbp-prod', objectName, filename)



