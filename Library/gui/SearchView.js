/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
"use strict";

function SearchView(toc, concordance, bibleCache) {
	this.toc = toc;
	this.concordance = concordance;
	this.bibleCache = bibleCache;
	this.words = [];
	this.bookList = [];
	this.viewRoot = document.createDocumentFragment();
	this.bodyNode = document.getElementById('appTop');
	Object.seal(this);
};
SearchView.prototype.showSearch = function(query) {
	
	this.words = query.split(' ');
	var refList = this.concordance.search(query);
	this.bookList = this.refListsByBook(refList);
	for (var i=0; i<this.bookList.length; i++) {
		var bookRef = this.bookList[i];
		this.appendBook(bookRef.bookCode);
		for (var j=0; j<bookRef.refList.length && j < 3; j++) {
			this.appendReference(bookRef.refList[j]);
		}
		if (bookRef.refList.length > 2) {
			this.appendSeeMore(bookRef);
		}
	}
	this.attachSearchView();
};
SearchView.prototype.refListsByBook = function(refList) {
	var bookList = [];
	var priorBook = '';
	for (var i=0; i<refList.length; i++) {
		var bookCode = refList[i].substr(0, 3);
		if (bookCode !== priorBook) {
			var bookRef = { bookCode: bookCode, refList: [ refList[i] ] };
			Object.freeze(bookRef);
			bookList.push(bookRef);
			priorBook = bookCode;
		}
		else {
			bookRef.refList.push(refList[i]);
		}
	}
	Object.freeze(bookList);
	return(bookList);
};
SearchView.prototype.appendBook = function(bookCode) {
	var book = this.toc.find(bookCode);
	var bookNode = document.createElement('p');
	bookNode.setAttribute('class', 'conBook');
	var tocBook = this.toc.find(bookCode);
	bookNode.textContent = tocBook.name;
	this.viewRoot.appendChild(bookNode);
	this.viewRoot.appendChild(document.createElement('hr'));
};
SearchView.prototype.appendReference = function(reference) {
	var that = this;
	var entryNode = document.createElement('p');
	this.viewRoot.appendChild(entryNode);
	var refNode = document.createElement('span');
	refNode.setAttribute('class', 'conRef');
	refNode.textContent = reference.substr(4);
	entryNode.appendChild(refNode);
	entryNode.appendChild(document.createElement('br'));
	this.bibleCache.getVerse(reference, function(verseText) {
		if (verseText instanceof Error) {
			console.log('Error in get verse', JSON.stringify(verseText));
		} else {
			var verseNode = document.createElement('span');
			verseNode.setAttribute('id', 'con' + reference);
			verseNode.setAttribute('class', 'conVerse');
			verseNode.innerHTML = styleSearchWords(verseText);
			entryNode.appendChild(verseNode);
			verseNode.addEventListener('click', function() {
				var nodeId = this.id.substr(3);
				console.log('open chapter', nodeId);
				that.bodyNode.dispatchEvent(new CustomEvent(EVENT.CON2PASSAGE, { detail: { id: nodeId }}));
			});
		}	
	});


	function styleSearchWords(verseText) {
		for (var i=0; i<that.words.length; i++) {
			var search = ' ' + that.words[i] + ' ';
			var regex = new RegExp(search, 'g');
			verseText = verseText.replace(regex, '<span class="conWord"> ' + that.words[i] + ' </span>');
		}
		return(verseText);
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
		var moreNode = document.getElementById(this.id);
		var parentNode = moreNode.parentNode;
		parentNode.removeChild(moreNode);

		var bookCode = this.id.substr(3);
		var bookListItem = findBookInBookList(bookCode);
		for (var i=0; i<bookListItem.length; i++) {
			that.appendReference(bookListItem[i]);
		}
	});

	function findBookInBookList(bookCode) {
		for (var i=0; i<this.bookList.length; i++) {
			if (this.bookList[i].bookCode === bookCode) {
				return(this.bookList[i]);
			}
		}
		return(null);
	}
};
SearchView.prototype.attachSearchView = function() {
	var appTop = document.getElementById('appTop');
	for (var i=appTop.children.length -1; i>=0; i--) {
		var child = appTop.children[i];
		appTop.removeChild(child);
	}
	appTop.appendChild(this.viewRoot);
};

