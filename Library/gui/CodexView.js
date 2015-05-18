/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

var CODEX_VIEW = { MAX: 10 };

function CodexView(tableContents, bibleCache, statusBarHeight) {
	this.tableContents = tableContents;
	this.bibleCache = bibleCache;
	this.statusBarHeight = statusBarHeight;
	this.chapterQueue = [];
	this.rootNode = document.getElementById('codexRoot');
	var that = this;
	this.addChapterInProgress = false;
	Object.seal(this);
};
CodexView.prototype.hideView = function() {
	this.chapterQueue.splice(0);
	for (var i=this.rootNode.children.length -1; i>=0; i--) {
		this.rootNode.removeChild(this.rootNode.children[i]);
	}
};
CodexView.prototype.showView = function(nodeId) {
	this.chapterQueue.splice(0);
	var chapter = new Reference(nodeId);
	for (var i=0; i<3 && chapter; i++) {
		chapter = this.tableContents.priorChapter(chapter);
		if (chapter) {
			this.chapterQueue.unshift(chapter);
		}
	}
	chapter = new Reference(nodeId);
	this.chapterQueue.push(chapter);
	for (var i=0; i<3 && chapter; i++) {
		chapter = this.tableContents.nextChapter(chapter);
		if (chapter) {
			this.chapterQueue.push(chapter);
		}
	}
	var that = this;
	processQueue(0);

	function processQueue(index) {
		if (index < that.chapterQueue.length) {
			var chapt = that.chapterQueue[index];
			that.rootNode.appendChild(chapt.rootNode);
			that.showChapter(chapt, function() {
				processQueue(index +1);
			});
		} else {
			that.scrollTo(nodeId);
			that.addChapterInProgress = false;
			document.addEventListener('scroll', onScrollHandler);
		}
	}
	function onScrollHandler(event) {
		if (! that.addChapterInProgress && that.chapterQueue.length > 1) {
			// determine the id for the node that is just visible
			if (document.body.scrollHeight - (window.scrollY + window.innerHeight) <= window.outerHeight) {
				that.addChapterInProgress = true;
				var lastChapter = that.chapterQueue[that.chapterQueue.length -1];
				var nextChapter = that.tableContents.nextChapter(lastChapter);
				if (nextChapter) {
					that.rootNode.appendChild(nextChapter.rootNode);
					that.chapterQueue.push(nextChapter);
					that.showChapter(nextChapter, function() {
						that.checkChapterQueueSize('top');
						that.addChapterInProgress = false;
					});
				} else {
					that.addChapterInProgress = false;
				}
			}
			else if (window.scrollY <= window.outerHeight) {
				that.addChapterInProgress = true;
				var saveY = window.scrollY;
				var firstChapter = that.chapterQueue[0];
				var beforeChapter = that.tableContents.priorChapter(firstChapter);
				if (beforeChapter) {
					that.rootNode.insertBefore(beforeChapter.rootNode, firstChapter.rootNode);
					that.chapterQueue.unshift(beforeChapter);
					that.showChapter(beforeChapter, function() {
						window.scrollTo(10, saveY + beforeChapter.rootNode.scrollHeight);
						that.checkChapterQueueSize('bottom');
						that.addChapterInProgress = false;
					});
				} else {
					that.addChapterInProgress = false;
				}
			}
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
			console.log('added chapter', chapter.nodeId);
			callout();
		}
	});
};
CodexView.prototype.checkChapterQueueSize = function(whichEnd) {
	if (this.chapterQueue.length > CODEX_VIEW.MAX) {
		var discard = null;
		switch(whichEnd) {
			case 'top':
				discard = this.chapterQueue.shift();
				break;
			case 'bottom':
				discard = this.chapterQueue.pop();
				break;
			default:
				console.log('unknown end ' + whichEnd + ' in CodexView.checkChapterQueueSize.');
		}
		console.log('discarded chapter ', discard.nodeId, 'at', whichEnd);
	}
};
CodexView.prototype.scrollTo = function(nodeId) {
	var verse = document.getElementById(nodeId);
	var rect = verse.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY - this.statusBarHeight);
};
CodexView.prototype.scrollToNode = function(node) {
	var rect = node.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY - this.statusBarHeight);
};
CodexView.prototype.showFootnote = function(noteId) {
	var note = document.getElementById(noteId);
	for (var i=0; i<note.children.length; i++) {
		var child = note.children[i];
		if (child.nodeName === 'SPAN') {
			child.innerHTML = child.getAttribute('note') + ' ';
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
