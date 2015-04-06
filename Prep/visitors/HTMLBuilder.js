/**
* This class traverses the USX data model in order to generate the DOM nodes of
* HTML, and optionally generates the HTML string, which can be stored as a file.
*/
"use strict"

function HTMLBuilder() {
	this.concordance = new Concordance();
};
HTMLBuilder.prototype.readBook = function(usxRoot) {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.readRecursively(usxRoot);
};
HTMLBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			this.bookCode = node.code;
			break;
		case 'chapter':
			this.chapter = node.number;
			break;
		case 'verse':
			this.verse = node.number;
			break;
		case 'text':
			var words = node.text.split(/\b/);
			for (var i=0; i<words.length; i++) {
				var word = words[i].replace(/[\u2000-\u206F\u2E00-\u2E7F\\'!"#\$%&\(\)\*\+,\-\.\/:;<=>\?@\[\]\^_`\{\|\}~\s0-9]/g, '');
				if (word.length > 0 && this.chapter > 0 && this.verse > 0) {
					var reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
					this.concordance.addEntry(word.toLowerCase(), reference);
				}
			}
			break;
		default:
			break;
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};
