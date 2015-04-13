/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexGUI() {
};
CodexGUI.prototype.showFootnote = function(noteId, text) {
	document.getElementById(noteId).innerHTML = text;
};
CodexGUI.prototype.hideFootnote = function(noteId, text) {
	document.getElementById(noteId).innerHTML = '';
};
var codex = new CodexGUI();
