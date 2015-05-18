/**
* This class presents the table of contents, and responds to user actions.
*/
"use strict";

function TableContentsView(toc) {
	this.toc = toc;
	this.root = null;
	this.rootNode = document.getElementById('tocRoot');
	var that = this;
	Object.seal(this);
};
TableContentsView.prototype.showView = function() {
	if (! this.root) {
		this.root = this.buildTocBookList();
	}
	if (this.rootNode.children.length < 1) {
		this.rootNode.appendChild(this.root);
	}
};
TableContentsView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.rootNode.removeChild(this.root);
	}
};
TableContentsView.prototype.buildTocBookList = function() {
	var div = document.createElement('div');
	div.setAttribute('id', 'toc');
	div.setAttribute('class', 'tocPage');
	for (var i=0; i<this.toc.bookList.length; i++) {
		var book = this.toc.bookList[i];
		var bookNode = document.createElement('p');
		bookNode.setAttribute('id', 'toc' + book.code);
		bookNode.setAttribute('class', 'tocBook');
		bookNode.textContent = book.name;
		div.appendChild(bookNode);
		var that = this;
		bookNode.addEventListener('click', function() {
			var bookCode = this.id.substring(3);
			that.showTocChapterList(bookCode);
		});
	}
	return(div);
};
TableContentsView.prototype.showTocChapterList = function(bookCode) {
	var book = this.toc.find(bookCode);
	if (book) {
		var root = document.createDocumentFragment();
		var table = document.createElement('table');
		table.setAttribute('class', 'tocChap');
		root.appendChild(table);
		var numCellPerRow = this.cellsPerRow();
		var numRows = Math.ceil(book.lastChapter / numCellPerRow);
		var chaptNum = 1;
		for (var r=0; r<numRows; r++) {
			var row = document.createElement('tr');
			table.appendChild(row);
			for (var c=0; c<numCellPerRow && chaptNum <= book.lastChapter; c++) {
				var cell = document.createElement('td');
				cell.setAttribute('id', 'toc' + bookCode + ':' + chaptNum);
				cell.textContent = chaptNum;
				row.appendChild(cell);
				chaptNum++;
				var that = this;
				cell.addEventListener('click', function() {
					var nodeId = this.id.substring(3);
					that.openChapter(nodeId);
				});
			}
		}
		this.removeAllChapters();
		var bookNode = document.getElementById('toc' + book.code);
		if (bookNode) {
			bookNode.appendChild(root);
		}
	}
};
TableContentsView.prototype.cellsPerRow = function() {
	return(5); // some calculation based upon the width of the screen
}
TableContentsView.prototype.removeAllChapters = function() {
	var div = document.getElementById('toc');
	if (div) {
		for (var i=div.children.length -1; i>=0; i--) {
			var bookNode = div.children[i];
			for (var j=bookNode.children.length -1; j>=0; j--) {
				var chaptTable = bookNode.children[j];
				bookNode.removeChild(chaptTable);
			}
		}
	}
};
TableContentsView.prototype.openChapter = function(nodeId) {
	console.log('open chapter', nodeId);
	this.hideView();
	document.body.dispatchEvent(new CustomEvent(BIBLE.TOC_FIND, { detail: { id: nodeId }}));
};


