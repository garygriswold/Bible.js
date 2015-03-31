/**
* This object contains a paragraph of the Bible text as parsed from a USX version of the Bible.
*/
"use strict";

function Para(style) {
	this.style = style;
	this.children = []; // contains verse | note | char | text
	Object.freeze(this);
};
Para.prototype.tagName = 'para';
Para.prototype.addChild = function(node) {
	this.children.push(node);
};
Para.prototype.openElement = function() {
	return('\n  <para style="' + this.style + '">');
}
Para.prototype.closeElement = function() {
	return('</para>');
}
Para.prototype.toUSX = function() {
	return("{ name: 'para',\n  attributes: { style: '" + this.style + "' },\n  isSelfClosing: false }");
}