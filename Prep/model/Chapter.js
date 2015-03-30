/**
* This object contains information about a chapter of the Bible from a parsed USX Bible document.
*/
"use strict";

function Chapter(number, style) {
	this.number = number;
	this.style = style;
	Object.freeze(this);
};
Chapter.prototype.toUSX = function() {
	return("{ name: 'chapter',\n  attributes: { number: '" + this.number + "', style: '" + this.style + "' },\n  isSelfClosing: true }");
}