Zip
===

This is the Zip module found on github.
https://github.com/marmelroy/Zip

Build
-----

	1. In Zip.swift import minizip was removed
	2. In Bridging-Header all of the minizip .h files were added
	
	#import "ioapi.h"
	#import "crypt.h"
	#import "zip.h"
	#import "unzip.h"
	
	3. In project, Embedded Binaries libz was added.