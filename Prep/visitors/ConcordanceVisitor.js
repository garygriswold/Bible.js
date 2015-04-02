/**
* This class traverses the USX data model in order to find each word, and 
* reference to that word.
*/
"use strict"

function ConcordanceVisitor() {
	this.concordance = new Concordance();
};
ConcordanceVisitor.prototype.readBook = function(usxRoot) {
	this.usxRoot = usxRoot;
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.readRecursively(this.usxRoot);
};
ConcordanceVisitor.prototype.readRecursively = function(node) {
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
			var words = node.text.split(/\s+/);
			for (var i=0; i<words.length; i++) {
				var word = words[i].replace(/[\?\"\'.!@#$%,]/, '');
				var reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
				this.concordance.addEntry(word, reference);
			}
			break;
		default:
			if ('children' in node) {
				for (var i=0; i<node.children.length; i++) {
					this.readRecursively(node.children[i]);
				}
			}

	}
};