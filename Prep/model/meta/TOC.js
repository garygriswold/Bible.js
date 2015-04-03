/**
* This class holds data for the table of contents of the entire Bible, or whatever part of the Bible was loaded.
*/
"use strict";

function TOC() {
	this.books = [];
	Object.freeze(this);
};
TOC.prototype.addBook = function(book) {
	this.books.push(book);
};