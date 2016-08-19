/**
* This class contains a text string as parsed from a USX Bible file.
*/
function Text(text) {
	this.text = text;
	Object.freeze(this);
}
Text.prototype.tagName = 'text';
Text.prototype.buildUSX = function(result) {
	result.push(this.text);
};
Text.prototype.toDOM = function(parentNode, bookCode, chapterNum) {
	var that = this;
	//if (parentNode === null || parentNode.nodeName === 'article') {
		// discard text node
	//} else 
	if (parentNode.nodeName === 'section') {
		appendTextNode(parentNode);
	} else if (! parentNode.hasAttribute('class')) { // Ref nodes have no class
		parentNode.setAttribute('note', this.text); 
	} else {
		var parentClass = parentNode.getAttribute('class');
		var grParentNode = parentNode.parentNode;
		var grParentClass = (grParentNode) ? grParentNode.getAttribute('class') : null;
		if (parentClass.substr(0, 3) === 'top') {
			var textNode = new DOMNode('span');
			textNode.setAttribute('class', parentClass.substr(3));
			textNode.setAttribute('note', this.text);
			parentNode.appendChild(textNode);
		} else if (parentNode.hasAttribute('hidden')) {
			parentNode.setAttribute('hidden', this.text);
		} else if (parentClass === 'fr' || parentClass === 'xo') {
			parentNode.setAttribute('hidden', this.text); // permanently hide note.
		} else if (parentClass[0] === 'f' || parentClass[0] === 'x') {
			parentNode.setAttribute('note', this.text); // hide footnote text in note attribute of parent.
		} else if (grParentClass != null && (grParentClass[0] === 'f' || grParentClass[0] === 'x')) {
			parentNode.setAttribute('note', this.text); // hide footnote text in note attribute of grand parent.
		}
		else {
			appendTextNode(parentNode);
		}
	}
	
	function appendTextNode(parentNode) {
		var child = new DOMNode('text');
		child.textContent = that.text;
		parentNode.appendChild(child);
	}
};

