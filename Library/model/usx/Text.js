/**
* This class contains a text string as parsed from a USX Bible file.
*/
"use strict";

function Text(text) {
	this.text = text;
	this.footnotes = [ 'f', 'fr', 'ft', 'fqa', 'x', 'xt', 'xo' ];
	Object.freeze(this);
};
Text.prototype.tagName = 'text';
Text.prototype.buildUSX = function(result) {
	result.push(this.text);
};
Text.prototype.toDOM = function(parentNode, bookCode, chapterNum, noteNum) {
	if (parentNode !== undefined && parentNode.tagName !== 'ARTICLE') {
		if (parentNode.nodeType === 1 && this.footnotes.indexOf(parentNode.getAttribute('class')) >= 0) {
			parentNode.setAttribute('note', this.text); // hide footnote text in note attribute of parent.
			var nodeId = bookCode + chapterNum + '-' + noteNum;
			parentNode.addEventListener('click', function() {
				app.codex.hideFootnote(nodeId);
				event.stopPropagation();
			});
		}
		else {
			var child = document.createTextNode(this.text);
			parentNode.appendChild(child);
		}
	}
};
Text.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Text.prototype.buildHTML = function(result) {
	result.push(this.text);
};
