Bible Validation Notes
======================

The document named BibleDeploymentNotes.md contains the specific instructions for preparing Bibles for
publication.  This document is where specific notes about specific versions must be recorded.

ARBVDPD
-------

	Last performed Aug 15, 2016
	XMLTokenizer - perfect diff no options
	USXParser - perfect diff no options
	HTML - needs work, TOC fields not done, many errors in PSA
	StyleUse - perfect
	Verses - errors diff no options, perfect diff -w
	Concordance - perfect, 6 punctuation marks + space
	TableOfContents - perfect

KJVPD
-----

	Last performed Aug 15, 2016
	XMLTokenizer - perfect diff no options
	USXParser - perfect diff no options
	HTML - needs work, TOC fields not done, there must be some missing elements
	StyleUse - perfect
	Verses - errors diff no options, perfect diff -w
	Concordance - perfect, 11 punctuation marks + space
	TableOfContents - perfect

NMV
---

	Last performed Aug 15, 2016
	XMLTokenizer - perfect, but when space in empty node is removed <name/> and utf-8 preamble is removed
	USXParser - space must be removed in empty nodes book, chapter, verse, and para.  Also, it uses \n CR and 
		before and after </usx>
	HTML - needs work
	StyleUse - perfect
	Verses - errors diff no options, perfect diff -w
	Concordance - perfect, 12 punctuation marks + space
	TableOfContents - perfect

WEB
---

	Last performed Aug 15, 2016
	XMLTokenizer - perfect, diff no options
	USXParser - </name>whitespace</name> problems. Whitespace not recognized. 
		Error occurs in 1MA, ESG, SIR, WIS,
		Error occurs in MRK 3:29 in way that drops space between note and following text.
	HTML - needs work
	StyleUse - perfect
	Verses - errors diff no options, perfect diff -w
	Concordance - perfect, 14 punctuation marks + space
	TableOfContents - perfect