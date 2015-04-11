/**
* This class contains a Note from a USX parsed Bible
*/
"use strict";

function Note(node) {
	this.caller = node.caller;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = [];
	Object.freeze(this);
};
Note.prototype.tagName = 'note';
Note.prototype.addChild = function(node) {
	this.children.push(node);
};
Note.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	if (this.style === 'x') {
		return('<note caller="' + this.caller + '" style="' + this.style + elementEnd);
	} else {
		return('<note style="' + this.style + '" caller="' + this.caller + elementEnd);
	}
};
Note.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</note>');
};
Note.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Note.prototype.toDOM = function(parentNode) {
	var child = document.createElement('span');
	child.setAttribute('class', this.style);
	parentNode.appendChild(child);
	return(child);
};
Note.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Note.prototype.buildHTML = function(result) {
	result.push('<span class="' + this.style + '">');
	result.push(this.caller);
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildHTML(result);
	}
	result.push('</span>');
};