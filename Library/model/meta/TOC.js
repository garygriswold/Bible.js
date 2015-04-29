/**
* This class holds data for the table of contents of the entire Bible, or whatever part of the Bible was loaded.
*/
"use strict";

function TOC() {
	this.bookList = [];
	this.bookMap = {};
	this.filename = 'toc.json';
	this.isFilled = false;
	Object.seal(this);
};
TOC.prototype.fill = function(books) {
	for (var i=0; i<books.length; i++) {
		this.addBook(books[i]);
	}
	this.isFilled = true;
	Object.freeze(this);	
}
TOC.prototype.addBook = function(book) {
	this.bookList.push(book);
	this.bookMap[book.code] = book;
	Object.freeze(book);
};
TOC.prototype.find = function(code) {
	return(this.bookMap[code]);
};
TOC.prototype.toJSON = function() {
	return(JSON.stringify(this.bookList, null, ' '));
};