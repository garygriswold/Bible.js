/**
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
"use strict"

var BIBLE = { TOC: 'bible-toc', LOOK: 'bible-look', SEARCH: 'bible-search', BACK: 'bible-back', FORWARD: 'bible-forward', 
		LAST: 'bible-last' };

function AppViewController(versionCode) {
	this.versionCode = versionCode;
	this.bibleCache = new BibleCache(this.versionCode);
};
AppViewController.prototype.begin = function() {
	var types = new AssetType('application', this.versionCode);
	types.tableContents = true;
	types.chapterFiles = true;
	types.history = true;
	types.concordance = true;
	var that = this;
	var assets = new AssetController(types);
	assets.checkBuildLoad(function(typesLoaded) {
		that.tableContents = assets.tableContents();
		console.log('loaded toc', that.tableContents.size());
		that.history = assets.history();
		console.log('loaded history', that.history.size());
		that.concordance = assets.concordance();
		console.log('loaded concordance', that.concordance.size());

		that.tableContentsView = new TableContentsView(that.tableContents);
		that.searchView = new SearchView(that.tableContents, that.concordance, that.bibleCache);
		that.codexView = new CodexView(that.tableContents, that.bibleCache);
		Object.freeze(that);

		//that.tableContentsView.showTocBookList();
		that.searchView.showSearch("risen");
	});
};
/**
* This class presents the table of contents, and responds to user actions.
*/
"use strict";

function TableContentsView(toc) {
	this.toc = toc;
	this.root = null;
	Object.seal(this);
};
TableContentsView.prototype.showTocBookList = function() {
	if (! this.root) {
		this.root = this.buildTocBookList();
	}
	this.removeBody();
	document.body.appendChild(this.root);
};
TableContentsView.prototype.buildTocBookList = function() {
	var root = document.createDocumentFragment();
	var div = document.createElement('div');
	div.setAttribute('id', 'toc');
	div.setAttribute('class', 'tocPage');
	root.appendChild(div);
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
	return(root);
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
TableContentsView.prototype.removeBody = function() {
	var bodyNode = document.body;
	for (var i=bodyNode.children.length -1; i>=0; i--) {
		var childNode = bodyNode.children[i];
		bodyNode.removeChild(childNode);
	}
};
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
	document.body.dispatchEvent(new CustomEvent(BIBLE.TOC, { detail: { id: nodeId }}));
};


