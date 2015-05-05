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
};
TOC.prototype.find = function(code) {
	return(this.bookMap[code]);
};
TOC.prototype.nextChapter = function(reference) {
	console.log('next chapter param', reference);
	var current = this.bookMap[reference.book];
	if (reference.chapter < current.lastChapter) {
		return(new Reference(reference.book, reference.chapter + 1));
	} else {
		return(new Reference(current.nextBook, 1));
	}
};
TOC.prototype.priorChapter = function(reference) {
	var current = this.bookMap[reference.book];
	if (reference.chapter > 1) {
		return(new Reference(reference.book, reference.chapter -1));
	} else {
		return(new Reference(current.priorBook, current.lastChapter));
	}
};
TOC.prototype.size = function() {
	return(this.bookList.length);
};
TOC.prototype.toJSON = function() {
	return(JSON.stringify(this.bookList, null, ' '));
};