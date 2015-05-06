/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(tableContents, bibleCache) {
	this.tableContents = tableContents;
	this.bibleCache = bibleCache;
	var that = this;
	this.scrollPosition = window.scrollY;
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
	this.bodyNode.addEventListener('scroll', function(event) {
		var position = window.scrollY;
		if (position > this.scrollPosition) {
			console.log('scrolling down');
			// check if 1st verse of last chapter is above bottom of the page
			// if last chapter has become visible at bottom
			// get next chapter push onto next queue
			// what processes next queue, because it might already be in process.
		} else {
			console.log('scrolling up');
			// check if last verse of first chapter is visible below top of the page
			// if the first chapter has become visible at top
			// get prior chapter and push onto prior queue
			// what processes prior queue, because it might already be in process.
		}
	});
	Object.freeze(this);
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
	var fragment = document.createDocumentFragment();
	var topNode = document.createElement('div');
	fragment.appendChild(topNode);

	this.removeBody();
	this.bodyNode.appendChild(fragment);

	var that = this;
	processQueue(queue);
	function processQueue(queue) {
		if (queue.length > 0) {
			var chapt = queue.shift();
			topNode.appendChild(chapt.rootNode);
			that.showChapter(chapt, function() {
				processQueue(queue);
			});
		} else {
			that.scrollTo(nodeId);
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
