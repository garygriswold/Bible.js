/**
* This class holds the table of contents data each book of the Bible, or whatever books were loaded.
*/
"use strict";

function TOCBook(code) {
	this.code = code;
	this.encoding = '';
	this.heading = '';
	this.title = '';
	this.name = '';
	this.abbrev = '';
	this.lastChapter = 0;
	Object.seal(this);
};