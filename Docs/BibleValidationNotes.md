Bible Validation Notes
======================

BibleAPPNW
----------

For many functions, including the presentation of text, it is faster to debug the App using BibleAppNW.
However, to do this it is essential to have the current Versions.db files there and the current and
correct Bible Files.  The tasks described here could be automated.

	cd $HOME/Library/Application Support/BibleAppNW/databases
	sqlite3 Databases.db
	select * from Databases
	
	Identify any needed new versions to be added: (currently ERV-ENG.db)
	insert into Databases (origin, name, description, estimated_size) values ('file__0', {filename}, {filename}, 31457280);
	
	select * from Databases
	Note the column 1, number of Versions.db (currently 9)
	Note the column 1, number of any needed version (WEB 10, KJVPD 12, NMV 20, ARBVDPD 22, ERV-ENG 24)
	
	.quit
	cd file__0
	
	For each of the files, that has a Bible in releases copy it
	cp $HOME/ShortSands/BibleApp/Versions/Versions.db 9
	cp $HOME/ShortSands/DBL/5ready/WEB.db 10
	cp $HOME/ShortSands/DBL/5ready/KJVPD.db 12
	cp $HOME/ShortSands/DBL/5ready/NMV.db 20
	cp $HOME/ShortSands/DBL/5ready/ARBVDPD.db 22
	cp $HOME/ShortSands/DBL/3prepared/ERV-ENG.db 24
	
	Insert into Settings.db and new version.
	sqlite3 8
	insert into Installed (version, filename, timestamp) values ('ERV-ENG', 'ERV-ENG.db', '2016-10-05T16:45:00');
	
	For repeated uploads of the same file use the following:
	cp $HOME/ShortSands/DBL/3prepared/ERV-ENG.db "$HOME/Library/Application Support/BibleAppNW/databases/file__0/24"
	
	For repeated uploads of the Versions.db
	cp $HOME/ShortSands/BibleApp/Versions/Versions.db "$HOME/Library/Application Support/BibleAppNW/databases/file__0/9"



The document named BibleDeploymentNotes.md contains the specific instructions for preparing Bibles for
publication.  This document is where specific notes about specific versions must be recorded.

ARBVDPD
-------
 
	Last performed Aug 22, 2016
	Publisher
	XMLTokenizer - perfect diff no options
	USXParser - perfect diff, 2 whitespace chars diff
	HTML - perfect
	Verses - perfect
	Concordance - perfect, 6 punctuation marks + space
	StyleUse - perfect
	TableOfContents - perfect
	ValidationCleanup
	ProductionUpload

KJVPD
-----

	Last performed Aug 22, 2016
	Publisher
	XMLTokenizer - perfect diff no options
	USXParser - perfect diff double \r\n before </usx>
	HTML - perfect
	Verses - perfect
	Concordance - perfect, 11 punctuation marks + space
	StyleUse - perfect
	TableOfContents - perfect
	ValidationCleanup
	ProductionUpload

NMV
---

	Last performed Aug 22, 2016
	Publisher
	XMLTokenizer NMV  nospace - whitespace diffs on preamble and </usx> 
	USXParser - space must be removed in empty nodes: book, chapter, verse, and para.  Also, it uses \n CR and 
		before and after </usx>	
	HTML - change END_EMPTY to '/>' and then errors are the same as above.
	Verses - perfect
	Concordance - perfect, 12 punctuation marks + space
	StyleUse - perfect
	TableOfContents - perfect
	ValidationCleanup
	ProductionUpload

WEB
---

	Last performed Aug 22, 2016
	Publisher	
	XMLTokenizer - perfect, diff no options
	USXParser - perfect, diff no options, double \r\n before </usx>
	HTML - change END_EMPTY to '/>', then perfect
	Verses - perfect
	Concordance - perfect, 14 punctuation marks + space
	StyleUse - perfect
	TableOfContents - perfect
	ValidationCleanup
	ProductionUpload
	
ERV-ENG
-------

	Last performed Oct 7, 2016
	Publisher
	XMLTokenizer - perfect
	USXParser - perfect
	HTMLValidator - perfect
	VersesValidator - perfect
	ConcordanceValidator - perfect
	StyleUseValidator - perfect
	TableOfContents - perfect
	ValidationCleanup
	ProductionUpload
	
	modify Versions to include ERV-ENG, but not installed.
	RunVersions.sh
	Upload to aws
	
Production
----------

	Last performed Aug 22, 2016
	cd ../Versions
	./RunVersions.sh
	Log into aws.amazon.com
	Upload ARBVDPD, KJVPD, NMV, WEB