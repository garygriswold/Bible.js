/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(versionCode) {
	this.versionCode = versionCode;
	this.bibleCache = new BibleCache(versionCode);
	this.bodyNode = document.getElementById('appTop');
	Object.freeze(this);
};
CodexView.prototype.showPassage = function(nodeId) {
	var that = this;
	this.bibleCache.getChapter(nodeId, function(usxNode) {
		if (usxNode instanceof Error) {
			// what to do here?
			console.log((JSON.stringify(usxNode)));
		} else {
			var util = require('util');
			var dom = new DOMBuilder();
			dom.bookCode = nodeId.split(':')[0];
			var fragment = dom.toDOM(usxNode);
			var verse = fragment.children[0];
			that.removeBody();
			that.bodyNode.appendChild(fragment);
			that.scrollToNode(verse);
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
CodexView.prototype.findVerse = function(reference) {
	// This command must access the passage, and recall the text of the verse
	// How does it do this?  Is the USX copy of the Bible in memory?
	// Or, does it read the verse from permanent storage.
	// Reading would require having a good idea where each chapter or chapter and
	// verse are located.
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
//var codex = new CodexView();
