/**
* This class contains a Note from a USX parsed Bible
*/
function Note(node) {
	this.caller = node.caller.charAt(0);
	if (this.caller !== '+') {
		console.log(JSON.stringify(node));
		throw new Error('Note caller with no +');
	}
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = [];
	Object.freeze(this);
}
Note.prototype.tagName = 'note';
Note.prototype.addChild = function(node) {
	this.children.push(node);
};
Note.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	if (this.style === 'x') {
		return('<note caller="' + this.caller + ' ' + this.note + '" style="' + this.style + elementEnd);
	} else {
		return('<note style="' + this.style + '" caller="' + this.caller + ' ' + this.note + elementEnd);
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
Note.prototype.toDOM = function(parentNode, bookCode, chapterNum, noteNum) {
	var nodeId = bookCode + chapterNum + '-' + noteNum;
	var refChild = new DOMNode('span');
	refChild.setAttribute('id', nodeId);
	refChild.setAttribute('class', 'top' + this.style);
	refChild.setAttribute('onclick', "bibleShowNoteClick('" + nodeId + "');");
	switch(this.style) {
		case 'f':
			refChild.textContent = '\u261E ';
			break;
		case 'x':
			refChild.textContent = '\u261B ';
			break;
		default:
			refChild.textContent = '* ';
	}
	parentNode.appendChild(refChild);
	return(refChild);
};
