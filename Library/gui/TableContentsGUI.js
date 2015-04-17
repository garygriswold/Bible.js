/**
* This class presents the table of contents, and responds to user actions.
*/
"use strict";

function TableContentsGUI() {
	this.toc = null;
	var bodyNodes = document.getElementsByTagName('body');
	this.bodyNode = bodyNodes[0];
	Object.seal(this);
};
TableContentsGUI.prototype.showTocBookList = function(versionCode) {
	if (app.toc) { // should check the version
		this.buildTocBookList();
	}
	else {
		var that = this;
		var reader = new NodeFileReader();
		var filename = 'usx/' + versionCode + '/toc.json';
		reader.readTextFile('application', filename, readSuccessHandler, readFailureHandler);
	}
	function readSuccessHandler(data) {
		var bookList = JSON.parse(data);
		that.toc = new TOC(bookList);
		that.buildTocBookList();
	};
	function readFailureHandler(err) {
		console.log('read TOC.json failure ' + JSON.stringify(err));
		that.toc = new TOC([]);
	};
}
TableContentsGUI.prototype.buildTocBookList = function() {//versionCode) {
	var root = document.createDocumentFragment();
	var div = document.createElement('div');
	div.setAttribute('id', 'toc');
	div.setAttribute('class', 'tocPage');
	root.appendChild(div);
	for (var i=0; i<this.toc.bookList.length; i++) {
		var book = this.toc.bookList[i];
		var bookNode = document.createElement('p');
		bookNode.setAttribute('id', book.code + 'toc');
		bookNode.setAttribute('class', 'tocBook');
		bookNode.setAttribute('onclick', 'app.tableContentsGUI.showTocChapterList("' +  book.code + '");');
		bookNode.textContent = book.name;
		div.appendChild(bookNode);
	}
	this.removeBody();
	this.bodyNode.appendChild(root);
};
TableContentsGUI.prototype.showTocChapterList = function(bookCode) {
	var book = this.toc.find(bookCode);
	if (book) {
		var root = document.createDocumentFragment();
		var table = document.createElement('table');
		table.setAttribute('id', book.code + 'ch');
		table.setAttribute('class', 'tocChap');
		root.appendChild(table);
		var numCellPerRow = this.cellsPerRow();
		var numRows = Math.ceil(book.lastChapter / numCellPerRow);
		console.log('numRows ', numRows);;
		var chaptNum = 1;
		for (var r=0; r<numRows; r++) {
			var row = document.createElement('tr');
			table.appendChild(row);
			for (var c=0; c<numCellPerRow && chaptNum <= book.lastChapter; c++) {
				var cell = document.createElement('td');
				cell.setAttribute('onclick', 'app.tableContentsGUI.openChapter("' + bookCode + '", "' + chaptNum + '");');
				cell.textContent = chaptNum;
				row.appendChild(cell);
				chaptNum++;
			}
		}
		this.removeAllChapters();
		var bookNode = document.getElementById(book.code + 'toc');
		if (bookNode) {
			bookNode.appendChild(root);
		}
	}
};
TableContentsGUI.prototype.cellsPerRow = function() {
	return(5); // some calculation based upon the width of the screen
}
TableContentsGUI.prototype.removeBody = function() {
	for (var i=this.bodyNode.children.length -1; i>=0; i--) {
		var childNode = this.bodyNode.children[i];
		div.removeChild(childNode);
	}
};
TableContentsGUI.prototype.removeAllChapters = function() {
	var div = document.getElementById('toc');
	for (var i=div.children.length -1; i>=0; i--) {
		var bookNode = div.children[i];
		for (var j=bookNode.children.length -1; j>=0; j--) {
			var chaptTable = bookNode.children[j];
			bookNode.removeChild(chaptTable);
		}
	}
};
TableContentsGUI.prototype.openChapter = function(bookCode, chapterNum) {
	var book = this.toc.find(bookCode);
	console.log('open chapter', book.code, chapterNum);
};

