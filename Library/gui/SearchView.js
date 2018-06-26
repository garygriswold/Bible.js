/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
function SearchView(toc, concordance, versesAdapter, historyAdapter, version, localizeNumber) {
	this.toc = toc;
	this.concordance = concordance;
	this.versesAdapter = versesAdapter;
	this.historyAdapter = historyAdapter;
	this.version = version;
	this.localizeNumber = localizeNumber;
	this.query = null;
	this.lookup = new Lookup(toc);
	this.words = [];
	this.bookList = {};
	this.viewRoot = null;
	this.rootNode = document.createElement('div');
	this.rootNode.id = 'searchRoot';
	document.body.appendChild(this.rootNode);
	this.stopIcon = new StopIcon('#FF0000');
	this.scrollPosition = 0;
	this.searchField = null;
	Object.seal(this);
}
SearchView.prototype.showView = function() {
	document.body.style.backgroundColor = '#FFF';
	if (this.searchField === null) {
		this.searchField = this.showSearchField();
	}
	this.rootNode.appendChild(this.searchField);
	 
	if (this.viewRoot) {
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, this.scrollPosition);
	} else {
		var that = this;
		this.historyAdapter.lastConcordanceSearch(function(lastSearch) {
			if (lastSearch instanceof IOError || lastSearch === null) {
				console.log('Nothing to search for, display blank page');
			} else {
				that.searchField.children[0].value = lastSearch;
				that.startSearch(lastSearch);
			}
		});
	}
};
SearchView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.scrollPosition = window.scrollY;
		for (var i=this.rootNode.children.length -1; i>=0; i--) {
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
	}
	this.stopIcon.hideIcon();
};
SearchView.prototype.startSearch = function(query) {
	this.query = query;
	console.log('Create new search page');
	if (! this.lookup.find(query)) {
		this.showSearch(query);
		for (var i=this.rootNode.children.length -1; i>=1; i--) { // remove viewRoot if present
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, 0);
	}
};
SearchView.prototype.showSearchField = function() {
	var searchField = document.createElement('div');
	searchField.setAttribute('class', 'searchBorder');
	var wid = window.innerWidth * 0.75;
	searchField.setAttribute('style', 'width:' + wid + 'px');
	searchField.setAttribute('style', 'padding:3px 5px');
	
	var inputField = document.createElement('input');
	inputField.setAttribute('type', 'text');
	inputField.setAttribute('class', 'searchField');
	inputField.setAttribute('style', 'width:' + (wid - 10) + 'px');
	
	searchField.appendChild(inputField);
	var that = this;
	inputField.addEventListener('keyup', function(event) {
		if (event.keyCode === 13) {
			//if (typeof(cordova) !== 'undefined') {
			//Utility.hideKeyboard(function(hidden) {
			callNative('Utility', 'hideKeyboard', [], "S", function(hidden) {
				console.log("Keyboard did hide " + hidden);
			});
			//}
			that.startSearch(this.value.trim());
		}
	});
	return(searchField);
};
SearchView.prototype.showSearch = function(query) {
	var that = this;
	this.viewRoot = document.createElement('div');
	//if (this.version.silCode === 'cnm') {
	if (this.version.langCode === 'zh' || this.version.langCode === 'th') {
		this.words = query.split('');
	} else {
		this.words = query.split(' ');
	}
	this.concordance.search2(this.words, function(refList) {
		if (refList instanceof IOError) {
			console.log('SEARCH RETURNED ERROR', JSON.stringify(refList));
			that.stopIcon.showIcon();
		} else if (refList.length === 0) {
			that.stopIcon.showIcon();
		} else {
			that.stopIcon.hideIcon();
			that.bookList = refListsByBook(refList);
			var selectList = selectListWithLimit(that.bookList);
			var selectMap = that.prepareSelect(selectList);
			that.versesAdapter.getVerses(Object.keys(selectMap), function(results) {
				if (results instanceof IOError) {
					that.stopIcon.showIcon();
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
						that.appendReference(bookNode, reference, verseText, selectMap[nodeId]);
					}
				}
			});
		}
	});
	function refListsByBook(refList) {
		var bookList = {};
		for (var i=0; i<refList.length; i++) {
			var bookCode = refList[i][0].substr(0, 3);
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
SearchView.prototype.appendReference = function(bookNode, reference, verseText, refList) {
	var that = this;
	var entryNode = document.createElement('p');
	entryNode.setAttribute('id', 'con' + reference.nodeId);
	bookNode.appendChild(entryNode);
	var refNode = document.createElement('span');
	refNode.setAttribute('class', 'conRef');
	refNode.textContent = this.localizeNumber.toLocal(reference.chapterVerse());
	entryNode.appendChild(refNode);
	entryNode.appendChild(document.createElement('br'));

	var verseNode = document.createElement('span');
	verseNode.setAttribute('class', 'conVerse');
	verseNode.innerHTML = styleSearchWords(verseText, refList);
	entryNode.appendChild(verseNode);
	entryNode.addEventListener('click', function(event) {
		var nodeId = this.id.substr(3);
		console.log('open chapter', nodeId);
		document.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId, source: that.query }}));
	});

	function styleSearchWords(verseText, refList) {
		var parts = refList[0].split(';');
		var wordPosition = null;
		var verseWords = null;
		if (that.version.silCode === 'cnm') {
			wordPosition = parseInt(parts[1] - 2);
			verseWords = verseText.split('');
		} else {
			wordPosition = parseInt(parts[1]) * 2 - 3;
			verseWords = verseText.split(/\b/); // Non-destructive, preserves all characters
		}
		if (wordPosition < 0) wordPosition = 0;
		
		var searchWords = verseWords.map(function(wrd) {
			return(wrd.toLocaleLowerCase());
		});
		
		for (var i=0; i<that.words.length; i++) {
			var word = that.words[i];
			var wordNum = searchWords.indexOf(word.toLocaleLowerCase(), wordPosition);
			if (wordNum >= 0) {
				verseWords[wordNum] = '<span class="conWord">' + verseWords[wordNum] + '</span>';
				wordPosition = wordNum;
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
	entryNode.textContent = String.fromCharCode(183) + String.fromCharCode(183) + String.fromCharCode(183);
	bookNode.appendChild(entryNode);
	entryNode.addEventListener('click', function(event) {
		var moreNode = document.getElementById(this.id);
		var parentNode = moreNode.parentNode;
		parentNode.removeChild(moreNode);

		var bookCode = this.id.substr(3);
		var bookNode = document.getElementById('con' + bookCode);
		var refList = that.bookList[bookCode];
		var selectMap = that.prepareSelect(refList);

		that.versesAdapter.getVerses(Object.keys(selectMap), function(results) {
			if (results instanceof IOError) {
				// display some error graphic?
			} else {
				for (var i=3; i<results.rows.length; i++) {
					var row = results.rows.item(i);
					var nodeId = row.reference;
					var verseText = row.html;
					var reference = new Reference(nodeId);
					that.appendReference(bookNode, reference, verseText, selectMap[nodeId]);
				}
			}
		});
	});
};
/**
* This is a private method which takes a list of search results and returns a
* list of verses to be selected.  This method is declare public only because it is
* used by two other methods.
*/
SearchView.prototype.prepareSelect = function(refList) {
	var searchMap = {};
	for (var i=0; i<refList.length; i++) {
		var first = refList[i][0];
		var parts = first.split(';');
		searchMap[parts[0]] = refList[i]; // When a search find multiple words in the same verse, this discards all but the last.
	}
	return(searchMap);
};
