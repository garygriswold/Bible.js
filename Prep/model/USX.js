/**
* This class is the root object of a parsed USX document
*/
"use strict";

function USX(version) {
	this.version = version;
	this.children = []; // includes books, chapters, and paragraphs
	Object.freeze(this);
};
USX.prototype.addChild = function(node) {
	this.children.push(node);
};
USX.prototype.toUSX = function() {
	return("{ name: 'usx',\n  attributes: { version: '" + this.version + "' },\n  isSelfClosing: false }");
};