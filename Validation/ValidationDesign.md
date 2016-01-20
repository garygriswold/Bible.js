Validation Design
=================

The Validation Module must be able to validate each part of the Bible.  However, for simplicity’s sake, it does not need to be one monolithic program, but many smaller programs that test individual parts.  Also, specific problems might arise with some languages, that require a special program for that language.

Concordance
-----------

Each Bible database includes a concordance table.  This table contains the following columns:

	word text primary key not null, 
	refCount integer not null, 
	refList text not null,
	positions text not null (to be added)
	
	Example: yielding|5|GEN:1:11,GEN:1:12,GEN:1:29,JER:17:8,REV:22:2|3,5,7,4,12
	
This not a properly normalized table per normal database design considerations, but it is specifically designed to perform well for its normal use.  Since the normal use is to search on individual words or sets of words and find all uses.

The validation program is a command line node program, which takes the concordance table as input, and loads the entire concordance into memory.  Then using the words, refList and positions, it output a file which contains each verse of the Bible.  This output can be manually compared to the original Bible to verify that the only thing missing is the punctuation, and extra-Biblical headings and notes.

A second program should compare the original USX file with the concordance generated file.  This program, should parse USX, read only the verse text, drop punctuation, and compare to the concordance generate file, and produce a line of output for each difference or verse that is different.



