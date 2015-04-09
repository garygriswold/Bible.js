/**
* This class traverses the USX data model in order to find each book, and chapter
* in order to create a table of contents that is localized to the language of the text.
*/
"use strict"

function TOCBuilder() {
	this.toc = new TOC();
};
TOCBuilder.prototype.readBook = function(usxRoot) {
	this.readRecursively(usxRoot);
};
TOCBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			this.tocBook = new TOCBook(this.bookCode);
			this.toc.addBook(this.tocBook);
			break;
		case 'chapter':
			this.tocBook.lastChapter = node.number;
			break;
		case 'para':
			switch(node.style) {
				case 'ide':
					this.tocBook.encoding = node.children[0].text;
					break;
				case 'h':
					this.tocBook.heading = node.children[0].text;
					break;
				case 'toc1':
					this.tocBook.title = node.children[0].text;
					break;
				case 'toc2':
					this.tocBook.name = node.children[0].text;
					break;
				case 'toc3':
					this.tocBook.abbrev = node.children[0].text;
					break;
			}
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};