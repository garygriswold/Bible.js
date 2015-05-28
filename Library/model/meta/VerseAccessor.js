/**
* This class extracts single verses from Chapters and returns the text of those
* verses for use in Concordance Search and possibly other uses.  This is written
* as a class, because BibleCache and SearchView both have only one instance, but
* SearchView could be accessing the text of many verses concurrently.
*/
"use strict";
function VerseAccessor(bibleCache, reference) {
	this.bibleCache = bibleCache;
	this.reference = reference;
	this.insideVerse = false;
	this.result = [];
	Object.seal(this);
}
VerseAccessor.prototype.getVerse = function(callback) {
	var that = this;
	this.bibleCache.getChapter(this.reference, function(chapter) {
		if (chapter.errno) {
			callback(chapter);
		} else {
			var verseNum = String(that.reference.verse);
			scanRecursively(chapter, verseNum);
			callback(that.result.join(' '));
		}
	});
	function scanRecursively(node, verseNum) {
		if (that.insideVerse) {
			if (node.tagName === 'verse') {
				that.insideVerse = false;
			}
			else if (node.tagName === 'text') {
				that.result.push(node.text);
			}
		} else {
			if (node.tagName === 'verse' && node.number === verseNum) {
				that.insideVerse = true;
			}
		}
		if (node.tagName !== 'note' && 'children' in node) {
			for (var i=0; i<node.children.length; i++) {
				scanRecursively(node.children[i], verseNum);
			}
		}
	}
};