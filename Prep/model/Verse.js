/**
* This chapter contains the verse of a Bible text as parsed from a USX Bible file.
*/
"use strict";

function Verse(number, style) {
	this.number = number;
	this.style = style;
	Object.freeze(this);
};
Verse.prototype.toUSX = function() {
	return("{ name: 'verse',\n  attributes: { number: '" + this.number + "', style: '" + this.style + "' },\n  isSelfClosing: true }");
}