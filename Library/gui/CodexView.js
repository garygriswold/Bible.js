/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(tableContents, bibleCache) {
	this.tableContents = tableContents;
	this.bibleCache = bibleCache;
	var that = this;
	this.bodyNode = document.getElementById('appTop');
	this.bodyNode.addEventListener(BIBLE.TOC, function(event) {
		var detail = event.detail;
		console.log(JSON.stringify(detail));
		that.showPassage(detail.id);	
	});
	this.bodyNode.addEventListener(BIBLE.SEARCH, function(event) {
		var detail = event.detail;
		console.log(JSON.stringify(detail));
		that.showPassage(detail.id);
	});
	document.addEventListener('scroll', function(event) {
		//console.log('new scroll');
		//for (var e in this) {
		//	console.log(e, this[e]);
		//}
		//for (var e in event) {
		//	console.log(e, event[e]);
		//}
	});
	Object.freeze(this);
};
CodexView.prototype.showPassage = function(nodeId) {
	var chapter = new Reference(nodeId);
	this.removeBody();
	this.showChapter(chapter);
	//var verse = fragment.children[0];
	var verse = this.bodyNode.children[0];
	for (var i=0; i<3; i++) {
		chapter = this.tableContents.nextChapter(chapter);
		this.showChapter(chapter);
	}
	chapter = new Reference(nodeId);
	for (var i=0; i<3; i++) {
		chapter = this.tableContents.priorChapter(chapter);
		this.showChapter(chapter);
	}
	this.scrollToNode(verse);//  TEMP REMOVE
};
CodexView.prototype.showChapter = function(chapter) {
	var that = this;
	this.bibleCache.getChapter(chapter, function(usxNode) {
		if (usxNode.errno) {
			// what to do here?
			console.log((JSON.stringify(usxNode)));
		} else {
			var dom = new DOMBuilder();
			dom.bookCode = chapter.book;
			var fragment = dom.toDOM(usxNode);

			//var verse = fragment.children[0];
			that.bodyNode.appendChild(fragment);
			//that.scrollToNode(verse);  TEMP REMOVE
		}
	});
};
CodexView.prototype.scrollTo = function(nodeId) {
	console.log('scroll to verse', nodeId);
	var verse = document.getElementById(nodeId);
	var rect = verse.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollY, rect.top + window.scrollY);
};
CodexView.prototype.scrollToNode = function(node) {
	var rect = node.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollY, rect.top + window.scrollY);
};
CodexView.prototype.showFootnote = function(noteId) {
	var note = document.getElementById(noteId);
	for (var i=0; i<note.children.length; i++) {
		var child = note.children[i];
		if (child.nodeName === 'SPAN') {
			child.innerHTML = child.getAttribute('note'); + ' ';
		}
	} 
};
CodexView.prototype.hideFootnote = function(noteId) {
	var note = document.getElementById(noteId);
	for (var i=0; i<note.children.length; i++) {
		var child = note.children[i];
		if (child.nodeName === 'SPAN') {
			child.innerHTML = '';
		}
	}
};
CodexView.prototype.removeBody = function() {
	for (var i=this.bodyNode.children.length -1; i>=0; i--) {
		var childNode = this.bodyNode.children[i];
		this.bodyNode.removeChild(childNode);
	}
};
