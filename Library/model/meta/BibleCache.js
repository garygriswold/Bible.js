/**
* This class handles all request to deliver scripture.  It handles all passage display requests to display passages of text,
* and it also handles all requests from concordance search requests to display individual verses.
* It will deliver the content from cache if it is present.  Or, it will find the content in persistent storage if it is
* not present in cache.  All content retrieved from persistent storage is added to the cache.
*
* Note: GNG 4/23/15 In the first writing of this class, it is a cache which holds the entire text of the Bible
*/
"use strict";

function BibleCache() {
	this.bookList = [];
	this.bookMap = {};
	Object.freeze(this);
};
BibleCache.prototype.addBook = function(usx) {
	var book = findBook(usx);
	this.bookList.push(book);
	this.bookMap[book.code] = book;
};
BibleCache.prototype.getVerseById = function(nodeId) {
	var parts = nodeId.split(':');
	return(this.getVerse(parts[0], parts[1], parts[2]));
};
BibleCache.prototype.getVerse = function(bookCode, chapterNum, verseNum) {
	var book = this.bookMap[bookCode];
	var chapter = book.getChapter(chapterNum);
	return(chapter.getVerse(verseNum));
};
BibleCache.prototype.getChapterById = function(nodeId) {
	var parts = nodeId.split(':');
	return(this.getChapter(parts[0], parts[1]));
};
BibleCache.prototype.getChapter = function(bookCode, chapterNum) {
	var book = this.bookMap[bookCode];
	return(book.getChapter(chapterNum));
};