/**
* This class contains a optbreak element as parsed from a USX Bible file.
* This is an empty element, which defines an optional location for a line
* break
*/
function OptBreak(node) {
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	Object.freeze(this);
}
OptBreak.prototype.tagName = 'optbreak';
//OptBreak.prototype.addChild = function(node) {
//	this.children.push(node);
//};
OptBreak.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<optbreak' + elementEnd);
};
OptBreak.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</optbreak>');
};
OptBreak.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	//for (var i=0; i<this.children.length; i++) {
	//	this.children[i].buildUSX(result);
	//}
	result.push(this.closeElement());
};
OptBreak.prototype.toDOM = function(parentNode) {
	return(parentNode);
	//if (this.style === 'fr' || this.style === 'xo') {
	//	return(null);// this drop these styles from presentation
	//}
	//else {
	//var child = new DOMNode('span');
	//child.setAttribute('class', this.style);
	//parentNode.appendChild(child);
	//return(child);
	//}
};
