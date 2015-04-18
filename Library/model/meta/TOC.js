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
// This needs a better solution. Filename should be stored somewhere
TOC.prototype.findFilename = function(book) {
	for (var i=0; i<this.bookList.length; i++) {
		if (book.code === this.bookList[i].code) {
			var num = i +1;
			var zeroPad = (num < 10) ? '00' : '0';
			return(zeroPad + num + book.code + '.usx');
		}
	}
	return(null);
};