/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(tableContents, bibleCache) {
	this.tableContents = tableContents;
	this.bibleCache = bibleCache;
	this.chapterQueue = [];
	var that = this;
	this.addChapterInProgress = false;
	document.body.addEventListener(BIBLE.TOC, function(event) {
		console.log(JSON.stringify(event.detail));
		that.showPassage(event.detail.id);	
	});
	document.body.addEventListener(BIBLE.SEARCH, function(event) {
		console.log(JSON.stringify(event.detail));
		that.showPassage(event.detail.id);
	});
	document.addEventListener('scroll', function(event) {
		if (! that.addChapterInProgress) {
			if (document.body.scrollHeight - (window.scrollY + window.innerHeight) <= window.outerHeight) {
				that.addChapterInProgress = true;
				var lastChapter = that.chapterQueue[that.chapterQueue.length -1];
				var nextChapter = that.tableContents.nextChapter(lastChapter);
				document.body.appendChild(nextChapter.rootNode);
				that.chapterQueue.push(nextChapter);
				that.showChapter(nextChapter, function() {
					that.addChapterInProgress = false;
				});
			}
			else if (window.scrollY <= window.outerHeight) {
				that.addChapterInProgress = true;
				var saveY = window.scrollY;
				var firstChapter = that.chapterQueue[0];
				var beforeChapter = that.tableContents.priorChapter(firstChapter);
				document.body.insertBefore(beforeChapter.rootNode, firstChapter.rootNode);
				that.chapterQueue.unshift(beforeChapter);
				that.showChapter(beforeChapter, function() {
					window.scrollTo(10, saveY + beforeChapter.rootNode.scrollHeight);
					that.addChapterInProgress = false;
				});
			}
		}
	});
	Object.seal(this);
};
CodexView.prototype.showPassage = function(nodeId) {
	this.chapterQueue.splice(0);
	var chapter = new Reference(nodeId);
	for (var i=0; i<3; i++) {
		chapter = this.tableContents.priorChapter(chapter);
		this.chapterQueue.unshift(chapter);
	}
	chapter = new Reference(nodeId);
	this.chapterQueue.push(chapter);
	for (var i=0; i<3; i++) {
		chapter = this.tableContents.nextChapter(chapter);
		this.chapterQueue.push(chapter);
	}
	this.removeBody();
	var that = this;
	processQueue(0);

	function processQueue(index) {
		if (index < that.chapterQueue.length) {
			var chapt = that.chapterQueue[index];
			document.body.appendChild(chapt.rootNode);
			that.showChapter(chapt, function() {
				processQueue(index +1);
			});
		} else {
			that.scrollTo(nodeId);
		}
	}
};
CodexView.prototype.showChapter = function(chapter, callout) {
	var that = this;
	this.bibleCache.getChapter(chapter, function(usxNode) {
		if (usxNode.errno) {
			// what to do here?
			console.log((JSON.stringify(usxNode)));
			callout();
		} else {
			var dom = new DOMBuilder();
			dom.bookCode = chapter.book;
			var fragment = dom.toDOM(usxNode);
			chapter.rootNode.appendChild(fragment);
			console.log('added chapter', chapter.nodeId);
			callout();
		}
	});
};
CodexView.prototype.scrollTo = function(nodeId) {
	var verse = document.getElementById(nodeId);
	var rect = verse.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY);
};
CodexView.prototype.scrollToNode = function(node) {
	var rect = node.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY);
};
CodexView.prototype.showFootnote = function(noteId) {
	var note = document.getElementById(noteId);
	for (var i=0; i<note.children.length; i++) {
		var child = note.children[i];
		if (child.nodeName === 'SPAN') {
			child.innerHTML = child.getAttribute('note'); + ' ';
		}
	} 
};
CodexView.prototype.hideFootnote = function(noteId) {
	var note = document.getElementById(noteId);
	for (var i=0; i<note.children.length; i++) {
		var child = note.children[i];
		if (child.nodeName === 'SPAN') {
			child.innerHTML = '';
		}
	}
};
CodexView.prototype.removeBody = function() {
	var bodyNode = document.body;
	for (var i=bodyNode.children.length -1; i>=0; i--) {
		var childNode = bodyNode.children[i];
		bodyNode.removeChild(childNode);
	}
};
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
	this.viewRoot = document.createDocumentFragment();
	this.bodyNode = document.getElementById('appTop');
	Object.seal(this);
};
SearchView.prototype.showSearch = function(query) {
	this.query = query;
	this.words = query.split(' ');
	var refList = this.concordance.search(query);
	this.bookList = this.refListsByBook(refList);
	for (var i=0; i<this.bookList.length; i++) {
		var bookRef = this.bookList[i];
		this.appendBook(bookRef.bookCode);
		for (var j=0; j<bookRef.refList.length && j < 3; j++) {
			var ref = new Reference(bookRef.refList[j]);
			this.appendReference(ref);
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
	refNode.textContent = reference.chapterVerse();
	entryNode.appendChild(refNode);
	entryNode.appendChild(document.createElement('br'));
	this.bibleCache.getVerse(reference, function(verseText) {
		if (verseText.errno) {
			console.log('Error in get verse', JSON.stringify(verseText));
		} else {
			var verseNode = document.createElement('span');
			verseNode.setAttribute('id', 'con' + reference.nodeId);
			verseNode.setAttribute('class', 'conVerse');
			verseNode.innerHTML = styleSearchWords(verseText);
			entryNode.appendChild(verseNode);
			verseNode.addEventListener('click', function() {
				var nodeId = this.id.substr(3);
				console.log('open chapter', nodeId);
				that.bodyNode.dispatchEvent(new CustomEvent(BIBLE.SEARCH, { detail: { id: nodeId, source: that.query }}));
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

/**
* This class contains a reference to a chapter or verse.  It is used to
* simplify the transition from the "GEN:1:1" format to the format
* of distinct parts { book: GEN, chapter: 1, verse: 1 }
* This class leaves unset members as undefined.
*/
"use strict";

function Reference(book, chapter, verse) {
	if (arguments.length > 1) {
		this.book = book;
		this.chapter = +chapter;
		this.verse = +verse;
		if (verse) {
			this.nodeId = book + ':' + chapter + ':' + verse;
		} else {
			this.nodeId = book + ':' + chapter;
		}
	} else {
		var parts = book.split(':');
		this.book = parts[0];
		this.chapter = (parts.length > 0) ? +parts[1] : NaN;
		this.verse = (parts.length > 1) ? +parts[2] : NaN;
		this.nodeId = book;
	}
	this.rootNode = document.createElement('div');
	Object.freeze(this);
};
Reference.prototype.path = function() {
	return(this.book + '/' + this.chapter + '.usx');
};
Reference.prototype.chapterVerse = function() {
	return((this.verse) ? this.chapter + ':' + this.verse : this.chapter);
};
/**
* This class handles all request to deliver scripture.  It handles all passage display requests to display passages of text,
* and it also handles all requests from concordance search requests to display individual verses.
* It will deliver the content from cache if it is present.  Or, it will find the content in persistent storage if it is
* not present in cache.  All content retrieved from persistent storage is added to the cache.
*
* On May 3, 2015 some performance checks were done.  The time measurements where from a sample of 4, the memory from a sample of 1.
* 1) Read Chapter 11.2ms, 49K heap increase
* 2) Parse USX 6.0ms, 306K heap increase
* 3) Generate Dom 2.16ms, 85K heap increase
*/
"use strict";

function BibleCache(versionCode) {
	this.versionCode = versionCode;
	this.chapterMap = {};
	this.reader = new NodeFileReader('application');
	this.parser = new USXParser();
	Object.freeze(this);
};
BibleCache.prototype.getChapter = function(reference, callback) {
	var that = this;
	var chapter = this.chapterMap[reference.nodeId];
	
	if (chapter !== undefined) {
		callback(chapter);
	} else {
		var filepath = 'usx/' + this.versionCode + '/' + reference.path();
		this.reader.readTextFile(filepath, function(data) {
			if (data.errno) {
				console.log('BibleCache.getChapter ', JSON.stringify(data));
				callback(data);
			} else {
				chapter = that.parser.readBook(data);
				that.chapterMap[reference.nodeId] = chapter;
				callback(chapter);				
			}
		});
	}
};
BibleCache.prototype.getVerse = function(reference, callback) {
	this.getChapter(reference, function(chapter) {
		if (chapter.errno) {
			callback(chapter);
		} else {
			var versePosition = findVerse(reference.verse, chapter);
			var verseContent = findVerseContent(versePosition);
			callback(verseContent);
		}
	});
	function findVerse(verseNum, chapter) {
		for (var i=0; i<chapter.children.length; i++) {
			var child = chapter.children[i];
			if (child.tagName === 'verse' && child.number == verseNum) {
				return({parent: chapter, childIndex: i+1});
			}
			else if (child.tagName === 'para') {
				for (var j=0; j<child.children.length; j++) {
					var grandChild = child.children[j];
					if (grandChild.tagName === 'verse' && grandChild.number == verseNum) {
						return({parent: child, childIndex: j+1});
					}
				}
			}
		}
		return(undefined);		
	}
	function findVerseContent(position) {
		var result = [];
		for (var i=position.childIndex; i<position.parent.children.length; i++) {
			var child = position.parent.children[i];
			if (child.tagName !== 'verse') {
				result.push(child.text);
			}
			else {
				return(result.join(' '));
			}
		}
		return(result.join(' '));
	}
};
/**
* This class holds the concordance of the entire Bible, or whatever part of the Bible was available.
*/
"use strict";

function Concordance() {
	this.index = {};
	this.filename = 'concordance.json';
	this.isFilled = false;
	Object.seal(this);
};
Concordance.prototype.fill = function(words) {
	this.index = words;
	this.isFilled = true;
	Object.freeze(this);
};
Concordance.prototype.addEntry = function(word, reference) {
	if (this.index[word] === undefined) {
		this.index[word] = [];
		this.index[word].push(reference);
	}
	else {
		var refList = this.index[word];
		if (reference !== refList[refList.length -1]) { /* ignore duplicate reference */
			refList.push(reference);
		}
	}
};
Concordance.prototype.size = function() {
	return(Object.keys(this.index).length);
}
Concordance.prototype.search = function(search) {
	var refList = []; 
	var words = search.split(' ');
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		refList.push(this.index[word]);
	}
	return(this.intersection(refList));
}
Concordance.prototype.intersection = function(refLists) {
	if (refLists.length === 0) {
		return([]);
	}
	if (refLists.length === 1) {
		return(refLists[0]);
	}
	var mapList = [];
	for (var i=1; i<refLists.length; i++) {
		var map = arrayToMap(refLists[i]);
		mapList.push(map);
	}
	var result = [];
	var firstList = refLists[0];
	for (var j=0; j<firstList.length; j++) {
		var reference = firstList[j];
		var present = true;
		for (var k=0; k<mapList.length; k++) {
			present = present && mapList[k][reference];
			if (present) {
				result.push(reference)
			}
		}
	}
	return(result);

	function arrayToMap(array) {
		var map = {};
		for (var i=0; i<array.length; i++) {
			map[array[i]] = true;
		}
		return(map);
	}
}
/** This is a fast intersection method, but it requires the lists to be sorted. */
Concordance.prototype.intersectionOld = function(a, b) {
	var ai = 0
	var bi = 0;
	var result = [];

  	while( ai < a.length && bi < b.length ) {
    	if      (a[ai] < b[bi] ){ ai++; }
   		else if (a[ai] > b[bi] ){ bi++; }
   		else { /* they're equal */
     		result.push(a[ai]);
     		ai++;
     		bi++;
   		}
  	}
  	return result;
};
Concordance.prototype.dumpAlphaSort = function() {
	var words = Object.keys(this.index);
	var alphaWords = words.sort();
	this.dump(alphaWords);
};
Concordance.prototype.dumpFrequencySort = function() {
	var freqMap = {};
	var words = Object.keys(this.index);
	for (var i=0; i<words.length; i++) {
		var key = words[i];
		var len = this.index[key].length;
		console.log('***', key, len);
		if (freqMap[len] === undefined) {
			freqMap[len] = [];
		}
		freqMap[len].push(key);
	}
	var freqSort = Object.keys(freqMap).sort(function(a, b) {
		return(a-b);
	});
	for (var i=0; i<freqSort.length; i++) {
		var freq = freqSort[i];
		console.log(freq, freqMap[freq]);
	}
};
Concordance.prototype.dump = function(words) {
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		console.log(word, this.index[word]);
	};	
};
Concordance.prototype.toJSON = function() {
	return(JSON.stringify(this.index, null, ' '));
};/**
* This class holds data for the table of contents of the entire Bible, or whatever part of the Bible was loaded.
*/
"use strict";

function TOC() {
	this.bookList = [];
	this.bookMap = {};
	this.filename = 'toc.json';
	this.isFilled = false;
	Object.seal(this);
};
TOC.prototype.fill = function(books) {
	for (var i=0; i<books.length; i++) {
		this.addBook(books[i]);
	}
	this.isFilled = true;
	Object.freeze(this);	
}
TOC.prototype.addBook = function(book) {
	this.bookList.push(book);
	this.bookMap[book.code] = book;
};
TOC.prototype.find = function(code) {
	return(this.bookMap[code]);
};
TOC.prototype.nextChapter = function(reference) {
	var current = this.bookMap[reference.book];
	if (reference.chapter < current.lastChapter) {
		return(new Reference(reference.book, reference.chapter + 1));
	} else {
		return(new Reference(current.nextBook, 0));
	}
};
TOC.prototype.priorChapter = function(reference) {
	var current = this.bookMap[reference.book];
	if (reference.chapter > 0) {
		return(new Reference(reference.book, reference.chapter -1));
	} else {
		var priorBook = this.bookMap[current.priorBook];
		return(new Reference(current.priorBook, priorBook.lastChapter));
	}
};
TOC.prototype.size = function() {
	return(this.bookList.length);
};
TOC.prototype.toJSON = function() {
	return(JSON.stringify(this.bookList, null, ' '));
};/**
* This class holds the table of contents data each book of the Bible, or whatever books were loaded.
*/
"use strict";

function TOCBook(code) {
	this.code = code;
	this.heading = '';
	this.title = '';
	this.name = '';
	this.abbrev = '';
	this.lastChapter = 0;
	this.priorBook = null;
	this.nextBook = null;
	Object.seal(this);
};/**
* This class holds an index of styles of the entire Bible, or whatever part of the Bible was loaded into it.
*/
"use strict";

function StyleIndex() {
	this.index = {};
	this.filename = 'styleIndex.json';
	this.isFilled = false;
	this.completed = [ 'book.id', 'para.ide', 'para.h', 'para.toc1', 'para.toc2', 'para.toc3', 'para.cl',
		'para.mt', 'para.mt2', 'para.mt3', 'para.ms', 'para.d',
		'chapter.c', 'verse.v',
		'para.p', 'para.m', 'para.b', 'para.mi', 'para.pi', 'para.li', 'para.nb',
		'para.sp', 'para.q', 'para.q2',
		'note.f', 'note.x',
		'char.wj', 'char.qs'];
	Object.seal(this);
};
StyleIndex.prototype.fill = function(entries) {
	this.index = entries;
	this.isFilled = true;
	Object.freeze(this);
};
StyleIndex.prototype.addEntry = function(word, reference) {
	if (this.completed.indexOf(word) < 0) {
		if (this.index[word] === undefined) {
			this.index[word] = [];
		}
		if (this.index[word].length < 100) {
			this.index[word].push(reference);
		}
	}
};
StyleIndex.prototype.find = function(word) {
	return(this.index[word]);
};
StyleIndex.prototype.size = function() {
	return(Object.keys(this.index).length);
};
StyleIndex.prototype.dumpAlphaSort = function() {
	var words = Object.keys(this.index);
	var alphaWords = words.sort();
	this.dump(alphaWords);
};
StyleIndex.prototype.dump = function(words) {
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		console.log(word, this.index[word]);
	};	
};
StyleIndex.prototype.toJSON = function() {
	return(JSON.stringify(this.index, null, ' '));
};/**
* This class manages a queue of history items up to some maximum number of items.
* It adds items when there is an event, such as a toc click, a search lookup,
* or a concordance search.  It also responds to function requests to go back 
* in history, forward in history, or return to the last event.
*/
"use strict";

function History() {
	this.items = [];
	this.currentItem = null;
	this.writer = new NodeFileWriter('application');
	this.isFilled = false;
	var that = this;
	this.bodyNode = document.getElementById('appTop');
	this.bodyNode.addEventListener(BIBLE.TOC, function(event) {
		that.addEvent(event);	
	});
	this.bodyNode.addEventListener(BIBLE.SEARCH, function(event) {
		that.addEvent(event);
	});
	Object.seal(this);
};
History.prototype.fill = function(itemList) {
	this.items = itemList;
	this.isFilled = true;
};
History.prototype.addEvent = function(event) {
	var item = new HistoryItem(event.detail.id, event.type, event.detail.source);
	this.items.push(item);
	this.currentItem = this.items.length -1;
	if (this.items.length > 1000) {
		var discard = this.items.shift();
		this.currentItem--;
	}
	setTimeout(this.persist(), 3000);
};
History.prototype.size = function() {
	return(this.items.length);
};
History.prototype.back = function() {
	return(this.item(--this.currentItem));
};
History.prototype.forward = function() {
	return(this.item(++this.currentItem));
};
History.prototype.last = function() {
	this.currentItem = this.items.length -1;
	return(this.item(this.currentItem));
};
History.prototype.current = function() {
	return(this.item(this.currentItem));
};
History.prototype.item = function(index) {
	return((index > -1 && index < this.items.length) ? this.items[index] : 'JHN:1');
};
History.prototype.persist = function() {
	var filepath = 'usx/WEB/history.json'; // Temporary path, it must be stored in data directory
	this.writer.writeTextFile(filepath, this.toJSON(), function(filename) {
		if (filename.errno) {
			console.log('error writing history.json', filename);
		} else {
			console.log('History saved', filename);
		}
	});
};
History.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};

/**
* This class contains the details of a single history event, such as
* clicking on the toc to get a chapter, doing a lookup of a specific passage
* or clicking on a verse during a concordance search.
*/
"use strict";

function HistoryItem(key, source, search) {
	this.key = key;
	this.source = source;
	this.search = search;
	this.timestamp = new Date();
	Object.freeze(this);
};/**
* This file contains IO constants and functions which are common to all file methods, which might include node.js, cordova, javascript, etc.
*/
var FILE_ROOTS = { 'application': '', 'document': '?', 'temporary': '?', 'test2application': '../../BibleAppNW/' };
/**
* This class is a file reader for Node.  It can be used with node.js and node-webkit.
* cordova requires using another class, but the interface should be the same.
*/
"use strict";

function NodeFileReader(location) {
	this.fs = require('fs');
	this.location = location;
	Object.freeze(this);
};
NodeFileReader.prototype.fileExists = function(filepath, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	//console.log('checking fullpath', fullPath);
	this.fs.stat(fullPath, function(err, stat) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(stat);
		}
	});
};
NodeFileReader.prototype.readDirectory = function(filepath, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	//console.log('read directory ', fullPath);
	this.fs.readdir(fullPath, function(err, data) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(data);
		}
	});
};
NodeFileReader.prototype.readTextFile = function(filepath, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	//console.log('read file ', fullPath);
	this.fs.readFile(fullPath, { encoding: 'utf-8'}, function(err, data) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(data);
		}
	});
};/**
* This class is a file writer for Node.  It can be used with node.js and node-webkit.
* cordova requires using another class, but the interface should be the same.
*/
"use strict";

