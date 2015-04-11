/**
* This class traverses a DOM tree in order to create an equivalent HTML document.
*/
"use strict"

function HTMLBuilder() {
	this.result = [];
	Object.freeze(this);
};
HTMLBuilder.prototype.toHTML = function(fragment) {
	this.readRecursively(fragment);
	return(this.result.join(''));
};
HTMLBuilder.prototype.readRecursively = function(node) {
	console.log('size result ', this.result.length);
	switch(node.nodeType) {
		case 11: // fragment
			//this.parent = node.toDOM(this.document, this.parent);
			break;
		case 1: // element
			this.bookCode = node.code;
			this.parent = node.toDOM(this.document, this.parent);
			this.result.push('<', node.tagName);
			for (var i=0; i<node.attributes.length; i++) {
				this.result.push(' ', node.attributes[i].nodeName, '="', node.attributes[i].nodeValue, '"');
			}
			this.result.push('>');
			break;
		case 3: // text
			this.result.push(node.text);
			break;
		default:
			throw new Error('Unexpected nodeType ' + node.nodeType + ' in HTMLBuilder.toHTML().');
			break;
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
	if (node.nodeType === 1) {
		this.result.push('</', node.tagName, '>');
	}
};


