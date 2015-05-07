/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(tableContents, bibleCache) {
	this.tableContents = tableContents;
	this.bibleCache = bibleCache;
	this.chapterQueue = [];
	var that = this;
	this.scrollSafeTop = 0;
	this.scrollSafeBottom = 0;
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
		var position = window.scrollY;
		if (position > that.scrollSafeBottom) {
			that.scrollSafeBottom = NaN;
			var lastChapter = that.chapterQueue[that.chapterQueue.length -1];
			var nextChapter = that.tableContents.nextChapter(lastChapter);
			that.bodyNode.appendChild(nextChapter.rootNode);
			that.chapterQueue.push(nextChapter);
			that.showChapter(nextChapter, function() {
				that.setScrollLimits();
			});
		}
		if (position < that.scrollSafeTop) {
			console.log('position', position, that.scrollSafeTop, that.scrollSafeBottom);
			console.log('must add to beginning');
			that.scrollSafeTop = NaN;
			var firstChapter = that.chapterQueue[0];
			var beforeChapter = that.tableContents.priorChapter(firstChapter);
			that.bodyNode.insertBefore(beforeChapter.rootNode, firstChapter.rootNode);
			that.chapterQueue.unshift(beforeChapter);
			that.showChapter(beforeChapter, function() {
				that.setScrollLimits();
			});
		}
	});
	Object.seal(this);// cannot freeze scrollPosition
};
CodexView.prototype.showPassage = function(nodeId) {
	this.chapterQueue.splice(0);
	var chapter = new Reference(nodeId);
	for (var i=0; i<3; i++) {
		chapter = this.tableContents.priorChapter(chapter);
		this.chapterQueue.unshift(chapter);
	}
	chapter = new Reference(nodeId);
	this.chapterQueue.push(chapter);
	for (var i=0; i<3; i++) {
		chapter = this.tableContents.nextChapter(chapter);
		this.chapterQueue.push(chapter);
	}
	this.removeBody();
	var that = this;
	processQueue(0);

	function processQueue(index) {
		if (index < that.chapterQueue.length) {
			var chapt = that.chapterQueue[index];
			that.bodyNode.appendChild(chapt.rootNode);
			that.showChapter(chapt, function() {
				processQueue(index +1);
			});
		} else {
			that.scrollTo(nodeId);
			that.setScrollLimits();
		}
	}
};
CodexView.prototype.showChapter = function(chapter, callout) {
	var that = this;
	this.bibleCache.getChapter(chapter, function(usxNode) {
		if (usxNode.errno) {
			// what to do here?
			console.log((JSON.stringify(usxNode)));
			callout();
		} else {
			var dom = new DOMBuilder();
			dom.bookCode = chapter.book;
			var fragment = dom.toDOM(usxNode);
			chapter.rootNode.appendChild(fragment);
			callout();
		}
	});
};
CodexView.prototype.scrollTo = function(nodeId) {
	var verse = document.getElementById(nodeId);
	var rect = verse.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY);
};
CodexView.prototype.scrollToNode = function(node) {
	var rect = node.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY);
};
CodexView.prototype.setScrollLimits = function() {
	var secondChapt = this.chapterQueue[1];
	var secondRect = secondChapt.rootNode.getBoundingClientRect();
	var lastChapt = this.chapterQueue[this.chapterQueue.length -1];
	var lastRect = lastChapt.rootNode.getBoundingClientRect();
	this.scrollSafeTop = secondRect.top + window.scrollY;
	this.scrollSafeBottom = lastRect.top + window.scrollY - window.innerHeight;
	//console.log('safe top', this.scrollSafeTop, '   safe bot', this.scrollSafeBottom);
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