function NodeFileWriter(location) {
	this.fs = require('fs');
	this.location = location;
	Object.freeze(this);
};
NodeFileWriter.prototype.createDirectory = function(filepath, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	this.fs.mkdir(fullPath, function(err) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(filepath);
		}
	});
}
NodeFileWriter.prototype.writeTextFile = function(filepath, data, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	var options = { encoding: 'utf-8'};
	this.fs.writeFile(fullPath, data, options, function(err) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(filepath);
		}
	});
};/**
* This class reads USX files and creates an equivalent object tree
* elements = [usx, book, chapter, para, verse, note, char];
* paraStyle = [b, d, cl, cp, h, li, p, pc, q, q2, mt, mt2, mt3, mte, toc1, toc2, toc3, ide, ip, ili, ili2, is, m, mi, ms, nb, pi, s, sp];
* charStyle = [add, bk, it, k, fr, fq, fqa, ft, wj, qs, xo, xt];
*/
"use strict";

function USXParser() {
};
USXParser.prototype.readBook = function(data) {
	var reader = new XMLTokenizer(data);
	var nodeStack = [];
	var node;
	var tempNode = {}
	var count = 0;
	while (tokenType !== XMLNodeType.END && count < 300000) {

		var tokenType = reader.nextToken();

		var tokenValue = reader.tokenValue();
		//console.log('type=|' + type + '|  value=|' + value + '|');
		count++;

		switch(tokenType) {
			case XMLNodeType.ELE_OPEN:
				tempNode = { tagName: tokenValue };
				tempNode.whiteSpace = (priorType === XMLNodeType.WHITESP) ? priorValue : '';
				//console.log(tokenValue, priorType, '|' + priorValue + '|');
				break;
			case XMLNodeType.ATTR_NAME:
				tempNode[tokenValue] = '';
				break;
			case XMLNodeType.ATTR_VALUE:
				tempNode[priorValue] = tokenValue;
				break;
			case XMLNodeType.ELE_END:
				tempNode.emptyElement = false;
				node = this.createUSXObject(tempNode);
				//console.log(node.openElement());
				if (nodeStack.length > 0) {
					nodeStack[nodeStack.length -1].addChild(node);
				}
				nodeStack.push(node);
				break;
			case XMLNodeType.TEXT:
				node = new Text(tokenValue);
				//console.log(node.text);
				nodeStack[nodeStack.length -1].addChild(node);
				break;
			case XMLNodeType.ELE_EMPTY:
				tempNode.emptyElement = true;
				node = this.createUSXObject(tempNode);
				//console.log(node.openElement());
				nodeStack[nodeStack.length -1].addChild(node);
				break;
			case XMLNodeType.ELE_CLOSE:
				node = nodeStack.pop();
				//console.log(node.closeElement());
				if (node.tagName !== tokenValue) {
					throw new Error('closing element mismatch ' + node.openElement() + ' and ' + tokenValue);
				}
				break;
			case XMLNodeType.WHITESP:
				// do nothing
				break;
			case XMLNodeType.PROG_INST:
				// do nothing
				break;
			case XMLNodeType.END:
				// do nothing
				break;
			default:
				throw new Error('The XMLNodeType ' + nodeType + ' is unknown in USXParser.');
		}
		var priorType = tokenType;
		var priorValue = tokenValue;
	};
	return(node);
};
USXParser.prototype.createUSXObject = function(tempNode) {
	switch(tempNode.tagName) {
		case 'char':
			return(new Char(tempNode));
			break;
		case 'note':
			return(new Note(tempNode));
			break;
		case 'verse':
			return(new Verse(tempNode));
			break;
		case 'para':
			return(new Para(tempNode));
			break;
		case 'chapter':
			return(new Chapter(tempNode));
			break;
		case 'book':
			return(new Book(tempNode));
			break;
		case 'usx':
			return(new USX(tempNode));
			break;
		default:
			throw new Error('USX element name ' + tempNode.tagName + ' is not known to USXParser.');
	}
};
/**
* This class does a stream read of an XML string to return XML tokens and their token type.
*/
"use strict";

