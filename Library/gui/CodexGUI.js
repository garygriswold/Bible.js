/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexGUI() {
};
CodexGUI.prototype.showFootnote = function(noteId, text) {
	document.getElementById(noteId).innerHTML = text;
	// TextPlugin did not work well, because it caused page to reformat as the text was added
	TweenLite.to('#' + noteId, 1, {text: {value: text, delimiter: ' ', padSpace: true}}); 
};
CodexGUI.prototype.hideFootnote = function(noteId, text) {
	document.getElementById(noteId).innerHTML = '';
};
var codex = new CodexGUI();
