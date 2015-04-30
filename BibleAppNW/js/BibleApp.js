/**
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
"use strict"

var EVENT = { TOC2PASSAGE: 'toc2passage', CON2PASSAGE: 'con2passage' };

function AppViewController(versionCode) {
	this.versionCode = versionCode;
	this.tableContents = new TableContentsView(versionCode);
	this.codex = new CodexView(versionCode);
	this.searchViewBuilder = new SearchViewBuilder(versionCode, this.tableContents.toc, this.codex.bibleCache);

	this.bodyNode = this.tableContents.bodyNode;
	this.bodyNode.addEventListener(EVENT.TOC2PASSAGE, toc2PassageHandler);
	this.bodyNode.addEventListener(EVENT.CON2PASSAGE, con2PassageHandler);
	var that = this;
	Object.freeze(this);

	function toc2PassageHandler(event) {
		var detail = event.detail;
		console.log(JSON.stringify(detail));
		that.codex.showPassage(detail.id);	
	}
	function con2PassageHandler(event) {
		var detail = event.detail;
		console.log(JSON.stringify(detail));
		that.codex.showPassage(detail.id);
	}
};
AppViewController.prototype.begin = function() {
	this.tableContents.showTocBookList();
	//this.tableContents.readTocFile();
	//this.searchViewBuilder.showSearch("risen");
};


/**
* This class presents the table of contents, and responds to user actions.
*/
"use strict";

function TableContentsView(versionCode) {
	this.versionCode = versionCode;
	this.toc = new TOC();
	this.bodyNode = document.getElementById('appTop');
	Object.seal(this);
};
TableContentsView.prototype.showTocBookList = function() {
	if (this.toc.isFilled) { // should check the version
		this.buildTocBookList();
	}
	else {
		this.readTocFile();
	}
}
TableContentsView.prototype.readTocFile = function() {
	var that = this;
	var reader = new NodeFileReader('application');
	var filename = 'usx/' + this.versionCode + '/' + this.toc.filename;
	reader.readTextFile(filename, function(data) {
		if (data instanceof Error) {
			console.log('read TOC.json failure ' + JSON.stringify(data));
		} else {
			var bookList = JSON.parse(data);
			that.toc.fill(bookList);
			that.buildTocBookList();			
		}
	});
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
	this.removeBody();
	this.bodyNode.appendChild(root);
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
	for (var i=this.bodyNode.children.length -1; i>=0; i--) {
		var childNode = this.bodyNode.children[i];
		div.removeChild(childNode);
	}
};
TableContentsView.prototype.removeAllChapters = function() {
	var div = document.getElementById('toc');
	for (var i=div.children.length -1; i>=0; i--) {
		var bookNode = div.children[i];
		for (var j=bookNode.children.length -1; j>=0; j--) {
			var chaptTable = bookNode.children[j];
			bookNode.removeChild(chaptTable);
		}
	}
};
TableContentsView.prototype.openChapter = function(nodeId) {
	console.log('open chapter', nodeId);
	this.bodyNode.dispatchEvent(new CustomEvent(EVENT.TOC2PASSAGE, { detail: { id: nodeId }}));
};


/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(versionCode) {
	this.versionCode = versionCode;
	this.bibleCache = new BibleCache(versionCode);
	this.bodyNode = document.getElementById('appTop');
	Object.freeze(this);
};
CodexView.prototype.showPassage = function(nodeId) {
	var that = this;
	var parts = nodeId.split(':');
	var chapter = parts[0] + ':' + parts[1];
	this.bibleCache.getChapter(chapter, function(usxNode) {
		if (usxNode instanceof Error) {
			// what to do here?
			console.log((JSON.stringify(usxNode)));
		} else {
			var dom = new DOMBuilder();
			dom.bookCode = parts[0];
			var fragment = dom.toDOM(usxNode);
			var verse = fragment.children[0];
			that.removeBody();
			that.bodyNode.appendChild(fragment);
			that.scrollToNode(verse);
		}
	});
};
CodexView.prototype.scrollTo = function(nodeId) {
	console.log('scroll to verse', nodeId);
	var verse = document.getElementById(nodeId);
	var rect = verse.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollY, rect.top + window.scrollY);
};
CodexView.prototype.scrollToNode = function(node) {
	var rect = node.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollY, rect.top + window.scrollY);
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
	for (var i=this.bodyNode.children.length -1; i>=0; i--) {
		var childNode = this.bodyNode.children[i];
		this.bodyNode.removeChild(childNode);
	}
};
//var codex = new CodexView();
/**
* This class does a lazy construction of all of the parts of the SearchView, or just attaches
* the searchView if it already exists.
*/
"use strict";

