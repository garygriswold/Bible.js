/**
* This class contains a character style as parsed from a USX Bible file.
*/
"use strict";

function Char(style) {
	this.style = style;
	this.text = "";
	Object.freeze(this);
};
Char.prototype.addChild = function(node) {
	this.text = node;
};