PKZip
=====

This plugin has been the source of lots of problems that result from the large number of choices, 
and the not so obvious result of those choices.

Zip Alternatives
----------------

There are multiple kinds of zip and they are not compatible with each other.  The Bibles
are currently stored on the server using OSX zip, which is PKZIP.  And the very nice
Java classes for reading and writing Zip content are PKZIP.

	* gzip is slightly faster than pkzip and zlib claims to be faster.
	Also, zlib gets better compression than gzip by a few bytes,
	and gzip is slightly better than pkzip.  But they all amount to
	0.201 compression when rounded.

	a zlib solution requires just a little C code.  The zlib site offers an excellent
	sample program zpipe.c  but zlib is not compatible with PK zip.
	 
	The mini zip solution is compatible with PKZIP, but I am having difficulty building 
	a mixed language framework (c/swift)  There were many implementations on github.
	I chose the one that I did because it was written is swift, had a clean interface,
	and threw exceptions.
	
	AWS has a builtin gzip, but it works on data, not files. This is not appropriate 
	for the Bible files 

Time Measurements
-----------------

ZIP PK
zip real0m5.055s
unzip real0m0.611s
0.201 compression

gzip
gzip zip 0m4.979s
real unzip0m0.470s
0.201 compression (smaller)

zlib
0.201 compression (smaller by a few bytes)






	

	