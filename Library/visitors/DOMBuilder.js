/**
* This class reads a file using the Cordova File Plugin, parses the contents into USX,
* translates the contents to DOM, and the plugs the content into the correct location 
* in the page.
*/
function DOMBuilder() {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;

	this.tree = null;
	this.currBook = null;
	this.currChapter = null;
	this.currPara = null;
	this.currElement = null;
	Object.seal(this);
};
DOMBuilder.prototype.toDOM = function(usxRoot) {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.tree = document.createDocumentFragment();
	this.readRecursively(usxRoot);
	return(this.tree);
};
DOMBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'usx':
			break;
		case 'book':
			this.bookCode = node.code;
			this.currBook = node.toDOM(this.tree);
			this.currChapter = this.currPara = this.currElement = null;
			break;
		case 'chapter':
			this.chapter = node.number;
			this.currChapter = node.toDOM(this.currBook, this.bookCode);
			this.currPara = this.currElement = null;
			break;
		case 'para':
			var paraParent = this.currChapter || this.currBook;
			this.currPara = node.toDOM(paraParent);
			this.currElement = null;
			break;
		case 'verse':
			this.verse = node.number;
			node.toDOM(this.currPara, this.bookCode, this.chapter);
			this.currElement = null;
			break;
		case 'text':
			var textPara = this.currElement || this.currPara;
			if (textPara) {
				node.toDOM(textPara);
			}
			break;
		case 'char':
			this.currElement = node.toDOM(this.currPara);
			break;
		case 'note':
			this.currElement = node.toDOM(this.currPara);
			break;
		default:
			throw new Error('Unknown tagname ' + node.tagName + ' in DOMBuilder.readBook');
			break;
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};