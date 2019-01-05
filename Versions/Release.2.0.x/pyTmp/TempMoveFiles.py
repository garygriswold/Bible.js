

import io
import os
import json
import sys


source = "/Users/garygriswold/ShortSands/DBL/FCBH_info/"
target = "/Users/garygriswold/ShortSands/DBL/FCBH_info_setaside/"
count = 0
for filename in os.listdir(source):
	if filename[0] != "." and filename.count(":") != 3:
		print filename
		count += 1
		os.rename(source + filename, target + filename)

print count
