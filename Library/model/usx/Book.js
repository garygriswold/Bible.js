/**
* This class contains a book of the Bible
*/
function Book(node) {
	this.code = node.code;
	this.style = node.style;
	this.emptyElement = node.emptyElement;
	this.children = []; // contains text
	Object.freeze(this);
}
Book.prototype.tagName = 'book';
Book.prototype.addChild = function(node) {
	this.children.push(node);
};
Book.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<book code="' + this.code + '" style="' + this.style + elementEnd);
};
Book.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</book>');
};
Book.prototype.buildUSX = function(result) {
	result.push(this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Book.prototype.toDOM = function(parentNode) {
	var article = new DOMNode('article');
	article.setAttribute('id', this.code);
	article.setAttribute('class', this.style);
	article.emptyElement = this.emptyElement;
	parentNode.appendChild(article);
	return(article);
};
