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
Text.prototype.toDOM = function(parentNode, bookCode, chapterNum, noteNum) {
	if (parentNode === null || parentNode.nodeName === 'article') {
		// discard text node
	} else {
		var nodeId = bookCode + chapterNum + '-' + noteNum;
		var parentClass = parentNode.getAttribute('class');
		if (parentClass.substr(0, 3) === 'top') {
			var textNode = new DOMNode('span');
			textNode.setAttribute('class', parentClass.substr(3));
			textNode.setAttribute('note', this.text);
			parentNode.appendChild(textNode);
		} else if (parentClass[0] === 'f' || parentClass[0] === 'x') {
			parentNode.setAttribute('note', this.text); // hide footnote text in note attribute of parent.
		}
		else {
			var child = new DOMNode('text');
			child.textContent = this.text;
			parentNode.appendChild(child);
		}
	}
};

