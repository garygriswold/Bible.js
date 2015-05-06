/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(tableContents, bibleCache) {
	this.tableContents = tableContents;
	this.bibleCache = bibleCache;
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
		console.log('position', position, that.scrollSafeTop, that.scrollSafeBottom);
		if (position > that.scrollSafeBottom) {
			console.log('must add to end');
			that.scrollSafeBottom = NaN;
			// Here I must get the key for the last node,
			// get next node
			// show chapter
			// on callback setScrollLimits();
		}
		if (position < that.scrollSafeTop) {
			console.log('must add to beginning');
			that.scrollSafeTop = NaN;
			// Here I must get the key for the first node
			// get the prior node
			// show chapter
			// on callback setScrollLimits();
		}
	});
	Object.seal(this);// cannot freeze scrollPosition
};
CodexView.prototype.showPassage = function(nodeId) {
	var queue = [];
	var chapter = new Reference(nodeId);
	for (var i=0; i<3; i++) {
		chapter = this.tableContents.priorChapter(chapter);
		queue.unshift(chapter);
	}
	chapter = new Reference(nodeId);
	queue.push(chapter);
	for (var i=0; i<3; i++) {
		chapter = this.tableContents.nextChapter(chapter);
		queue.push(chapter);
	}
	this.removeBody();
	var that = this;
	processQueue(queue);

	function processQueue(queue) {
		if (queue.length > 0) {
			var chapt = queue.shift();
			that.bodyNode.appendChild(chapt.rootNode);
			that.showChapter(chapt, function() {
				processQueue(queue);
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
	var firstNode = this.bodyNode.firstElementChild;
	var secondNode = firstNode.nextElementSibling;
	var secondRect = secondNode.getBoundingClientRect();
	var lastNode = this.bodyNode.lastElementChild;
	var lastRect = lastNode.getBoundingClientRect();
	this.scrollSafeTop = secondRect.top + window.scrollY;
	this.scrollSafeBottom = lastRect.top + window.scrollY - window.innerHeight;
	console.log('safe top', this.scrollSafeTop, '   safe bot', this.scrollSafeBottom);
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
