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
	this.query = '';
	this.words = [];
	this.bookList = [];
	this.viewRoot = null;
	this.rootNode = document.getElementById('searchRoot');
	this.scrollPosition = 0;
	var that = this;
	Object.seal(this);
};
SearchView.prototype.showView = function(query) {
	if (query) {
		this.hideView();
		this.showSearch(query);
		this.rootNode.appendChild(this.viewRoot);
	} else if (this.viewRoot) {
		if (this.rootNode.children.length < 1) {
			this.rootNode.appendChild(this.viewRoot);
			window.scrollTo(10, this.scrollPosition);
		}
	} else {
		// must present search input form TO BE DONE
	}
};
SearchView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.scrollPosition = window.scrollY;
		this.rootNode.removeChild(this.viewRoot);
	}
};
SearchView.prototype.showSearch = function(query) {
	this.viewRoot = document.createElement('div');
	this.query = query;
	this.words = query.split(' ');
	var refList = this.concordance.search(this.words);
	this.bookList = this.refListsByBook(refList);
	for (var i=0; i<this.bookList.length; i++) {
		var bookRef = this.bookList[i];
		var bookNode = this.appendBook(bookRef.bookCode);
		for (var j=0; j<bookRef.refList.length && j < 3; j++) {
			var ref = new Reference(bookRef.refList[j]);
			this.appendReference(bookNode, ref);
		}
		if (bookRef.refList.length > 3) {
			this.appendSeeMore(bookNode, bookRef);
		}
	}
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
	bookNode.setAttribute('id', 'con' + bookCode);
	this.viewRoot.appendChild(bookNode);
	var titleNode = document.createElement('span');
	titleNode.setAttribute('class', 'conBook');
	var tocBook = this.toc.find(bookCode);
	titleNode.textContent = tocBook.name;
	bookNode.appendChild(titleNode);
	bookNode.appendChild(document.createElement('hr'));
	return(bookNode);
};
SearchView.prototype.appendReference = function(bookNode, reference) {
	var that = this;
	var entryNode = document.createElement('p');
	bookNode.appendChild(entryNode);
	var refNode = document.createElement('span');
	refNode.setAttribute('class', 'conRef');
	refNode.textContent = reference.chapterVerse();
	entryNode.appendChild(refNode);
	entryNode.appendChild(document.createElement('br'));
	var accessor = new VerseAccessor(this.bibleCache, reference);
	accessor.getVerse(function(verseText) {
		if (verseText.errno) {
			console.log('Error in get verse', JSON.stringify(verseText));
		} else {
			var verseNode = document.createElement('span');
			verseNode.setAttribute('id', 'con' + reference.nodeId);
			verseNode.setAttribute('class', 'conVerse');
			verseNode.innerHTML = styleSearchWords(verseText);
			entryNode.appendChild(verseNode);
			verseNode.addEventListener('click', function(event) {
				var nodeId = this.id.substr(3);
				console.log('open chapter', nodeId);
				that.hideView();
				document.body.dispatchEvent(new CustomEvent(BIBLE.SEARCH_FIND, { detail: { id: nodeId, source: that.query }}));
			});
		}	
	});

	function styleSearchWords(verseText) {
		var verseWords = verseText.split(/\b/); // Non-destructive, preserves all characters
		for (var i=0; i<that.words.length; i++) {
			var word = that.words[i];
			var wordNum = verseWords.indexOf(word);
			if (wordNum >= 0) {
				verseWords[wordNum] = '<span class="conWord">' + word + '</span>';
			}
		}
		return(verseWords.join(''));
	}
};
SearchView.prototype.appendSeeMore = function(bookNode, bookRef) {
	var that = this;
	var entryNode = document.createElement('p');
	entryNode.setAttribute('id', 'mor' + bookRef.bookCode);
	entryNode.setAttribute('class', 'conMore');
	entryNode.textContent = '...';
	bookNode.appendChild(entryNode);
	entryNode.addEventListener('click', function(event) {
		var moreNode = document.getElementById(this.id);
		var parentNode = moreNode.parentNode;
		parentNode.removeChild(moreNode);

		var bookCode = this.id.substr(3);
		var bookNode = document.getElementById('con' + bookCode);
		var refList = findBookInBookList(bookCode);
		for (var i=3; i<refList.length; i++) {
			var ref = new Reference(refList[i]);
			that.appendReference(bookNode, ref);
		}
	});

	function findBookInBookList(bookCode) {
		for (var i=0; i<that.bookList.length; i++) {
			if (that.bookList[i].bookCode === bookCode) {
				return(that.bookList[i].refList);
			}
		}
		return(null);
	}
};