var XMLNodeType = Object.freeze({ELE_OPEN:'ele-open', ATTR_NAME:'attr-name', ATTR_VALUE:'attr-value', ELE_END:'ele-end', 
			WHITESP:'whitesp', TEXT:'text', ELE_EMPTY:'ele-empty', ELE_CLOSE:'ele-close', PROG_INST:'prog-inst', END:'end'});

function XMLTokenizer(data) {
	this.data = data;
	this.position = 0;

	this.tokenStart = 0;
	this.tokenEnd = 0;

	this.state = Object.freeze({ BEGIN:'begin', START:'start', WHITESP:'whitesp', TEXT:'text', ELE_START:'ele-start', ELE_OPEN:'ele-open', 
		EXPECT_EMPTY_ELE:'expect-empty-ele', ELE_CLOSE:'ele-close', 
		EXPECT_ATTR_NAME:'expect-attr-name', ATTR_NAME:'attr-name', EXPECT_ATTR_VALUE:'expect-attr-value1', ATTR_VALUE:'attr-value', 
		PROG_INST:'prog-inst', END:'end' });
	this.current = this.state.BEGIN;

	Object.seal(this);
};
XMLTokenizer.prototype.tokenValue = function() {
	return(this.data.substring(this.tokenStart, this.tokenEnd));
};
XMLTokenizer.prototype.nextToken = function() {
	this.tokenStart = this.position;
	while(this.position < this.data.length) {
		var chr = this.data[this.position++];
		//console.log(this.current, chr, chr.charCodeAt(0));
		switch(this.current) {
			case this.state.BEGIN:
				if (chr === '<') {
					this.current = this.state.ELE_START;
					this.tokenStart = this.position;
				}
				break;
			case this.state.START:
				if (chr === '<') {
					this.current = this.state.ELE_START;
					this.tokenStart = this.position;
				}
				else if (chr === ' ' || chr === '\t' || chr === '\n' || chr === '\r') {
					this.current = this.state.WHITESP;
					this.tokenStart = this.position -1;
				}
				else {
					this.current = this.state.TEXT;
					this.tokenStart = this.position -1;
				}
				break;
			case this.state.WHITESP:
				if (chr === '<') {
					this.current = this.state.START;
					this.position--;
					this.tokenEnd = this.position;
					return(XMLNodeType.WHITESP);
				}
				else if (chr !== ' ' && chr !== '\t' && chr !== '\n' && chr !== '\r') {
					this.current = this.state.TEXT;
				}
				break;
			case this.state.TEXT:
				if (chr === '<') {
					this.current = this.state.START;
					this.position--;
					this.tokenEnd = this.position;
					return(XMLNodeType.TEXT);
				}
				break;
			case this.state.ELE_START:
				if (chr === '/') {
					this.current = this.state.ELE_CLOSE;
					this.tokenStart = this.position;
				} 
				else if (chr === '?') {
					this.current = this.state.PROG_INST;
					this.tokenStart = this.position;
				} 
				else {
					this.current = this.state.ELE_OPEN;
				}
				break;
			case this.state.ELE_OPEN:
				if (chr === ' ') {
					this.current = this.state.EXPECT_ATTR_NAME;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ELE_OPEN);
				} 
				else if (chr === '>') {
					this.current = this.state.START;
					return(XMLNodeType.ELE_END);
				}
				else if (chr === '/') {
					this.current = this.state.EXPECT_EMPTY_ELE;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ELE_OPEN);
				}
				break;
			case this.state.ELE_CLOSE:
				if (chr === '>') {
					this.current = this.state.START;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ELE_CLOSE);
				}
				break;
			case this.state.EXPECT_ATTR_NAME:
				if (chr === '>') {
					this.current = this.state.START;
					this.tokenEnd = this.tokenStart;
					return(XMLNodeType.ELE_END);
				}
				else if (chr === '/') {
					this.current = this.state.EXPECT_EMPTY_ELE;
				}
				else if (chr !== ' ') {
					this.current = this.state.ATTR_NAME;
					this.tokenStart = this.position -1;		
				}
				break;
			case this.state.EXPECT_EMPTY_ELE:
				if (chr === '>') {
					this.current = this.state.START;
					this.tokenEnd = this.tokenStart;
					return(XMLNodeType.ELE_EMPTY);
				}
				break;
			case this.state.ATTR_NAME:
				if (chr === '=') {
					this.current = this.state.EXPECT_ATTR_VALUE;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ATTR_NAME);
				}
				break;
			case this.state.EXPECT_ATTR_VALUE:
				if (chr === '"') {
					this.current = this.state.ATTR_VALUE;
					this.tokenStart = this.position;
				} else if (chr !== ' ') {
					throw new Error();
				}
				break;
			case this.state.ATTR_VALUE:
				if (chr === '"') {
					this.current = this.state.EXPECT_ATTR_NAME;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ATTR_VALUE);
				}
				break;
			case this.state.PROG_INST:
				if (chr === '>') {
					this.current = this.state.START;
					this.tokenStart -= 2;
					this.tokenEnd = this.position;
					return(XMLNodeType.PROG_INST);
				}
				break;
			default:
				throw new Error('Unknown state ' + this.current);
		}
	}
	return(XMLNodeType.END);
};
/**
* This object of the Director pattern, it contains a boolean member for each type of asset.
* Setting a member to true will be used by the Builder classes to control which assets are built.
*/
"use strict";

