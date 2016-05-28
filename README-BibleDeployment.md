Publishing Documentation
========================

Directory: ShortSands/BibleApp/Publisher

This program


Validation Documentation
========================

Directory: ShortSands/BibleApp/Validation

The Validation Module is a series of program that must be run individually and their results inspected to insure there is no error.
There is much redundancy.  For example, if the ConcordanceValidation is successful is seems unlikely that the Bible Text contains an error,
but the other test will help to identify the location of the error should one occur.

XMLTokenizerTest
----------------

The XMLTokenizer is the lexical processor that processes Bible input.  If an error occurs here many other modules will have errors as well.
This program generates USX text files from input USX files and then does a diff to be certain the generated are identical to the starting ones.

	./TokenizerTest.sh VERSION
	
	Any difference between input and generated will be displayed.
	
USXParser
---------

The USXParser is the xml parser processor that processes Bible input.  It was custom written, because other JS parsers that I found did not work
perfectly.  This program parses the USX into internal object that model USX and then converts them back to text files.  A perfect result will
show only the filename of each book.  When errors do occur verify whether they are occurring a book that is part of the canon or scripture.

	./USXParserTest.sh VERSION
	
	Any difference between input and generated USX files will be displayed.
	
StyleUseValidator
-----------------

The StyleUseValidator compares the styles found in the version with those which have been written for in Codex.css and elsewhere.
It displays the styles, references or use, and counts for any styles that are not yet developed.

	./StyleUseValidator.sh VERSION
	
	Error results are displayed in stdout, and output/StyleUseUnfinished.txt
	
HTMLValidator
-------------

The HTMLValidator first extracts all of the verse.html into a single text.  This is used as a baseline of text for the Bible, because
it is generated directly off the USX model objects that were created by the USXParser.  Next, this program reads chapters.html and extracts
the text from the HTML, and generates a single text file.

	./HTMLValidator.sh VERSION
	
	Differences are displayed on the console.  The verses.html output is found at output/verses.txt, and the chapters.html output is found at
	output/chapters.txt.  They are compared using diff -w
	

ConcordanceValidator
--------------------

When the concordance was generated the refList column was populated with a list of all of the verse references for each word.  But a nearly duplicate column
was created called refPosition, which contains the references for each word including the position of each word in each verse.  
This program uses the refPosition information to create a text file version of the entire Bible.  This output is stored in output/generated.txt.  
The program then uses the text version of each verse stored in verses.html to compare with generated.txt character by character.  It outputs every 
character that is missing in generated.txt into the table valPunctuation.  At the end of the process, it displays a frequency count
of these characters in valPunctuation.  If all of the characters displayed are punctuation characters then the validation has passed.

	./ConcordanceValidator.sh VERSION
	
	Uses concordance.refPosition to create the output file output/generated.txt
	Compares generated.txt to table verses.txt and puts differences into the table valPunctuation.
	Displays a frequency count of the data in valPunctuation at end.
	
ValidationCleanup
-----------------

This program copies the database file from DBL/3prepared to DBL/4validated and removes most of the data that was only needed for validation.  This includes
the xml columns in the tables chapters and verses and the concordance.refPositions column.  It also drops the table valPunctuation.

	./ValidationCleanup.sh VERSION
	
ProductionUpload
----------------

The Publish.sh program stores Bible files in DBL/3prepared.  These validation programs operate on that copy of the database.  The ValidationCleanup script
copies the file to the DBL/4validated directory.  This script copies the databases into production by copying the files to DBL/5ready and to the static root
of the server.

	./ProductionUpload.sh VERSION


