/**
* This object contains information about a chapter of the Bible from a parsed USX Bible document.
*/
"use strict";

function Chapter(node) {
	this.number = node.number;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	Object.freeze(this);
};
Chapter.prototype.tagName = 'chapter';
Chapter.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<chapter number="' + this.number + '" style="' + this.style + elementEnd);
}
Chapter.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</chapter>');
}
Chapter.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	result.push(this.closeElement());
}