function AssetType(location, versionCode) {
	this.location = location;
	this.versionCode = versionCode;
	this.chapterFiles = false;
	this.tableContents = false;
	this.concordance = false;
	this.history = false;
	this.styleIndex = false;
	this.html = false;// this one is not ready
	Object.seal(this);
};
AssetType.prototype.mustDoQueue = function(filename) {
	switch(filename) {
		case 'chapterMetaData.json':
			this.chapterFiles = true;
			break;
		case 'toc.json':
			this.tableContents = true;
			break;
		case 'concordance.json':
			this.concordance = true;
			break;
		case 'history.json':
			this.history = true;
			break;
		case 'styleIndex.json':
			this.styleIndex = true;
			break;
		default:
			throw new Error('File ' + filename + ' is not known in AssetType.mustDo.');
	}
};
AssetType.prototype.toBeDoneQueue = function() {
	var toDo = [];
	if (this.chapterFiles) {
		toDo.push('chapterMetaData.json');
	}
	if (this.tableContents) {
		toDo.push('toc.json');
	}
	if (this.concordance) {
		toDo.push('concordance.json');
	}
	if (this.history) {
		toDo.push('history.json');
	}
	if (this.styleIndex) {
		toDo.push('styleIndex.json');
	}
	return(toDo);
};
AssetType.prototype.getPath = function(filename) {
	return('usx/' + this.versionCode + '/' + filename);
};
/**
* The class controls the construction and loading of asset objects.  It is designed to be used
* one both the client and the server.  It is a "builder" controller that uses the AssetType
* as a "director" to control which assets are built.
*/
"use strict";

function AssetController(types) {
	this.types = types;
	this.checker = new AssetChecker(types);
	this.loader = new AssetLoader(types);
};
AssetController.prototype.tableContents = function() {
	return(this.loader.toc);
};
AssetController.prototype.concordance = function() {
	return(this.loader.concordance);
}
AssetController.prototype.history = function() {
	return(this.loader.history);
};
AssetController.prototype.styleIndex = function() {
	return(this.loader.styleIndex);
}
AssetController.prototype.checkBuildLoad = function(callback) {
	var that = this;
	this.checker.check(function(absentTypes) {
		var builder = new AssetBuilder(absentTypes);
		builder.build(function() {
			that.loader.load(function(loadedTypes) {
				callback(loadedTypes)
			});
		});
	});
};
AssetController.prototype.check = function(callback) {
	this.checker.check(function(absentTypes) {
		console.log('finished to be built types', absentTypes);
		callback(absentTypes);
	});
};
AssetController.prototype.build = function(callback) {
	var builder = new AssetBuilder(this.types);
	builder.build(function() {
		console.log('finished asset build');
		callback();
	});
};
AssetController.prototype.load = function(callback) {
	this.loader.load(function(loadedTypes) {
		console.log('finished assetcontroller load');
		callback(loadedTypes);
	});
};
/**
* This class checks for the presence of each assets that is required.
* It should be expanded to check for the correct version of each asset as well, 
* once assets are versioned.
*/
"use strict";

function AssetChecker(types) {
	this.types = types;
};
AssetChecker.prototype.check = function(callback) {
	var that = this;
	var result = new AssetType(this.types.location, this.types.versionCode);
	var reader = new NodeFileReader(that.types.location);
	var toDo = this.types.toBeDoneQueue();
	checkExists(toDo.shift());

	function checkExists(filename) {
		if (filename) {
			var fullPath = that.types.getPath(filename);
			console.log('checking for ', fullPath);
			reader.fileExists(fullPath, function(stat) {
				if (stat.errno) {
					if (stat.code === 'ENOENT') {
						console.log('check exists ' + filename + ' is not found');
						result.mustDoQueue(filename);
					} else {
						console.log('check exists for ' + filename + ' failure ' + JSON.stringify(stat));
					}
				} else {
					// Someday I should check version when check succeeeds.  When version is known.
					console.log('check succeeds for ', filename);
				}
				checkExists(toDo.shift());
			});
		} else {
			callback(result);
		}
	}
};
/**
* The Table of Contents and Concordance must be created by processing the entire text.  Since the parsing of the XML
* is a significant amount of the time to do this, this class reads over the entire Bible text and creates
* all of the required assets.
*/
"use strict";

