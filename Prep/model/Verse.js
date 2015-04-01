/**
* This chapter contains the verse of a Bible text as parsed from a USX Bible file.
*/
"use strict";

function Verse(node) {
	this.number = node.number;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	Object.freeze(this);
};
Verse.prototype.tagName = 'verse';
Verse.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<verse number="' + this.number + '" style="' + this.style + elementEnd);
};
Verse.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</verse>');
};
Verse.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	result.push(this.closeElement());
};