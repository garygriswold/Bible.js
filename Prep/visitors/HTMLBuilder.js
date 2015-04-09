/**
* This class traverses the USX data model in order to generate the DOM nodes of
* HTML, and optionally generates the HTML string, which can be stored as a file.
*/
"use strict"

function HTMLBuilder(document) {
	this.document = document;
	this.top = this.document.createElement('div');
	this.parent = this.topDiv
};
HTMLBuilder.prototype.readBook = function(usxRoot) {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.readRecursively(usxRoot);
	return(this.top);
};
HTMLBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'usx':
		this.parent = node.toDOM(this.document, this.parent);
			break;
		case 'book':
			this.bookCode = node.code;
			this.parent = node.toDOM(this.document, this.parent);
			break;
		case 'chapter':
			this.chapter = node.number;
			this.parent = node.toDOM(this.document, this.parent);
			break;
		case 'verse':
			this.verse = node.number;
			this.parent = node.toDOM(this.document, this.parent);
			break;
		case 'para':
			this.parent = node.toDOM(this.document, this.parent);
			break;
		case 'text':
			this.parent = node.toDOM(this.document, this.parent);
			break;
		case 'char':
			this.parent = node.toDOM(this.document, this.parent);
			break;
		case 'note':
			this.parent = node.toDOM(this.document, this.parent);
			break;
		default:
			break;
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};