function AssetBuilder(types) {
	this.types = types;
	this.builders = [];
	if (types.chapterFiles) {
		this.builders.push(new ChapterBuilder(types.location, types.versionCode));
	}
	if (types.tableContents) {
		this.builders.push(new TOCBuilder());
	}
	if (types.concordance) {
		this.builders.push(new ConcordanceBuilder());
	}
	if (types.history) { 
		// do nothing 
	}
	if (types.styleIndex) {
		this.builders.push(new StyleIndexBuilder());
	}
	if (types.html) {
		this.builders.push(new HTMLBuilder()); // HTMLBuilder does NOT yet have the correct interface for this.
	}
	this.reader = new NodeFileReader(types.location);
	this.parser = new USXParser();
	this.writer = new NodeFileWriter(types.location);
	this.filesToProcess = [];
	Object.freeze(this);
};
AssetBuilder.prototype.build = function(callback) {
	if (this.builders.length > 0) {
		var that = this;
		this.reader.readDirectory(this.types.getPath(''), function(files) {
			if (files.errno) {
				console.log('directory read err ', JSON.stringify(files));
				callback(files);
			} else {
				var count = 0
				for (var i=0; i<files.length && count < 66; i++) {
					if (files[i].indexOf('.usx') > 0) {
						that.filesToProcess.push(files[i]);
						count++;
					}
				}
				processReadFile(that.filesToProcess.shift());
			}
		});
	} else {
		callback();
	}
	function processReadFile(file) {
		if (file) {
			that.reader.readTextFile(that.types.getPath(file), function(data) {
				if (data.errno) {
					console.log('file read err ', JSON.stringify(data));
					callback(data);
				} else {
					var rootNode = that.parser.readBook(data);
					for (var i=0; i<that.builders.length; i++) {
						that.builders[i].readBook(rootNode);
					}
					processReadFile(that.filesToProcess.shift());
				}
			});
		} else {
			processWriteResult(that.builders.shift());
		}
	}
	function processWriteResult(builder) {
		if (builder) {
			var json = builder.toJSON();
			var filepath = that.types.getPath(builder.filename);
			that.writer.writeTextFile(filepath, json, function(filename) {
				if (filename.errno) {
					console.log('file write failure ', filename);
					callback(filename);
				} else {
					console.log('file write success ', filename);
					processWriteResult(that.builders.shift());
				}
			});
		} else {
			callback();
		}
	}
};
/**
* This class traverses the USX data model in order to find each book, and chapter
* in order to create a table of contents that is localized to the language of the text.
*/
"use strict"

function TOCBuilder() {
	this.toc = new TOC();
	this.tocBook = null;
	this.filename = this.toc.filename;
	Object.seal(this);
};
TOCBuilder.prototype.readBook = function(usxRoot) {
	this.readRecursively(usxRoot);
};
TOCBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			var priorBook = null;
			if (this.tocBook) {
				this.tocBook.nextBook = node.code;
				priorBook = this.tocBook.code;
			}
			this.tocBook = new TOCBook(node.code);
			this.tocBook.priorBook = priorBook;
			this.toc.addBook(this.tocBook);
			break;
		case 'chapter':
			this.tocBook.lastChapter = node.number;
			break;
		case 'para':
			switch(node.style) {
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
TOCBuilder.prototype.toJSON = function() {
	return(this.toc.toJSON());
};/**
* This class traverses the USX data model in order to find each word, and 
* reference to that word.
*
* This solution might not be unicode safe. GNG Apr 2, 2015
*/
"use strict"

function ConcordanceBuilder() {
	this.concordance = new Concordance();
	this.filename = this.concordance.filename;
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	Object.seal(this);
};
ConcordanceBuilder.prototype.readBook = function(usxRoot) {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.readRecursively(usxRoot);
};
ConcordanceBuilder.prototype.readRecursively = function(node) {
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
			if ('children' in node) {
				for (var i=0; i<node.children.length; i++) {
					this.readRecursively(node.children[i]);
				}
			}

	}
};
ConcordanceBuilder.prototype.toJSON = function() {
	return(this.concordance.toJSON());
};/**
* This class traverses the USX data model in order to find each style, and 
* reference to that style.  It builds an index to each style showing
* all of the references where each style is used.
*/
"use strict"

function StyleIndexBuilder() {
	this.styleIndex = new StyleIndex();
	this.filename = this.styleIndex.filename;
};
StyleIndexBuilder.prototype.readBook = function(usxRoot) {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.readRecursively(usxRoot);
};
StyleIndexBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			this.bookCode = node.code;
			var style = 'book.' + node.style;
			var reference = this.bookCode;
			this.styleIndex.addEntry(style, reference);
			break;
		case 'chapter':
			this.chapter = node.number;
			style = 'chapter.' + node.style;
			reference = this.bookCode + ':' + this.chapter;
			this.styleIndex.addEntry(style, reference);
			break;
		case 'verse':
			this.verse = node.number;
			style = 'verse.' + node.style;
			reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
			this.styleIndex.addEntry(style, reference);
			break;
		case 'usx':
		case 'text':
			// do nothing
			break;
		default:
			var style = node.tagName + '.' + node.style;
			var reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
			this.styleIndex.addEntry(style, reference);
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};
StyleIndexBuilder.prototype.toJSON = function() {
	return(this.styleIndex.toJSON());
};
/**
* This class iterates over the USX data model, and breaks it into files one for each chapter.
*
*/
function ChapterBuilder(location, versionCode) {
	this.location = location;
	this.versionCode = versionCode;
	this.filename = 'chapterMetaData.json';
	Object.seal(this);
};
ChapterBuilder.prototype.readBook = function(usxRoot) {
	var that = this;
	var bookCode = ''; // set by side effect of breakBookIntoChapters
	var chapters = breakBookIntoChapters(usxRoot);

	var reader = new NodeFileReader(this.location);
	var writer = new NodeFileWriter(this.location);

	var oneChapter = chapters.shift();
	var chapterNum = findChapterNum(oneChapter);
	createDirectory(bookCode);

	function breakBookIntoChapters(usxRoot) {
		var chapters = [];
		var chapterNum = 0;
		var oneChapter = new USX({ version: 2.0 });
		for (var i=0; i<usxRoot.children.length; i++) {
			var childNode = usxRoot.children[i];
			switch(childNode.tagName) {
				case 'book':
					bookCode = childNode.code;
					break;
				case 'chapter':
					chapters.push(oneChapter);
					oneChapter = new USX({ version: 2.0 });
					chapterNum = childNode.number;
					break;
			}
			oneChapter.addChild(childNode);
		}
		chapters.push(oneChapter);
		return(chapters);
	}
	function findChapterNum(oneChapter) {
		for (var i=0; i<oneChapter.children.length; i++) {
			var child = oneChapter.children[i];
			if (child.tagName === 'chapter') {
				return(child.number);
			}
		}
		return(0);
	}
	function createDirectory(bookCode) {
		var filepath = getPath(bookCode);
		writer.createDirectory(filepath, function(dirName) {
			if (dirName.errno) {
				writeChapter(bookCode, chapterNum, oneChapter);				
			} else {
				writeChapter(bookCode, chapterNum, oneChapter);	
			}
		});
	}
	function writeChapter(bookCode, chapterNum, oneChapter) {
		var filepath = getPath(bookCode) + '/' + chapterNum + '.usx';
		var data = oneChapter.toUSX();
		writer.writeTextFile(filepath, data, function(filename) {	
			if (filename.errno) {
				console.log('ChapterBuilder.writeChapterFailure ', JSON.stringify(filename));
			} else {
				oneChapter = chapters.shift();
				if (oneChapter) {
					chapterNum = findChapterNum(oneChapter);
					writeChapter(bookCode, chapterNum, oneChapter);
				} else {
					// done
				}
			}
		});
	}
	function getPath(filename) {
		return('usx/' + that.versionCode + '/' + filename);
	}
};
ChapterBuilder.prototype.toJSON = function() {
	//return(JSON.stringify(this.usxRoot));
};

