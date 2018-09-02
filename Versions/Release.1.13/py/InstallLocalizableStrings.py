#
# This program is used to copy Localizable.strings files into their directory
# It fails when the directory is not present, because this means that the language
# has not been added to the App
#
#import httplib
#import io
import os
import sys
from shutil import copyfile
#import json


sourceDir = "/Users/garygriswold/Downloads/Output/"
targetDir = "/Users/garygriswold/ShortSands/BibleApp/Plugins/Settings/Settings_ios/Settings/"

for langDir in os.listdir(sourceDir):
	fullDirName = targetDir + langDir
	if os.path.exists(fullDirName):
		sourceFile = sourceDir + langDir + "/Localizable.strings"
		targetFile = targetDir + langDir + "/Localizable.strings"
		copyfile(sourceFile, targetFile)
		print "copied", langDir
	else:
		print "NOT EXISTS ", langDir



