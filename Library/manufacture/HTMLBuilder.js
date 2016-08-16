/**
* This class traverses a DOM tree in order to create an equivalent HTML document.
*/
function HTMLBuilder() {
	this.result = [];
	Object.seal(this);
}
HTMLBuilder.prototype.toHTML = function(fragment) {
	this.result = [];
	this.readRecursively(fragment);
	return(this.result.join(''));
};
HTMLBuilder.prototype.readRecursively = function(node) {
	var nodeName = node.nodeName.toLowerCase();
	switch(node.nodeType) {
		case 11: // fragment
			break;
		case 1: // element
			this.result.push(node.preWhiteSpace, '<', nodeName);
			var attrs = node.attrNames();
			for (var i=0; i<attrs.length; i++) {
				this.result.push(' ', attrs[i], '="', node.getAttribute(attrs[i]), '"');
			}
			this.result.push('>');
			if (node.textContent) {
				this.result.push(node.textContent);
			}
			break;
		case 3: // text
			this.result.push(node.preWhiteSpace, node.textContent);
			break;
		case 13: // empty element
			this.result.push(node.preWhiteSpace, '<', nodeName, '>');
			break;
		default:
			throw new Error('Unexpected nodeType ' + node.nodeType + ' in HTMLBuilder.toHTML().');
	}
	for (var child=0; child<node.childNodes.length; child++) {
		this.readRecursively(node.childNodes[child]);
	}
	if (node.nodeType === 1) {
		this.result.push('</', nodeName, '>');
	}
};
HTMLBuilder.prototype.toJSON = function() {
	return(this.result.join(''));
};