/**
* This class loads each of the assets that is specified in the types file.
*
* On May 3, 2015 some performance checks were done
* 1) Toc Read 10.52ms  85.8KB heap increase
* 2) Toc Loaded 1.22ms  322KB heap increase
* 3) Concordance Read 20.99ms  7.695MB heap increase
* 4) Concordance Loaded 96.49ms  27.971MB heap increase
*/
"use strict";

function AssetLoader(types) {
	this.types = types;
	this.toc = new TOC();
	this.concordance = new Concordance();
	this.history = new History();
	this.styleIndex = new StyleIndex();
};
AssetLoader.prototype.load = function(callback) {
	var that = this;
	this.types.chapterFiles = false; // do not load this
	var result = new AssetType(that.types.location, that.types.versionCode);
	var reader = new NodeFileReader(that.types.location);
	var toDo = this.types.toBeDoneQueue();
	readTextFile(toDo.shift());

	function readTextFile(filename) {
		if (filename) {
			var fullPath = that.types.getPath(filename);
			reader.readTextFile(fullPath, function(data) {
				if (data.errno) {
					console.log('read concordance.json failure ' + JSON.stringify(data));
				} else {
					switch(filename) {
						case 'chapterMetaData.json':
							result.chapterFiles = true;
							break;
						case 'toc.json':
							result.tableContents = true;
							var bookList = JSON.parse(data);
							that.toc.fill(bookList);
							break;
						case 'concordance.json':
							result.concordance = true;
							var wordList = JSON.parse(data);
							that.concordance.fill(wordList);
							break;
						case 'history.json':
							result.history = true;
							var historyList = JSON.parse(data);
							that.history.fill(historyList);
							break;
						case 'styleIndex.json':
							result.styleIndex = true;
							var styleList = JSON.parse(data);
							that.styleIndex.fill(styleList);
							break;
						default:
							throw new Error('File ' + filename + ' is not known in AssetLoader.load.');

					}
				}
				readTextFile(toDo.shift());
			});
		} else {
			callback(result);
		}
	}
};
/**
* This class iterates over the USX data model, and translates the contents to DOM.
*
* This method generates a DOM tree that has exactly the same parentage as the USX model.
* This is probably a problem.  The easy insertion and deletion of nodes probably requires
* having a hierarchy of books and chapters. GNG April 13, 2015
*/
function DOMBuilder() {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.noteNum = 0;

	this.treeRoot = null;
	Object.seal(this);
};
DOMBuilder.prototype.toDOM = function(usxRoot) {
	//this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.noteNum = 0;
	this.treeRoot = document.createDocumentFragment();
	this.readRecursively(this.treeRoot, usxRoot);
	return(this.treeRoot);
};
DOMBuilder.prototype.readRecursively = function(domParent, node) {
	var domNode;
	//console.log('dom-parent: ', domParent.nodeName, domParent.nodeType, '  node: ', node.tagName);
	switch(node.tagName) {
		case 'usx':
			domNode = domParent;
			break;
		case 'book':
			this.bookCode = node.code;
			domNode = node.toDOM(domParent);
			break;
		case 'chapter':
			this.chapter = node.number;
			this.noteNum = 0;
			domNode = node.toDOM(domParent, this.bookCode);
			break;
		case 'para':
			domNode = node.toDOM(domParent);
			break;
		case 'verse':
			this.verse = node.number;
			domNode = node.toDOM(domParent, this.bookCode, this.chapter);
			break;
		case 'text':
			node.toDOM(domParent, this.bookCode, this.chapter, this.noteNum);
			domNode = domParent;
			break;
		case 'char':
			domNode = node.toDOM(domParent);
			break;
		case 'note':
			domNode = node.toDOM(domParent, this.bookCode, this.chapter, ++this.noteNum);
			break;
		default:
			throw new Error('Unknown tagname ' + node.tagName + ' in DOMBuilder.readBook');
			break;
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(domNode, node.children[i]);
		}
	}
};
/**
* This class is the root object of a parsed USX document
*/
"use strict";

function USX(node) {
	this.version = node.version;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // includes books, chapters, and paragraphs
	Object.freeze(this);
};
USX.prototype.tagName = 'usx';
USX.prototype.addChild = function(node) {
	this.children.push(node);
};
USX.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<usx version="' + this.version + elementEnd);
};
USX.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '\n</usx>');
};
USX.prototype.toUSX = function() {
	var result = [];
	this.buildUSX(result);
	return(result.join(''));
};
USX.prototype.toDOM = function() {
};
USX.prototype.buildUSX = function(result) {
	result.push('\uFEFF<?xml version="1.0" encoding="utf-8"?>');
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
USX.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
USX.prototype.buildHTML = function(result) {
	result.push('\uFEFF<?xml version="1.0" encoding="utf-8"?>\n');
	result.push('<html><head>\n');
	result.push('\t<meta charset="utf-8" />\n');
	result.push('\t<meta name="format-detection" content="telephone=no" />\n');
	result.push('\t<meta name="msapplication-tap-highlight" content="no" />\n');
    result.push('\t<meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi" />\n');
	result.push('\t<link rel="stylesheet" href="../css/prototype.css"/>\n');
	result.push('\t<script type="text/javascript" src="cordova.js"></script>\n');
	result.push('\t<script type="text/javascript">\n');
	result.push('\t\tfunction onBodyLoad() {\n');
	result.push('\t\t\tdocument.addEventListener("deviceready", onDeviceReady, false);\n');
	result.push('\t\t}\n');
	result.push('\t\tfunction onDeviceReady() {\n');
	result.push('\t\t\t// app = new BibleApp();\n');
	result.push('\t\t\t// app.something();\n');
	result.push('\t\t}\n');
	result.push('\t</script>\n');
	result.push('</head><body onload="onBodyLoad()">');
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildHTML(result);
	}
	result.push('\n</body></html>')
};/**
* This class contains a book of the Bible
*/
"use strict";

function Book(node) {
	this.code = node.code;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // contains text
	Object.freeze(this);
};
Book.prototype.tagName = 'book';
Book.prototype.addChild = function(node) {
	this.children.push(node);
};
Book.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<book code="' + this.code + '" style="' + this.style + elementEnd);
};
Book.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</book>');
};
Book.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Book.prototype.toDOM = function(parentNode) {
	var article = document.createElement('article');
	article.setAttribute('id', this.code);
	article.setAttribute('class', this.style);
	parentNode.appendChild(article);
	return(article);
};
Book.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Book.prototype.buildHTML = function(result) {
};/**
* This object contains information about a chapter of the Bible from a parsed USX Bible document.
*/
"use strict";

function Chapter(node) {
	this.number = node.number;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	Object.freeze(this);
};
Chapter.prototype.tagName = 'chapter';
Chapter.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<chapter number="' + this.number + '" style="' + this.style + elementEnd);
};
Chapter.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</chapter>');
};
Chapter.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	result.push(this.closeElement());
};
Chapter.prototype.toDOM = function(parentNode, bookCode) {
	var reference = bookCode + ':' + this.number;
	var section = document.createElement('section');
	section.setAttribute('id', reference);
	parentNode.appendChild(section);

	var child = document.createElement('p');
	child.setAttribute('class', this.style);
	child.textContent = this.number;
	section.appendChild(child);
	return(section);
};
Chapter.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Chapter.prototype.buildHTML = function(result) {
	result.push('\n<p id="' + this.number + '" class="' + this.style + '">', this.number, '</p>');
};/**
* This object contains a paragraph of the Bible text as parsed from a USX version of the Bible.
*/
"use strict";

