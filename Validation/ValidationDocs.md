Validation Documentation
========================

The Validation Module is a series of program that must be run individually and their results inspected to insure there is no error.
There is much redundancy.  For example, if the ConcordanceValidation is successful is seems unlikely that the Bible Text contains an error,
but the other test will help to identify the location of the error should one occur.

XMLTokenizerTest
----------------

The XMLTokenizer is the lexical processor that processes Bible input.  If an error occurs here many other modules will have errors as well.
This program generates USX text files from input USX files and then does a diff to be certain the generated are identical to the starting ones.

	./TokenizerTest.sh
	
	Any difference between input and generated will be displayed.
	
USXParser
---------

The USXParser is the xml parser processor that processes Bible input.  It was custom written, because other JS parsers that I found did not work
perfectly.  This program parses the USX into internal object that model USX and then converts them back to text files.  A perfect result will
show only the filename of each book.  When errors do occur verify whether they are occurring a book that is part of the canon or scripture.

	./USXParserTest.sh
	
	Any difference between input and generated USX files will be displayed.
	
StyleUseValidator
-----------------

The StyleUseValidator compares the styles found in the version with those which have been written for in Codex.css and elsewhere.
It displays the styles, references or use, and counts for any styles that are not yet developed.

	./StyleUseValidator
	
	Error results are displayed in stdout, and output/StyleUseUnfinished.txt
	

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