function SearchViewBuilder(versionCode, toc, bibleCache) {
	this.versionCode = versionCode;
	this.toc = toc;
	this.bibleCache = bibleCache;
	this.searchView = null;
	this.query = '';
	this.concordance = new Concordance();

	Object.seal(this);
};
SearchViewBuilder.prototype.showSearch = function(query) {
	this.query = query;
	if (this.searchView) {
		this.attachSearchView();
	} 
	else if (this.concordance.size > 1000) {
		this.buildSearchView(query);
	}
	else {
		var that = this;
		var reader = new NodeFileReader('application');
		reader.fileExists(this.getPath(this.concordance.filename), function(stat) {
			if (stat instanceof Error) {
				if (stat.code === 'ENOENT') {
					console.log('check exists concordance json is not found');
					that.createConcordanceFile();	
				} else {
					console.log('check exists concordance.json failure ' + JSON.stringify(stat));
				}
			} else {
				that.readConcordanceFile();
			}
		});
	}
};
SearchViewBuilder.prototype.createConcordanceFile = function() {
	var that = this;
	var options = { buildTableContents: true, buildConcordance: true, buildStyleIndex: true };
	var builder = new AssetBuilder('application', this.versionCode, options);
	builder.build(function(result) {
		if (result instanceof Error) {
			console.log('create concordance file failure', JSON.stringify(result));
		} else {
			that.readConcordanceFile();
		}
	});
};
SearchViewBuilder.prototype.readConcordanceFile = function() {
	var that = this;
	var reader = new NodeFileReader('application');
	var fullPath = this.getPath(this.concordance.filename);
	reader.readTextFile(fullPath, function(data) {
		if (data instanceof Error) {
			console.log('read concordance.json failure ' + JSON.stringify(data));
		} else {
			that.concordance = new Concordance(JSON.parse(data));
			that.buildSearchView(that.query);
		}
	});
};
SearchViewBuilder.prototype.buildSearchView = function(query) {
	this.searchView = new SearchView(this.concordance, this.toc, this.bibleCache);
	this.searchView.showSearch(query);
	this.attachSearchView();
};
SearchViewBuilder.prototype.attachSearchView = function() {
	var appTop = document.getElementById('appTop');
	for (var i=appTop.children.length -1; i>=0; i--) {
		var child = appTop.children[i];
		appTop.removeChild(child);
	}
	appTop.appendChild(this.searchView.viewRoot);
};
SearchViewBuilder.prototype.processFailure = function(err) {
	console.log('process failure  ' + JSON.stringify(err));
};
SearchViewBuilder.prototype.getPath = function(filename) {
	return('usx/' + this.versionCode + '/' + filename);
};
/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
"use strict";

function SearchView(concordance, toc, bibleCache) {
	this.concordance = concordance;
	this.toc = toc;
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

/**
* This class handles all request to deliver scripture.  It handles all passage display requests to display passages of text,
* and it also handles all requests from concordance search requests to display individual verses.
* It will deliver the content from cache if it is present.  Or, it will find the content in persistent storage if it is
* not present in cache.  All content retrieved from persistent storage is added to the cache.
*/
"use strict";

function BibleCache(versionCode) {
	this.versionCode = versionCode;
	this.chapterMap = {};
	this.reader = new NodeFileReader('application');
	this.parser = new USXParser();
	Object.freeze(this);
};
BibleCache.prototype.getChapter = function(nodeId, callback) {
	var that = this;
	var chapter = this.chapterMap[nodeId];
	
	if (chapter !== undefined) {
		callback(chapter);
	} else {
		var filepath = 'usx/' + this.versionCode + '/' + nodeId.replace(':', '/') + '.usx';
		this.reader.readTextFile(filepath, function(data) {
			if (data instanceof Error) {
				console.log('BibleCache.getChapter ', JSON.stringify(data));
				callback(data);
			} else {
				chapter = that.parser.readBook(data);
				that.chapterMap[nodeId] = chapter;
				callback(chapter);				
			}
		});
	}
};
BibleCache.prototype.getVerse = function(nodeId, callback) {
	var parts = nodeId.split(':');
	this.getChapter(parts[0] + ':' + parts[1], function(chapter) {
		if (chapter instanceof Error) {
			callback(chapter);
		} else {
			var versePosition = findVerse(parts[2], chapter);
			var verseContent = findVerseContent(versePosition);
			callback(verseContent);
		}
	});
	function findVerse(verseNum, chapter) {
		for (var i=0; i<chapter.children.length; i++) {
			var child = chapter.children[i];
			if (child.tagName === 'verse' && child.number === verseNum) {
				return({parent: chapter, childIndex: i+1});
			}
			else if (child.tagName === 'para') {
				for (var j=0; j<child.children.length; j++) {
					var grandChild = child.children[j];
					if (grandChild.tagName === 'verse' && grandChild.number === verseNum) {
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

function Concordance(words) {
	this.index = words || {};
	this.filename = 'concordance.json';
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
TOC.prototype.toJSON = function() {
	return(JSON.stringify(this.bookList, null, ' '));
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
	this.fs.stat(filepath, function(err, stat) {
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