function Para(node) {
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // contains verse | note | char | text
	Object.freeze(this);
};
Para.prototype.tagName = 'para';
Para.prototype.addChild = function(node) {
	this.children.push(node);
};
Para.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<para style="' + this.style + elementEnd);
};
Para.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</para>');
};
Para.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Para.prototype.toDOM = function(parentNode) {
	var identStyles = [ 'ide', 'sts', 'rem', 'h', 'toc1', 'toc2', 'toc3', 'cl' ];
	var child = document.createElement('p');
	child.setAttribute('class', this.style);
	if (identStyles.indexOf(this.style) === -1) {
		parentNode.appendChild(child);
	}
	return(child);
};
Para.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Para.prototype.buildHTML = function(result) {
	var identStyles = [ 'ide', 'sts', 'rem', 'h', 'toc1', 'toc2', 'toc3', 'cl' ];
	if (identStyles.indexOf(this.style) === -1) {
		result.push('\n<p class="' + this.style + '">');
		for (var i=0; i<this.children.length; i++) {
			this.children[i].buildHTML(result);
		}
		result.push('</p>');
	}
};
/**
* This chapter contains the verse of a Bible text as parsed from a USX Bible file.
*/
"use strict";

function Verse(node) {
	this.number = node.number;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	Object.freeze(this);
};
Verse.prototype.tagName = 'verse';
Verse.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<verse number="' + this.number + '" style="' + this.style + elementEnd);
};
Verse.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</verse>');
};
Verse.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	result.push(this.closeElement());
};
Verse.prototype.toDOM = function(parentNode, bookCode, chapterNum) {
	var reference = bookCode + ':' + chapterNum + ':' + this.number;
	var child = document.createElement('span');
	child.setAttribute('id', reference);
	child.setAttribute('class', this.style);
	child.textContent = ' ' + this.number + ' ';
	parentNode.appendChild(child);
	return(child);
};
Verse.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Verse.prototype.buildHTML = function(result) {
	result.push('<span id="' + this.number + '" class="' + this.style + '">', this.number, ' </span>');
};/**
* This class contains a Note from a USX parsed Bible
*/
"use strict";

function Note(node) {
	this.caller = node.caller.charAt(0);
	if (this.caller !== '+') {
		console.log(JSON.stringify(node));
		throw new Error('Caller with no +');
	}
	this.note = node.caller.substring(1).replace(/^\s\s*/, '');
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = [];
	Object.freeze(this);
};
Note.prototype.tagName = 'note';
Note.prototype.addChild = function(node) {
	this.children.push(node);
};
Note.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	if (this.style === 'x') {
		return('<note caller="' + this.caller + ' ' + this.note + '" style="' + this.style + elementEnd);
	} else {
		return('<note style="' + this.style + '" caller="' + this.caller + ' ' + this.note + elementEnd);
	}
};
Note.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</note>');
};
Note.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Note.prototype.toDOM = function(parentNode, bookCode, chapterNum, noteNum) {
	var nodeId = bookCode + chapterNum + '-' + noteNum;
	var refChild = document.createElement('span');
	refChild.setAttribute('id', nodeId);
	refChild.setAttribute('class', 'fnref');
	if (this.note) {
		refChild.setAttribute('note', this.note);
	}
	switch(this.style) {
		case 'f':
			refChild.textContent = '\u261E ';
			break;
		case 'x':
			refChild.textContent = '\u261B ';
			break;
		default:
			refChild.textContent = '* ';
	}
	parentNode.appendChild(refChild);
	refChild.addEventListener('click', function() {
		console.log('inside show footnote', this.id);
		app.codex.showFootnote(this.id);
	});

	if (this.note !== undefined && this.note.length > 0) {
		var noteChild = document.createElement('span');
		noteChild.setAttribute('class', this.style);
		noteChild.setAttribute('note', this.note);
		refChild.appendChild(noteChild);
		noteChild.addEventListener('click', function() {
			app.codex.hideFootnote(nodeId);
			event.stopPropagation();
		});
	}
	return(refChild);
};
Note.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Note.prototype.buildHTML = function(result) {
	result.push('<span class="' + this.style + '">');
	result.push(this.caller);
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildHTML(result);
	}
	result.push('</span>');
};/**
* This class contains a character style as parsed from a USX Bible file.
*/
"use strict";

function Char(node) {
	this.style = node.style;
	this.closed = node.closed;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = [];
	Object.freeze(this);
};
Char.prototype.tagName = 'char';
Char.prototype.addChild = function(node) {
	this.children.push(node);
};
Char.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	if (this.closed) {
		return('<char style="' + this.style + '" closed="' + this.closed + elementEnd);
	} else {
		return('<char style="' + this.style + elementEnd);
	}
};
Char.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</char>');
};
Char.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Char.prototype.toDOM = function(parentNode) {
	if (this.style === 'fr' || this.style === 'xo') {
		return(undefined);
	}
	else {
		var child = document.createElement('span');
		child.setAttribute('class', this.style);
		parentNode.appendChild(child);
		return(child);
	}
};
Char.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Char.prototype.buildHTML = function(result) {
	result.push('<span class="' + this.style + '">');
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildHTML(result);
	}
	result.push('</span>');
};/**
* This class contains a text string as parsed from a USX Bible file.
*/
"use strict";

function Text(text) {
	this.text = text;
	this.footnotes = [ 'f', 'fr', 'ft', 'fqa', 'x', 'xt', 'xo' ];
	Object.freeze(this);
};
Text.prototype.tagName = 'text';
Text.prototype.buildUSX = function(result) {
	result.push(this.text);
};
Text.prototype.toDOM = function(parentNode, bookCode, chapterNum, noteNum) {
	if (parentNode !== undefined && parentNode.tagName !== 'ARTICLE') {
		if (parentNode.nodeType === 1 && this.footnotes.indexOf(parentNode.getAttribute('class')) >= 0) {
			parentNode.setAttribute('note', this.text); // hide footnote text in note attribute of parent.
			var nodeId = bookCode + chapterNum + '-' + noteNum;
			parentNode.addEventListener('click', function() {
				app.codex.hideFootnote(nodeId);
				event.stopPropagation();
			});
		}
		else {
			var child = document.createTextNode(this.text);
			parentNode.appendChild(child);
		}
	}
};
Text.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
Text.prototype.buildHTML = function(result) {
	result.push(this.text);
};
/**
* This simple class is used to measure performance of the App.
* It is not part of the production system, but is used during development
* to instrument the code.
*/
"use strict";

function Performance(message) {
	this.startTime = performance.now();
	var memory = process.memoryUsage();
	this.heapUsed = memory.heapUsed;
	console.log(message, 'heapUsed:', this.heapUsed, 'heapTotal:', memory.heapTotal);
};
Performance.prototype.duration = function(message) {
	var now = performance.now();
	var duration = now - this.startTime;
	var heap = process.memoryUsage().heapUsed;
	var memChanged = heap - this.heapUsed;
	console.log(message, duration + 'ms', memChanged/1024 + 'KB');
	this.startTime = now;
	this.heapUsed = heap;
};
