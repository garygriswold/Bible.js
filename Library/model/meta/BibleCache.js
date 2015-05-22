/**
* This class handles all request to deliver scripture.  It handles all passage display requests to display passages of text,
* and it also handles all requests from concordance search requests to display individual verses.
* It will deliver the content from cache if it is present.  Or, it will find the content in persistent storage if it is
* not present in cache.  All content retrieved from persistent storage is added to the cache.
*
* On May 3, 2015 some performance checks were done.  The time measurements where from a sample of 4, the memory from a sample of 1.
* 1) Read Chapter 11.2ms, 49K heap increase
* 2) Parse USX 6.0ms, 306K heap increase
* 3) Generate Dom 2.16ms, 85K heap increase
*/
"use strict";

function BibleCache(types) {
	this.types = types;
	this.chapterMap = {};
	this.reader = new NodeFileReader(types.location);
	this.parser = new USXParser();
	Object.freeze(this);
};
BibleCache.prototype.getChapter = function(reference, callback) {
	var that = this;
	var chapter = this.chapterMap[reference.nodeId];
	
	if (chapter !== undefined) {
		callback(chapter);
	} else {
		var filepath = this.types.getAppPath(reference.path());
		this.reader.readTextFile(filepath, function(data) {
			if (data.errno) {
				console.log('BibleCache.getChapter ', JSON.stringify(data));
				callback(data);
			} else {
				chapter = that.parser.readBook(data);
				that.chapterMap[reference.nodeId] = chapter;
				callback(chapter);				
			}
		});
	}
};
//
// Try rewriting this without parsing.  But, I would need to parse the fragment.
// 
BibleCache.prototype.getVerse = function(reference, callback) {
	this.getChapter(reference, function(chapter) {
		if (chapter.errno) {
			callback(chapter);
		} else {
			console.log(reference.nodeId, reference.verse, chapter.children.length);
			var versePosition = findVerse(reference.verse, chapter);
			console.log('position', versePosition);
			var verseContent = findVerseContent(versePosition);
			callback(verseContent);
		}
	});
	function findVerse(verseNum, chapter) {
		for (var i=0; i<chapter.children.length; i++) {
			var child = chapter.children[i];
			if (child.tagName === 'verse' && child.number == verseNum) {
				return({parent: chapter, childIndex: i+1});
			}
			else if (child.tagName === 'para') {
				for (var j=0; j<child.children.length; j++) {
					var grandChild = child.children[j];
					if (grandChild.tagName === 'verse' && grandChild.number == verseNum) {
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
