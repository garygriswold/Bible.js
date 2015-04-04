/**
* This object contains a paragraph of the Bible text as parsed from a USX version of the Bible.
*/
"use strict";

function Para(node) {
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // contains verse | note | char | text
	Object.freeze(this);
};
Para.prototype.tagName = 'para';
Para.prototype.addChild = function(node) {
	this.children.push(node);
};
Para.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<para style="' + this.style + elementEnd);
};
Para.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</para>');
};
Para.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Para.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Para.prototype.buildHTML = function(result) {
	var identStyles = [ 'ide', 'sts', 'rem', 'h', 'toc1', 'toc2', 'toc3' ];
	if (identStyles.indexOf(this.style) === -1) {
		result.push('\n<p class="' + this.style + '">');
		for (var i=0; i<this.children.length; i++) {
			this.children[i].buildHTML(result);
		}
		result.push('</p>');
	}
};
