/**
* This class contains a book of the Bible
*/
"use strict";

function Book(code, style) {
	this.code = code;
	this.style = style;
	this.children = []; // contains text
	Object.freeze(this);
};
Book.prototype.tagName = 'book';
Book.prototype.addChild = function(node) {
	this.children.push(node);
};
Book.prototype.openElement = function() {
	return('\n  <book code="' + this.code + '" style="' + this.style + '">');
}
Book.prototype.closeElement = function() {
	return('</book>');
}
Book.prototype.toUSX = function() {
	return("{ name: 'book',\n  attributes: { code: '" + this.code + "', style: '" + this.style + "' },\n  isSelfClosing: false }");
}