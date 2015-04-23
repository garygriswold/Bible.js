/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
"use strict";

function SearchView(concordance, toc) {
	this.concordance = concordance;
	this.toc = toc;
	this.query = '';
	this.words = [];
	this.bookList = [];
	this.viewRoot = document.createDocumentFragment();
	Object.freeze(this);
};
SearchView.prototype.showSearch = function(query) {
	this.query = query;
	this.words = query.split(' ');
	var refList = this.concordance.search(query);
	this.bookList = this.refListsByBook(refList);
	for each(var i=0; i<bookList.length; i++) {
		var bookRef = bookList[i];
		this.appendBook(bookRef.bookCode);
		for (var j=0; j<bookRef.refList.length && j < 3; j++) {
			this.appendReference(bookRef.refList[i]);
		}
		if (bookRef.refList.length > 2) {
			this.appendSeeMore(bookRef);
		}
	}

};
SearchView.prototype.refListsByBook = function(refList) {
	var bookList = [];
	Object.freeze(bookList);
	var priorBook = '';
	for (var i=0; i<refList.length; i++) {
		var bookCode = refList[i].substr(0, 3);
		if (bookCode !== priorBook) {
			var bookRef = { bookCode: bookCode, refList: [ refList[i] ] };
			Object.freeze(bookRef);
			bookList.push(bookRef);
		}
		else {
			bookRef.push(refList[i]);
		}
	}
	return(bookList);
}
SearchView.prototype.appendBook = function(bookCode) {
	var book = toc.find(bookCode);
	var bookNode = document.createElement('p');
	var bookNode.setAttribute('class', 'conBook');
	this.viewRoot.appendChild(bookNode);
	this.viewRoot.appendChild(document.createElement('hr'));
};
SearchView.prototype.appendReference = function(reference) {
	var entryNode = document.createElement('p');
	this.viewRoot.appendChild(entryNode);
	var refNode = document.createElement('span');
	refNode.setAttribute('class', 'conRef');
	entryNode.appendChild(refNode);
	entryNode.appendChild(document.createElement('br'));
	var verseText = this.codex.findVerse(reference);// function to be written
	var verseNode = document.createElement('span');
	verseNode.setAttribute('id', 'con' + reference);
	verseNode.setAttribute('class', 'conVerse');
	verseNode.innerHTML = styleSearchWords(verseText);
	entryNode.appendChild(verseNode);
	verseNode.addEventListener('click', function() {
		var nodeId = this.id.substr(3);
		var parts = nodeId.split(':');
		var book = this.toc.find(parts[0]);
		var filename = this.toc.findFilename(book);
		console.log('open chapter', nodeId);
		this.bodyNode.dispatchEvent(new CustomEvent(EVENT.CON2PASSAGE, { detail: { filename: filename, id: nodeId }}));
	});

	function styleSearchWords(verseText) {
		for (var i=0; i<this.words.length; i++) {
			var search = ' ' + words[i] + ' ';
			verseText.replace(/search/g, '<span class="conWord">' + words[i] + '</span>');
		}
	}
};
SearchView.prototype.appendSeeMore = function(bookRef) {
	var that = this;
	var entryNode = document.createElement('p');
	entryNode.setAttribute('id', 'mor' + bookRef.bookCode);
	entryNode.setAttribute('class', 'conMore');
	entryNode.textContent = '...';
	this.viewRoot.appendChild(entryNode);
	entryNode.addEventListener('click', function() {
		seeMoreHandler(this.id);
	});

	function seeMoreHandler(nodeId) {
		var moreNode = document.getElementById(nodeId);
		var parentNode = moreNode.parentNode;
		parentNode.removeChild(moreNode);

		var bookCode = nodeId.substr(3);
		var bookListItem = findBookInBookList(bookCode);
		for (var i=0; i<bookListItem.length; i++) {
			this.appendReference(bookListItem[i]);
		}
	}

	function findBookInBookList(bookCode) {
		for (var i=0; i<this.bookList.length; i++) {
			if (this.bookList[i].bookCode === bookCode) {
				return(this.bookList[i]);
			}
		}
		return(null);
	}
}
SearchView.prototype.showView = function() {
	var appTopNode = document.getElementById('appTop');
	for (var i=appTopNode.children -1; i>=0; i--) {
		appTopNode.removeNode(appTopNode.children[i]);
	}
	appTopNode.appendChild(this.viewRoot);
};
