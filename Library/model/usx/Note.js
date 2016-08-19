/**
* This class contains a Note from a USX parsed Bible
*/
function Note(node) {
	this.caller = node.caller.charAt(0);
	if (this.caller !== '+' && this.caller !== '-' && this.caller !== '*') {
		console.log(JSON.stringify(node));
		throw new Error('Note caller with no + or - or *');
	}
	this.style = node.style;
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
	return('<note caller="' + this.caller + '" style="' + this.style + elementEnd);
};
Note.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</note>');
};
Note.prototype.buildUSX = function(result) {
	result.push(this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Note.prototype.toDOM = function(parentNode, bookCode, chapterNum, noteNum, direction) {
	var nodeId = bookCode + chapterNum + '-' + noteNum;
	var refChild = new DOMNode('span');
	refChild.setAttribute('id', nodeId);
	refChild.setAttribute('class', 'top' + this.style);
	refChild.setAttribute('onclick', "bibleShowNoteClick('" + nodeId + "');");
	switch(this.style) {
		case 'f':
			refChild.textContent = (direction === 'rtl') ? '\u261C ' : '\u261E '; //261C points left, 261E points right
			break;
		case 'x':
			refChild.textContent = (direction === 'rtl') ? '\u261A ' : '\u261B '; //261A points left, 261B points right
			break;
		default:
			refChild.textContent = '* ';
	}
	refChild.emptyElement = this.emptyElement;
	parentNode.appendChild(refChild);
	return(refChild);
};
