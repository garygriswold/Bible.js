/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView() {
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
var codex = new CodexView();
