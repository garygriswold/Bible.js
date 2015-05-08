/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(tableContents, bibleCache) {
	this.tableContents = tableContents;
	this.bibleCache = bibleCache;
	this.chapterQueue = [];
	var that = this;
	this.addChapterInProgress = false;
	document.body.addEventListener(BIBLE.TOC, function(event) {
		console.log(JSON.stringify(event.detail));
		that.showPassage(event.detail.id);	
	});
	document.body.addEventListener(BIBLE.SEARCH, function(event) {
		console.log(JSON.stringify(event.detail));
		that.showPassage(event.detail.id);
	});
	document.addEventListener('scroll', function(event) {
		//console.log('on scroll', that.bodyNode.scrollTop, that.bodyNode.scrollHeight, window.innerHeight, window.height);
		//console.log('scrolling', that.bodyNode.scrollTop, document.body.scrollTop, window.pageYOffset, document.body.parentElement.scrollTop);
		/// here test if chapter is being added.
		if (! that.addChapterInProgress) {
			if (document.body.scrollTop + (window.innerHeight * 2) >= document.body.scrollHeight) {
				that.addChapterInProgress = true;
				console.log('add chapter below');
				var lastChapter = that.chapterQueue[that.chapterQueue.length -1];
				var nextChapter = that.tableContents.nextChapter(lastChapter);
				document.body.appendChild(nextChapter.rootNode);
				that.chapterQueue.push(nextChapter);
				that.showChapter(nextChapter, function() {
					that.addChapterInProgress = false;
				});
			}
			if (document.body.scrollTop < window.innerHeight) {
				that.addChapterInProgress = true;
				console.log('must add to beginning');
				var firstChapter = that.chapterQueue[0];
				var beforeChapter = that.tableContents.priorChapter(firstChapter);
				document.body.insertBefore(beforeChapter.rootNode, firstChapter.rootNode);
				that.chapterQueue.unshift(beforeChapter);
				that.showChapter(beforeChapter, function() {
					that.addChapterInProgress = false;
				});
			}
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
			document.body.appendChild(chapt.rootNode);
			that.showChapter(chapt, function() {
				processQueue(index +1);
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
			//var topNode = chapter.rootNode.children[0];
			//var rect = topNode.getBoundingClientRect();
			var rect = chapter.rootNode.getBoundingClientRect();
			console.log('addec chapter', chapter.nodeId);
			console.log('bounding rect top=', rect.top, ' bottom=', rect.bottom);
			console.log('element scrolltop=', chapter.rootNode.scrollTop, '  height=', chapter.rootNode.height);
			console.log('body scrolltop ', document.body.scrollTop,  '  height=', document.body.height);
			console.log('window innerHeight=', window.innerHeight, '  window.height=', window.height);
			console.log('window scroll=', window.scroll, '  window pageYOffset=', window.pageYOffset);
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
	var bodyNode = document.body;
	for (var i=bodyNode.children.length -1; i>=0; i--) {
		var childNode = bodyNode.children[i];
		bodyNode.removeChild(childNode);
	}
};
