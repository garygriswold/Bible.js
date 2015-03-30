/**
* This object contains a paragraph of the Bible text as parsed from a USX version of the Bible.
*/
"use strict";

function Para(style) {
	this.style = style;
	this.children = []; // contains verse | note | char | text
	Object.freeze(this);
};
Para.prototype.addChild = function(node) {
	this.children.push(node);
};
Para.prototype.toUSX = function() {
	return("{ name: 'para',\n  attributes: { style: '" + this.style + "' },\n  isSelfClosing: false }");
}