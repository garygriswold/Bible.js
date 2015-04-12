/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexGUI() {
};
CodexGUI.prototype.showFootnote = function(nodeId, text) {
	//document.getElementById(nodeId).innerHTML = text + '<span onclick="codex.hideFootnote(\"demo\")"> \u27A0 </span>';
	var node = document.getElementById(nodeId);
	node.textContent = text;
	var span = document.createElement('span');
	span.setAttribute('onclick', 'codex.hideFootnote("demo")');
	span.textContent = ' \u27A0 ';
	node.appendChild(span);
};
CodexGUI.prototype.hideFootnote = function(nodeId) {
	document.getElementById(nodeId).textContent = '';
};
var codex = new CodexGUI();
