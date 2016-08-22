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
	if (parentNode.nodeName === 'article') {
		parentNode.setAttribute('hidden', this.text);
	} else if (parentNode.nodeName === 'section') {
		parentNode.appendText(this.text);
	} else if (! parentNode.hasAttribute('class')) { // Ref nodes have no class
		parentNode.appendText(this.text);
	} else {
		var parentClass = parentNode.getAttribute('class');
		if (parentClass.substr(0, 3) === 'top') {
			var textNode = new DOMNode('span');
			textNode.setAttribute('class', parentClass.substr(3));
			textNode.appendText(this.text);
			textNode.setAttribute('style', 'display:none');
			parentNode.appendChild(textNode);
		} else if (parentNode.hasAttribute('hidden')) {
			parentNode.setAttribute('hidden', this.text);
		} else if (parentClass === 'fr' || parentClass === 'xo') {
			parentNode.setAttribute('hidden', this.text); // permanently hide note.
		} else if (parentClass[0] === 'f' || parentClass[0] === 'x') {
			parentNode.appendText(this.text);
			parentNode.setAttribute('style', 'display:none');
		}
		else {
			parentNode.appendText(this.text);
		}
	}
};

