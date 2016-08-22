/**
* This class contains a ref element as parsed from a USX Bible file.
* This contains one attribute loc, which contain a bible reference
* And a text node, which contains the Bible reference in text form.
*/
function Ref(node) {
	this.loc = node.loc;
	this.emptyElement = node.emptyElement;
	this.children = [];
	Object.freeze(this);
}
Ref.prototype.tagName = 'ref';
Ref.prototype.addChild = function(node) {
	this.children.push(node);
};
Ref.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<ref loc="' + this.loc + elementEnd);
};
Ref.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</ref>');
};
Ref.prototype.buildUSX = function(result) {
	result.push(this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Ref.prototype.toDOM = function(parentNode) {
	var child = new DOMNode('span');
	child.setAttribute('loc', this.loc);
	child.emptyElement = this.emptyElement;
	parentNode.appendChild(child);
	return(child);
};
