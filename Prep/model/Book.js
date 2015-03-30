/**
* This class contains a book of the Bible
*/
"use strict";

function Book(code, style) {
	this.code = code;
	this.style = style;
	Object.freeze(this);
};
Book.prototype.toUSX = function() {
	return("{ name: 'book',\n  attributes: { code: '" + this.code + "', style: '" + this.style + "' },\n  isSelfClosing: false }");
}