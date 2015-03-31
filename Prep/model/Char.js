/**
* This class contains a character style as parsed from a USX Bible file.
*/
"use strict";

function Char(style) {
	this.style = style;
	this.children = [];
	Object.freeze(this);
};
Char.prototype.tagName = 'char';
Char.prototype.addChild = function(node) {
	this.children.push(node);
};
Char.prototype.openElement = function() {
	return('<char style="' + this.style + '">');
}
Char.prototype.closeElement = function() {
	return('</char>');
}