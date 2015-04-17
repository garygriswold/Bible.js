/**
* This class holds data for the table of contents of the entire Bible, or whatever part of the Bible was loaded.
*/
"use strict";

function TOC(books) {
	this.bookList = books || [];
	this.bookMap = {};
	for (var i=0; i<this.bookList.length; i++) {
		var book = this.bookList[i];
		this.bookMap[book.code] = book;
		Object.freeze(book);
	}
	Object.freeze(this);
};
TOC.prototype.addBook = function(book) {
	this.bookList.push(book);
	this.bookMap[book.code] = book;
};
TOC.prototype.find = function(code) {
	return(this.bookMap[code]);
};