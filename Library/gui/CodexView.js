/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(versionCode) {
	this.versionCode = versionCode;
	var bodyNodes = document.getElementsByTagName('body');
	this.bodyNode = bodyNodes[0];
	Object.freeze(this);
};
CodexView.prototype.showPassage = function(filename, nodeId) {
	var that = this;
	var reader = new NodeFileReader();
	var filepath = 'usx/' + this.versionCode + '/' + filename;
	reader.readTextFile('application', filepath, readSuccessHandler, readFailedHandler);

	function readSuccessHandler(data) {
		var parser = new USXParser();
		var usxNode = parser.readBook(data);
	
		var dom = new DOMBuilder();
		var fragment = dom.toDOM(usxNode);

		that.removeBody();
		var bodyNodes = document.getElementsByTagName('body');
		bodyNodes[0].appendChild(fragment);

		that.scrollTo(nodeId);
	};
	function readFailedHandler(err) {
		console.log(JSON.stringify(err));
	};
};
CodexView.prototype.scrollTo = function(nodeId) {
	console.log('verse', nodeId);
	var verse = document.getElementById(nodeId);
	var rect = verse.getBoundingClientRect();
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
