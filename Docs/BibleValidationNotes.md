Bible Validation Notes
======================

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

	Last performed Oct 10, 2016
	Publisher
	XMLTokenizer - perfect
	USXParser - perfect
	HTMLValidator - perfect
	VersesValidator - perfect
ConcordanceValidator - failed
StyleUseValidator - perfect
TableOfContents - perfect
ValidationCleanup
ProductionUpload
	
modify Versions to include ERV-ENG, but not installed.
RunVersions.sh
Upload to aws
	
ENG-SPA
-------

	Last performed Oct 10, 2016
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
	
modify Versions to include ERV-SPA, but not installed.
RunVersions.sh
Upload to aws
	
	
	
Production
----------

	Last performed Aug 22, 2016
	cd ../Versions
	./RunVersions.sh
	Log into aws.amazon.com
	Upload ARBVDPD, KJVPD, NMV, WEB