/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
function SearchView(toc, concordance, versesAdapter, history) {
	this.toc = toc;
	this.concordance = concordance;
	this.versesAdapter = versesAdapter;
	this.history = history;
	this.query = '';
	this.words = [];
	this.bookList = {};
	this.viewRoot = null;
	this.rootNode = document.getElementById('searchRoot');
	this.scrollPosition = 0;
	Object.seal(this);
}
SearchView.prototype.showView = function(query) {
	this.hideView();
	if (query) {
		console.log('Create new search page');
		this.showSearch(query);
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, 0);
	} else if (this.viewRoot) {
		console.log('Reattach existing search page');
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, this.scrollPosition);
	} else {
		var lastSearch = this.history.lastConcordanceSearch();
		if (lastSearch && lastSearch.length > 0) { // check trim also
			document.body.dispatchEvent(new CustomEvent(BIBLE.SEARCH_START, { detail: { search: lastSearch }}));
		} else {
			console.log('Nothing to search for, display blank page');
			this.showSearch('');
			this.rootNode.appendChild(this.viewRoot);
			window.scrollTo(10, 0);			
		}
	}
};
SearchView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.scrollPosition = window.scrollY;
		this.rootNode.removeChild(this.viewRoot);
	}
};
SearchView.prototype.showSearch = function(query) {
	var that = this;
	this.viewRoot = document.createElement('div');
	this.query = query;
	this.words = query.split(' ');
	this.concordance.search(this.words, function(refList) {
		if (refList instanceof IOError) {
			// Error should display some kind of icon to represent error.
		} else {
			that.bookList = refListsByBook(refList);
			var selectList = selectListWithLimit(that.bookList);
			that.versesAdapter.getVerses(selectList, function(results) {
				if (results instanceof IOError) {
					// Error should display some kind of error icon
				} else {
					var priorBook = null;
					var bookNode = null;
					for (var i=0; i<results.rows.length; i++) {
						var row = results.rows.item(i);
						var nodeId = row.reference;
						var verseText = row.html;
						var reference = new Reference(nodeId);
						var bookCode = reference.book;
						if (bookCode !== priorBook) {
							if (priorBook) {
								var priorList = that.bookList[priorBook];
								if (priorList && priorList.length > 3) {
									that.appendSeeMore(bookNode, priorBook);
								}
							}
							bookNode = that.appendBook(bookCode);
							priorBook = bookCode;
						}
						that.appendReference(bookNode, reference, verseText);
					}
				}
			});
		}
	});
	function refListsByBook(refList) {
		var bookList = {};
		for (var i=0; i<refList.length; i++) {
			var bookCode = refList[i].substr(0, 3);
			if (bookList[bookCode] === undefined) {
				bookList[bookCode] = [ refList[i] ];
			} else {
				bookList[bookCode].push(refList[i]);
			}
		}
		Object.freeze(bookList);
		return(bookList);
	}
	function selectListWithLimit(bookList) {
		var selectList = [];
		var books = Object.keys(bookList);
		for (var i=0; i<books.length; i++) {
			var refList = bookList[books[i]];
			for (var j=0; j<refList.length && j<3; j++) {
				selectList.push(refList[j]);
			}
		}
		Object.freeze(selectList);
		return(selectList);
	}
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
SearchView.prototype.appendReference = function(bookNode, reference, verseText) {
	var that = this;
	var entryNode = document.createElement('p');
	bookNode.appendChild(entryNode);
	var refNode = document.createElement('span');
	refNode.setAttribute('class', 'conRef');
	refNode.textContent = reference.chapterVerse();
	entryNode.appendChild(refNode);
	entryNode.appendChild(document.createElement('br'));

	var verseNode = document.createElement('span');
	verseNode.setAttribute('id', 'con' + reference.nodeId);
	verseNode.setAttribute('class', 'conVerse');
	verseNode.innerHTML = styleSearchWords(verseText);
	entryNode.appendChild(verseNode);
	verseNode.addEventListener('click', function(event) {
		var nodeId = this.id.substr(3);
		console.log('open chapter', nodeId);
		that.hideView();
		document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId, source: that.query }}));
	});

	function styleSearchWords(verseText) {
		var verseWords = verseText.split(/\b/); // Non-destructive, preserves all characters
		var searchWords = verseWords.map(function(wrd) {
			return(wrd.toLocaleLowerCase());
		});
		for (var i=0; i<that.words.length; i++) {
			var word = that.words[i];
			var wordNum = searchWords.indexOf(word.toLocaleLowerCase());
			if (wordNum >= 0) {
				verseWords[wordNum] = '<span class="conWord">' + verseWords[wordNum] + '</span>';
			}
		}
		return(verseWords.join(''));
	}
};
SearchView.prototype.appendSeeMore = function(bookNode, bookCode) {
	var that = this;
	var entryNode = document.createElement('p');
	entryNode.setAttribute('id', 'mor' + bookCode);
	entryNode.setAttribute('class', 'conMore');
	entryNode.textContent = '...';
	bookNode.appendChild(entryNode);
	entryNode.addEventListener('click', function(event) {
		var moreNode = document.getElementById(this.id);
		var parentNode = moreNode.parentNode;
		parentNode.removeChild(moreNode);

		var bookCode = this.id.substr(3);
		var bookNode = document.getElementById('con' + bookCode);
		var refList = that.bookList[bookCode];

		that.versesAdapter.getVerses(refList, function(results) {
			if (results instanceof IOError) {
				// display some error graphic?
			} else {
				for (var i=3; i<results.rows.length; i++) {
					var row = results.rows.item(i);
					var nodeId = row.reference;
					var verseText = row.html;
					var reference = new Reference(nodeId);
					that.appendReference(bookNode, reference, verseText);
				}
			}
		});
	});
};
