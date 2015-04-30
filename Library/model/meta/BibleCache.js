/**
* This class handles all request to deliver scripture.  It handles all passage display requests to display passages of text,
* and it also handles all requests from concordance search requests to display individual verses.
* It will deliver the content from cache if it is present.  Or, it will find the content in persistent storage if it is
* not present in cache.  All content retrieved from persistent storage is added to the cache.
*/
"use strict";

function BibleCache(versionCode) {
	this.versionCode = versionCode;
	this.chapterMap = {};
	this.reader = new NodeFileReader('application');
	this.parser = new USXParser();
	Object.freeze(this);
};
BibleCache.prototype.getChapter = function(nodeId, callback) {
	var that = this;
	var chapter = this.chapterMap[nodeId];
	
	if (chapter !== undefined) {
		callback(chapter);
	} else {
		var filepath = 'usx/' + this.versionCode + '/' + nodeId.replace(':', '/') + '.usx';
		this.reader.readTextFile(filepath, readFileSuccess, function(err) {
			console.log('BibleCache.getChapter ', JSON.stringify(err));
			callback(err);
		});
	}
	function readFileSuccess(data) {
		chapter = that.parser.readBook(data);
		that.chapterMap[nodeId] = chapter;
		callback(chapter);
	}
};
BibleCache.prototype.getVerse = function(nodeId, callback) {
	var parts = nodeId.split(':');
	this.getChapter(parts[0] + ':' + parts[1], function(chapter) {
		if (chapter instanceof Error) {
			callback(chapter);
		} else {
			var versePosition = findVerse(parts[2], chapter);
			var verseContent = findVerseContent(versePosition);
			callback(verseContent);
		}
	});
	function findVerse(verseNum, chapter) {
		for (var i=0; i<chapter.children.length; i++) {
			var child = chapter.children[i];
			if (child.tagName === 'verse' && child.number === verseNum) {
				return({parent: chapter, childIndex: i+1});
			}
			else if (child.tagName === 'para') {
				for (var j=0; j<child.children.length; j++) {
					var grandChild = child.children[j];
					if (grandChild.tagName === 'verse' && grandChild.number === verseNum) {
						return({parent: child, childIndex: j+1});
					}
				}
			}
		}
		return(undefined);		
	}
	function findVerseContent(position) {
		var result = [];
		for (var i=position.childIndex; i<position.parent.children.length; i++) {
			var child = position.parent.children[i];
			if (child.tagName !== 'verse') {
				result.push(child.text);
			}
			else {
				return(result.join(' '));
			}
		}
		return(result.join(' '));
	}
};
