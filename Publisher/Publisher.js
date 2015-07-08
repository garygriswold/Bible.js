"use strict";
/**
* This object of the Director pattern, it contains a boolean member for each type of asset.
* Setting a member to true will be used by the Builder classes to control which assets are built.
*/
function AssetType(location, versionCode) {
	this.location = location;
	this.versionCode = versionCode;
	this.chapterFiles = false;
	this.tableContents = false;
	this.concordance = false;
	this.history = false;
	this.questions = false;
	this.styleIndex = false;
	this.html = false;// this one is not ready
	Object.seal(this);
}
AssetType.prototype.getUSXPath = function(filename) {
	return(this.versionCode + '/USX/' + filename);
};

/**
* The Table of Contents and Concordance must be created by processing the entire text.  Since the parsing of the XML
* is a significant amount of the time to do this, this class reads over the entire Bible text and creates
* all of the required assets.
*/
function AssetBuilder(types, database) {
	this.types = types;
	this.database = database;
	this.builders = [];
	if (types.chapterFiles) {
		this.builders.push(new ChapterBuilder(this.database.codex));
	}
	if (types.tableContents) {
		this.builders.push(new TOCBuilder(this.database.tableContents));
	}
	if (types.concordance) {
		this.builders.push(new ConcordanceBuilder(this.database.concordance));
	}
	if (types.styleIndex) {
		this.builders.push(new StyleIndexBuilder(this.database.styleIndex));
		this.builders.push(new StyleUseBuilder(this.database.styleUse));
	}
	if (types.history) {
		this.builders.push(new HistoryBuilder(this.database.history));
	}
	if (types.questions) {
		this.builders.push(new QuestionsBuilder(this.database.questions));
	}
	if (types.html) {
		this.builders.push(new HTMLBuilder()); // HTMLBuilder does NOT yet have the correct interface for this.
	}
	this.reader = new FileReader(types.location);
	this.parser = new USXParser();
	this.filesToProcess = [];
	Object.freeze(this);
}
AssetBuilder.prototype.build = function(callback) {
	var that = this;
	if (this.builders.length > 0) {
		this.filesToProcess.splice(0);
		var canon = new Canon();
		for (var i=0; i<canon.books.length; i++) {
			this.filesToProcess.push(canon.books[i].code + '.usx');
		}
		processReadFile(this.filesToProcess.shift());
	} else {
		callback();
	}
	function processReadFile(file) {
		if (file) {
			that.reader.readTextFile(that.types.getUSXPath(file), function(data) {
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
			processDatabaseLoad(that.builders.shift());
		}
	}
	function processDatabaseLoad(builder) {
		if (builder) {
			builder.collection.drop(function(err) {
				if (err) {
					console.log('drop error', err);
					callback(err);
				} else {
					processDatabaseLoad(that.builders.shift());
					//callback(err);
				/*	
					builder.collection.create(builder.schema(), function(err) {
						if (err) {
							console.log('create error', err);
							callback(err);
						} else {
							builder.loadDB(function(err) {
								if (err) {
									console.log('load db error', err);
									callback(err);
								} else {
									processDatabaseLoad(that.builders.shift());
								}
							});
						}
					});
*/
				}
			});
		} else {
			callback();
		}
	}
};
/**
* This class iterates over the USX data model, and breaks it into files one for each chapter.
*
*/
function ChapterBuilder(collection) {
	this.collection = collection;
	this.books = [];
	Object.seal(this);
}
ChapterBuilder.prototype.readBook = function(usxRoot) {
	var that = this;
	this.books.push(usxRoot);
};
ChapterBuilder.prototype.schema = function() {
	var sql = 'book text not null, ' +
		'chapter integer not null, ' +
		'xml text not null, ' +
		'primary key (book, chapter)';
	return(sql);
};
ChapterBuilder.prototype.loadDB = function(callback) {
	var array = [];
	for (var i=0; i<this.books.length; i++) {
		var usxRoot = this.books[i];
		var bookCode = null; // set as a side-effect of breakBookIntoChapters
		var chapters = breakBookIntoChapters(usxRoot);
		for (var j=0; j<chapters.length; j++) {
			var chapter = chapters[j];
			var chapterNum = findChapterNum(chapter);
			var values = [ bookCode, chapterNum, chapter.toUSX() ];
			array.push(values);
		}
	}
	var names = [ 'book', 'chapter', 'xml' ];
	this.collection.load(names, array, function(err) {
		if (err) {
			console.log('Storing chapters failed');
			callback(err);
		} else {
			console.log('store chapters success');
			callback();
		}
	});

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
};
ChapterBuilder.prototype.toJSON = function() {
	return('');
};

/**
* This class traverses the USX data model in order to find each book, and chapter
* in order to create a table of contents that is localized to the language of the text.
*/
function TOCBuilder(collection) {
	this.collection = collection;
	this.toc = new TOC(collection);
	this.tocBook = null;
	Object.seal(this);
}
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
TOCBuilder.prototype.size = function() {
	return(this.toc.bookList.length);
};
TOCBuilder.prototype.schema = function() {
	var sql = 'code text primary key not null, ' +
    	'heading text not null, ' +
    	'title text not null, ' +
    	'name text not null, ' +
    	'abbrev text not null, ' +
		'lastChapter integer not null, ' +
		'priorBook text null, ' +
		'nextBook text null';
	return(sql);
};
TOCBuilder.prototype.loadDB = function(callback) {
	console.log('TOC loadDB records count', this.size());
	var array = [];
	var len = this.size();
	for (var i=0; i<len; i++) {
		var tocBook = this.toc.bookList[i];
		var names = Object.keys(tocBook);
		var values = this.collection.valuesToArray(names, tocBook);
		array.push(values);
	}
	this.collection.load(names, array, function(err) {
		if (err) {
			window.alert('TOC Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('TOC loaded in database');
			callback();
		}
	});
};
TOCBuilder.prototype.toJSON = function() {
	return(this.toc.toJSON());
};/**
* This class traverses the USX data model in order to find each word, and 
* reference to that word.
*
* This solution might not be unicode safe. GNG Apr 2, 2015
*/
function ConcordanceBuilder(collection) {
	this.collection = collection;
	this.index = {};
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	Object.seal(this);
}
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
		case 'note':
			break; // Do not index notes
		case 'text':
			var words = node.text.split(/\b/);
			for (var i=0; i<words.length; i++) {
				var word = words[i].replace(/[\u2000-\u206F\u2E00-\u2E7F\\'!"#\$%&\(\)\*\+,\-\.\/:;<=>\?@\[\]\^_`\{\|\}~\s0-9]/g, '');
				if (word.length > 0 && this.chapter > 0 && this.verse > 0) {
					var reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
					this.addEntry(word.toLocaleLowerCase(), reference);
				}
			}
			break;
		default:
			if ('children' in node) {
				for (i=0; i<node.children.length; i++) {
					this.readRecursively(node.children[i]);
				}
			}

	}
};
ConcordanceBuilder.prototype.addEntry = function(word, reference) {
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
ConcordanceBuilder.prototype.size = function() {
	return(Object.keys(this.index).length); 
};
ConcordanceBuilder.prototype.schema = function() {
	var sql = 'word text primary key not null, ' +
    	'refCount integer not null, ' +
    	'refList text not null';
    return(sql);
};
ConcordanceBuilder.prototype.loadDB = function(callback) {
	console.log('Concordance loadDB records count', this.size());
	var words = Object.keys(this.index);
	var array = [];
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		var refList = this.index[word];
		var refCount = refList.length;
		var item = [ words[i], refCount, refList ];
		array.push(item);
	}
	var names = [ 'word', 'refCount', 'refList' ];
	this.collection.load(names, array, function(err) {
		if (err) {
			window.alert('Concordance Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('concordance loaded in database');
			callback();
		}
	});
};
ConcordanceBuilder.prototype.toJSON = function() {
	return(JSON.stringify(this.index, null, ' '));
};/**
* This class creates an empty History table.  The table is filled
* by user action.
*/
function HistoryBuilder(collection) {
	this.collection = collection;
	Object.freeze(this);
}
HistoryBuilder.prototype.readBook = function(usxRoot) {
	// This class does not process the Bible
};
HistoryBuilder.prototype.schema = function() {
	var sql = 'timestamp text not null primary key, ' +
		'book text not null, ' +
		'chapter integer not null, ' +
		'verse integer null, ' +
		'source text not null, ' +
		'search text null';
	return(sql);
};
HistoryBuilder.prototype.loadDB = function(callback) {
	callback();  // This class does not load history
};/**
* This class creates an initial Questions table.  The table is filled
* by user and instructor input.
*/
function QuestionsBuilder(collection) {
	this.collection = collection;
	Object.freeze(this);
}
QuestionsBuilder.prototype.readBook = function(usxRoot) {
	// This class does not process the Bible
};
QuestionsBuilder.prototype.schema = function() {
	var sql = 'askedDateTime text not null primary key, ' +
		'book text not null, ' +
		'chapter integer not null, ' +
		'verse integer null, ' +
		'question text not null, ' +
		'instructor text not null, ' +
		'answerDateTime text not null, ' +
		'answer text not null';
	return(sql);
};
QuestionsBuilder.prototype.loadDB = function(callback) {
	callback();  // This class does not load history
};/**
* This class traverses the USX data model in order to find each style, and 
* reference to that style.  It builds an index to each style showing
* all of the references where each style is used.
*/
function StyleIndexBuilder(collection) {
	this.collection = collection;
	this.index = {};
}
StyleIndexBuilder.prototype.addEntry = function(word, reference) {
	if (this.index[word] === undefined) {
		this.index[word] = [];
	}
	if (this.index[word].length < 100) {
		this.index[word].push(reference);
	}
};
StyleIndexBuilder.prototype.readBook = function(usxRoot) {
	this.bookCode = '';
	this.chapter = null;
	this.verse = null;
	this.readRecursively(usxRoot);
};
StyleIndexBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			this.bookCode = node.code;
			var style = 'book.' + node.style;
			var reference = this.bookCode;
			this.addEntry(style, reference);
			break;
		case 'chapter':
			this.chapter = node.number;
			style = 'chapter.' + node.style;
			reference = this.bookCode + ':' + this.chapter;
			this.addEntry(style, reference);
			break;
		case 'verse':
			this.verse = node.number;
			style = 'verse.' + node.style;
			reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
			this.addEntry(style, reference);
			break;
		case 'usx':
		case 'text':
			// do nothing
			break;
		default:
			style = node.tagName + '.' + node.style;
			reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
			this.addEntry(style, reference);
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};
StyleIndexBuilder.prototype.size = function() {
	return(Object.keys(this.index).length);
};
StyleIndexBuilder.prototype.schema = function() {
	var sql = 'style text not null, ' +
		'usage text not null, ' +
		'book text not null, ' +
		'chapter integer null, ' +
		'verse integer null';
	return(sql);
};
StyleIndexBuilder.prototype.loadDB = function(callback) {
	console.log('style index loadDB records count', this.size());
	var array = [];
	var styles = Object.keys(this.index);
	for (var i=0; i<styles.length; i++) {
		var style = styles[i];
		var styleUse = style.split('.');
		var refList = this.index[style];
		for (var j=0; j<refList.length; j++) {
			var refItem = refList[j];
			var reference = refItem.split(':');
			switch(reference.length) {
				case 1:
					var values = [ styleUse[1], styleUse[0], reference[0], null, null ];
					break;
				case 2:
					values = [ styleUse[1], styleUse[0], reference[0], reference[1], null ];
					break;
				case 3:
					values = [ styleUse[1], styleUse[0], reference[0], reference[1], reference[2] ];
			}
			array.push(values);
		}
	}
	var names = [ 'style', 'usage', 'book', 'chapter', 'verse' ];
	this.collection.load(names, array, function(err) {
		if (err) {
			window.alert('StyleIndex Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('StyleIndex loaded in database');
			callback();
		}
	});
};
StyleIndexBuilder.prototype.toJSON = function() {
	return(this.toJSON());
};
/**
* This class builds a table of already handled styles so that we can easily
* query the styleIndex table for any styles that are new in a table.
*/
function StyleUseBuilder(collection) {
	this.collection = collection;
}
StyleUseBuilder.prototype.readBook = function(usxRoot) {
	// This table is not populated from text of the Bible
};
StyleUseBuilder.prototype.schema = function() {
	var sql = 'style text not null, ' +
		'usage text not null, ' +
		'primary key(style, usage)';
	return(sql);
};
StyleUseBuilder.prototype.loadDB = function(callback) {
	var styles = [ 'book.id', 'para.ide', 'para.h', 'para.toc1', 'para.toc2', 'para.toc3', 'para.cl', 'para.rem',
		'para.mt', 'para.mt1', 'para.mt2', 'para.mt3', 'para.ms', 'para.ms1', 'para.d',
		'chapter.c', 'verse.v',
		'para.p', 'para.m', 'para.b', 'para.mi', 'para.pi', 'para.li', 'para.li1', 'para.nb',
		'para.sp', 'para.q', 'para.q1', 'para.q2',
		'note.f', 'note.x', 'char.fr', 'char.ft', 'char.fqa', 'char.xo',
		'char.wj', 'char.qs'];
	var array = [];
	for (var i=0; i<styles.length; i++) {
		var style = styles[i];
		var styleUse = style.split('.');
		var values = [ styleUse[1], styleUse[0] ];
		array.push(values);
	}
	var names = [ 'style', 'usage' ];
	this.collection.load(names, array, function(err) {
		if (err) {
			window.alert('StyleUse Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('StyleUse loaded in database');
			callback();
		}
	});
};/**
* This class traverses a DOM tree in order to create an equivalent HTML document.
*/
function HTMLBuilder() {
	this.result = [];
	this.filename = 'bible.html';
	Object.freeze(this);
}
HTMLBuilder.prototype.toHTML = function(fragment) {
	this.readRecursively(fragment);
	return(this.result.join(''));
};
HTMLBuilder.prototype.readRecursively = function(node) {
	switch(node.nodeType) {
		case 11: // fragment
			break;
		case 1: // element
			this.result.push('\n<', node.tagName.toLowerCase());
			for (var i=0; i<node.attributes.length; i++) {
				this.result.push(' ', node.attributes[i].nodeName, '="', node.attributes[i].value, '"');
			}
			this.result.push('>');
			break;
		case 3: // text
			this.result.push(node.wholeText);
			break;
		default:
			throw new Error('Unexpected nodeType ' + node.nodeType + ' in HTMLBuilder.toHTML().');
	}
	if ('childNodes' in node) {
		for (i=0; i<node.childNodes.length; i++) {
			this.readRecursively(node.childNodes[i]);
		}
	}
	if (node.nodeType === 1) {
		this.result.push('</', node.tagName.toLowerCase(), '>\n');
	}
};
HTMLBuilder.prototype.toJSON = function() {
	return(this.result.join(''));
};


/**
* This class is the root object of a parsed USX document
*/
function USX(node) {
	this.version = node.version;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // includes books, chapters, and paragraphs
	Object.freeze(this);
}
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
/** deprecated, might redo when writing tests */
USX.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
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
	result.push('\n</body></html>');
};
/**
* This class contains a book of the Bible
*/
function Book(node) {
	this.code = node.code;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // contains text
	Object.freeze(this);
}
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
/** deprecated, might redo when writing tests */
Book.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Book.prototype.buildHTML = function(result) {
};/**
* This object contains information about a chapter of the Bible from a parsed USX Bible document.
*/
function Chapter(node) {
	this.number = node.number;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	Object.freeze(this);
}
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
/** deprecated, might redo when writing tests */
Chapter.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Chapter.prototype.buildHTML = function(result) {
	result.push('\n<p id="' + this.number + '" class="' + this.style + '">', this.number, '</p>');
};/**
* This object contains a paragraph of the Bible text as parsed from a USX version of the Bible.
*/
function Para(node) {
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // contains verse | note | char | text
	Object.freeze(this);
}
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
/** deprecated, might redo when writing tests */
Para.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
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
function Verse(node) {
	this.number = node.number;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	Object.freeze(this);
}
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
/** deprecated, might redo when writing tests */
Verse.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Verse.prototype.buildHTML = function(result) {
	result.push('<span id="' + this.number + '" class="' + this.style + '">', this.number, ' </span>');
};/**
* This class contains a Note from a USX parsed Bible
*/
function Note(node) {
	this.caller = node.caller.charAt(0);
	if (this.caller !== '+') {
		console.log(JSON.stringify(node));
		throw new Error('Note caller with no +');
	}
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = [];
	Object.freeze(this);
}
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
	refChild.setAttribute('class', 'top' + this.style);
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
		event.stopImmediatePropagation();
		document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_NOTE, { detail: { id: this.id }}));
	});
	return(refChild);
};
/** deprecated, might redo when writing tests */
Note.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
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
function Char(node) {
	this.style = node.style;
	this.closed = node.closed;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = [];
	Object.freeze(this);
}
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
		return(null);// this drop these styles from presentation
	}
	else {
		var child = document.createElement('span');
		child.setAttribute('class', this.style);
		parentNode.appendChild(child);
		return(child);
	}
};
/** deprecated, might redo when writing tests */
Char.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Char.prototype.buildHTML = function(result) {
	result.push('<span class="' + this.style + '">');
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildHTML(result);
	}
	result.push('</span>');
};/**
* This class contains a text string as parsed from a USX Bible file.
*/
function Text(text) {
	this.text = text;
	Object.freeze(this);
}
Text.prototype.tagName = 'text';
Text.prototype.buildUSX = function(result) {
	result.push(this.text);
};
Text.prototype.toDOM = function(parentNode, bookCode, chapterNum, noteNum) {
	if (parentNode === null || parentNode.tagName === 'ARTICLE') {
		// discard text node
	} else {
		var nodeId = bookCode + chapterNum + '-' + noteNum;
		var parentClass = parentNode.getAttribute('class');
		if (parentClass.substr(0, 3) === 'top') {
			var textNode = document.createElement('span');
			textNode.setAttribute('class', parentClass.substr(3));
			textNode.setAttribute('note', this.text);
			parentNode.appendChild(textNode);
			textNode.addEventListener('click', function() {
				event.stopImmediatePropagation();
				document.body.dispatchEvent(new CustomEvent(BIBLE.HIDE_NOTE, { detail: { id: nodeId }}));
			});
		} else if (parentClass[0] === 'f' || parentClass[0] === 'x') {
			parentNode.setAttribute('note', this.text); // hide footnote text in note attribute of parent.
			parentNode.addEventListener('click', function() {
				event.stopImmediatePropagation();
				document.body.dispatchEvent(new CustomEvent(BIBLE.HIDE_NOTE, { detail: { id: nodeId }}));
			});
		}
		else {
			var child = document.createTextNode(this.text);
			parentNode.appendChild(child);
		}
	}
};
/** deprecated, might redo when writing tests */
Text.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Text.prototype.buildHTML = function(result) {
	result.push(this.text);
};
/**
* This class does a stream read of an XML string to return XML tokens and their token type.
*/
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
}
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
* This class reads USX files and creates an equivalent object tree
* elements = [usx, book, chapter, para, verse, note, char];
* paraStyle = [b, d, cl, cp, h, li, p, pc, q, q2, mt, mt2, mt3, mte, toc1, toc2, toc3, ide, ip, ili, ili2, is, m, mi, ms, nb, pi, s, sp];
* charStyle = [add, bk, it, k, fr, fq, fqa, ft, wj, qs, xo, xt];
*/
function USXParser() {
}
USXParser.prototype.readBook = function(data) {
	var reader = new XMLTokenizer(data);
	var nodeStack = [];
	var node;
	var tempNode = {};
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
				throw new Error('The XMLNodeType ' + tokenType + ' is unknown in USXParser.');
		}
		var priorType = tokenType;
		var priorValue = tokenValue;
	}
	return(node);
};
USXParser.prototype.createUSXObject = function(tempNode) {
	switch(tempNode.tagName) {
		case 'char':
			return(new Char(tempNode));
		case 'note':
			return(new Note(tempNode));
		case 'verse':
			return(new Verse(tempNode));
		case 'para':
			return(new Para(tempNode));
		case 'chapter':
			return(new Chapter(tempNode));
		case 'book':
			return(new Book(tempNode));
		case 'usx':
			return(new USX(tempNode));
		default:
			throw new Error('USX element name ' + tempNode.tagName + ' is not known to USXParser.');
	}
};
/**
* This class contains the Canon of Scripture as 66 books.  It is used to control
* which books are published using this App.  The codes are used to identify the
* books of the Bible, while the names, which are in English are only used to document
* the meaning of each code.  These names are not used for display in the App.
*/
function Canon() {
	this.books = [
    	{ code: 'GEN', name: 'Genesis' },
    	{ code: 'EXO', name: 'Exodus' },
    	{ code: 'LEV', name: 'Leviticus' },
    	{ code: 'NUM', name: 'Numbers' },
    	{ code: 'DEU', name: 'Deuteronomy' },
    	{ code: 'JOS', name: 'Joshua' },
    	{ code: 'JDG', name: 'Judges' },
    	{ code: 'RUT', name: 'Ruth' },
    	{ code: '1SA', name: '1 Samuel' },
    	{ code: '2SA', name: '2 Samuel' },
    	{ code: '1KI', name: '1 Kings' },
    	{ code: '2KI', name: '2 Kings' },
    	{ code: '1CH', name: '1 Chronicles' },
    	{ code: '2CH', name: '2 Chronicles' },
    	{ code: 'EZR', name: 'Ezra' },
    	{ code: 'NEH', name: 'Nehemiah' },
    	{ code: 'EST', name: 'Esther' },
    	{ code: 'JOB', name: 'Job' },
    	{ code: 'PSA', name: 'Psalms' },
    	{ code: 'PRO', name: 'Proverbs' },
    	{ code: 'ECC', name: 'Ecclesiastes' },
    	{ code: 'SNG', name: 'Song of Solomon' },
    	{ code: 'ISA', name: 'Isaiah' },
    	{ code: 'JER', name: 'Jeremiah' },
    	{ code: 'LAM', name: 'Lamentations' },
    	{ code: 'EZK', name: 'Ezekiel' },
    	{ code: 'DAN', name: 'Daniel' },
    	{ code: 'HOS', name: 'Hosea' },
    	{ code: 'JOL', name: 'Joel' },
    	{ code: 'AMO', name: 'Amos' },
    	{ code: 'OBA', name: 'Obadiah' },
    	{ code: 'JON', name: 'Jonah' },
    	{ code: 'MIC', name: 'Micah' },
    	{ code: 'NAM', name: 'Nahum' },
    	{ code: 'HAB', name: 'Habakkuk' },
    	{ code: 'ZEP', name: 'Zephaniah' },
    	{ code: 'HAG', name: 'Haggai' },
    	{ code: 'ZEC', name: 'Zechariah' },
    	{ code: 'MAL', name: 'Malachi' },
    	{ code: 'MAT', name: 'Matthew' },
    	{ code: 'MRK', name: 'Mark' },
    	{ code: 'LUK', name: 'Luke' },
    	{ code: 'JHN', name: 'John' },
    	{ code: 'ACT', name: 'Acts' },
    	{ code: 'ROM', name: 'Romans' },
    	{ code: '1CO', name: '1 Corinthians' },
    	{ code: '2CO', name: '2 Corinthians' },
    	{ code: 'GAL', name: 'Galatians' },
    	{ code: 'EPH', name: 'Ephesians' },
    	{ code: 'PHP', name: 'Philippians' },
    	{ code: 'COL', name: 'Colossians' },
    	{ code: '1TH', name: '1 Thessalonians' },
    	{ code: '2TH', name: '2 Thessalonians' },
    	{ code: '1TI', name: '1 Timothy' },
    	{ code: '2TI', name: '2 Timothy' },
    	{ code: 'TIT', name: 'Titus' },
    	{ code: 'PHM', name: 'Philemon' },
    	{ code: 'HEB', name: 'Hebrews' },
    	{ code: 'JAS', name: 'James' },
    	{ code: '1PE', name: '1 Peter' },
    	{ code: '2PE', name: '2 Peter' },
    	{ code: '1JN', name: '1 John' },
    	{ code: '2JN', name: '2 John' },
    	{ code: '3JN', name: '3 John' },
    	{ code: 'JUD', name: 'Jude' },
    	{ code: 'REV', name: 'Revelation' } ];
}
/**
* This class holds data for the table of contents of the entire Bible, or whatever part of the Bible was loaded.
*/
function TOC(collection) {
	this.collection = collection;
	this.bookList = [];
	this.bookMap = {};
	this.isFilled = false;
	Object.seal(this);
}
TOC.prototype.fill = function(callback) {
	var that = this;
	var statement = 'select code, heading, title, name, abbrev, lastChapter, priorBook, nextBook from tableContents';
	this.collection.select(statement, [], function(results) {
		if (results instanceof IOError) {
			callback();
		} else {
			for (var i=0; i<results.rows.length; i++) {
				that.addBook(results.rows.item(i));
			}
			that.isFilled = true;
		}
		Object.freeze(that);
		callback();
	});
};
TOC.prototype.addBook = function(book) {
	this.bookList.push(book);
	this.bookMap[book.code] = book;
};
TOC.prototype.find = function(code) {
	return(this.bookMap[code]);
};
TOC.prototype.ensureChapter = function(reference) {
	var current = this.bookMap[reference.book];
	if (reference.chapter > current.lastChapter) {
		return(new Reference(reference.book, current.lastChapter, 1));
	}
	if (reference.chapter < 1) {
		return(new Reference(reference.book, 1, 1));
	}
	return(reference);
};
TOC.prototype.nextChapter = function(reference) {
	var current = this.bookMap[reference.book];
	if (reference.chapter < current.lastChapter) {
		return(new Reference(reference.book, reference.chapter + 1));
	} else {
		return((current.nextBook) ? new Reference(current.nextBook, 0) : null);
	}
};
TOC.prototype.priorChapter = function(reference) {
	var current = this.bookMap[reference.book];
	if (reference.chapter > 0) {
		return(new Reference(reference.book, reference.chapter -1));
	} else {
		var priorBook = this.bookMap[current.priorBook];
		return((priorBook) ? new Reference(current.priorBook, priorBook.lastChapter) : null);
	}
};
TOC.prototype.size = function() {
	return(this.bookList.length);
};
TOC.prototype.toString = function(reference) {
	return(this.find(reference.book).name + ' ' + reference.chapter + ':' + reference.verse);
};
TOC.prototype.toJSON = function() {
	return(JSON.stringify(this.bookList, null, ' '));
};/**
* This class holds the table of contents data each book of the Bible, or whatever books were loaded.
*/
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
}/**
* This class holds the concordance of the entire Bible, or whatever part of the Bible was available.
*/
function Concordance(collection) {
	this.collection = collection;
	Object.freeze(this);
}
Concordance.prototype.search = function(words, callback) {
	var questionMarks = [ words.length ];
	var values = [ words.length ];
	for (var i=0; i<words.length; i++) {
		questionMarks[i] = '?';
		values[i] = words[i].toLocaleLowerCase();
	}
	var that = this;
	var statement = 'select refList from concordance where word in(' + questionMarks.join(',') + ')';
	this.collection.select(statement, values, function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else {
			var refLists = [];
			for (i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				if (row && row.refList) { // ignore words that have no ref list
					var array = row.refList.split(',');
					refLists.push(array);
				}
			}
			var result = that.intersection(refLists);
			callback(result);
		}
	});
};
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
		if (presentInAllMaps(mapList, reference)) {
			result.push(reference);
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
	function presentInAllMaps(mapList, reference) {
		for (var i=0; i<mapList.length; i++) {
			if (mapList[i][reference] === undefined) {
				return(false);
			}
		}
		return(true);
	}
};
/**
* This class manages a queue of history items up to some maximum number of items.
* It adds items when there is an event, such as a toc click, a search lookup,
* or a concordance search.  It also responds to function requests to go back 
* in history, forward in history, or return to the last event.
*/
var MAX_HISTORY = 20;

function History(collection) {
	this.collection = collection;
	this.items = [];
	this.isFilled = false;
	this.isViewCurrent = false;
	Object.seal(this);
}
History.prototype.fill = function(callback) {
	var that = this;
	this.items.splice(0);
	var statement = 'select timestamp, book, chapter, verse, source, search ' +
		'from history order by timestamp desc limit ?';
	this.collection.select(statement, [ MAX_HISTORY ], function(results) {
		if (results instanceof IOError) {
			callback();
		} else {
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				var ref = new Reference(row.book, row.chapter, row.verse);
				var hist = new HistoryItem(ref.nodeId, row.source, row.search, row.timestamp);
				console.log('HISTORY', hist, hist.timestamp.toISOString());
				that.items.push(hist);
			}
			that.isFilled = true;
			that.isViewCurrent = false;
		}
		callback();
	});
};
History.prototype.addEvent = function(event) {
	var itemIndex = this.search(event.detail.id);
	if (itemIndex >= 0) {
		this.items.splice(itemIndex, 1);
	}
	var item = new HistoryItem(event.detail.id, event.type, event.detail.source);
	this.items.push(item);
	if (this.items.length > MAX_HISTORY) {
		var discard = this.items.shift();
	}
	this.isViewCurrent = false;
	
	// I might want a timeout to postpone this until after animation is finished.
	var statement = 'replace into history(timestamp, book, chapter, verse, source, search) ' +
		'values (?,?,?,?,?,?)';
	var timestampStr = item.timestamp.toISOString();
	var ref = new Reference(item.nodeId);
	var values = [ timestampStr, ref.book, ref.chapter, ref.verse, item.source, item.search ];
	this.collection.replace(statement, values, function(err) {
		if (err instanceof IOError) {
			console.log('replace error', JSON.stringify(err));
		}
	});
};
History.prototype.search = function(nodeId) {
	for (var i=0; i<this.items.length; i++) {
		var item = this.items[i];
		if (item.nodeId === nodeId) {
			return(i);
		}
	}
	return(-1);
};
History.prototype.size = function() {
	return(this.items.length);
};
History.prototype.last = function() {
	return(this.item(this.items.length -1));
};
History.prototype.item = function(index) {
	return((index > -1 && index < this.items.length) ? this.items[index] : 'JHN:1');
};
History.prototype.lastConcordanceSearch = function() {
	for (var i=this.items.length -1; i>=0; i--) {
		var item = this.items[i];
		if (item.search && item.search.length > 0) { // also trim it
			return(item.search);
		}
	}
	return('');
};
History.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};

/**
* This file contains IO constants and functions which are common to all file methods, which might include node.js, cordova, javascript, etc.
*/
var FILE_ROOTS = { 'application': '?', 'document': '../../dbl/current/', 'temporary': '?', 'test2dbl': '../../../dbl/current/' };
/**
* This class is a wrapper for SQL Error so that we can always distinguish an error
* from valid results.  Any method that calls an IO routine, which can expect valid results
* or an error should test "if (results instanceof IOError)".
*/
function IOError(err) {
	this.code = err.code;
	this.message = err.message;
}
/**
* This class is a file reader for Node.  It can be used with node.js and node-webkit.
* cordova requires using another class, but the interface should be the same.
*/
function FileReader(location) {
	this.fs = require('fs');
	this.location = location;
	Object.freeze(this);
}
FileReader.prototype.fileExists = function(filepath, callback) {
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
FileReader.prototype.readDirectory = function(filepath, callback) {
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
FileReader.prototype.readTextFile = function(filepath, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	//console.log('read file ', fullPath);
	this.fs.readFile(fullPath, { encoding: 'utf8'}, function(err, data) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(data);
		}
	});
};/**
* This class is a facade over the database that is used to store bible text, concordance,
* table of contents, history and questions.
*/
function DeviceDatabase(code, name) {
	this.code = code;
	this.name = name;
    this.className = 'DeviceDatabase';
	var size = 30 * 1024 * 1024;
	this.database = window.openDatabase(this.code, "1.0", this.name, size);
	this.codex = new CodexAdapter(this);
	this.tableContents = new TableContentsAdapter(this);
	this.concordance = new ConcordanceAdapter(this);
	this.styleIndex = new StyleIndexAdapter(this);
	this.styleUse = new StyleUseAdapter(this);
	this.history = new HistoryAdapter(this);
	this.questions = new QuestionsAdapter(this);
	Object.freeze(this);
}
DeviceDatabase.prototype.select = function(statement, values, callback) {
    this.database.readTransaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
        console.log(statement, values);
        tx.executeSql(statement, values, onSelectSuccess, onSelectError);
    }
    function onTranError(err) {
        console.log('select tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
    	console.log('select tran success');
    	callback();
    }
    function onSelectSuccess(tx, results) {
        console.log('select success results', JSON.stringify(results.rows));
        callback(results);
    }
    function onSelectError(tx, err) {
        console.log('select error', err);
        callback(new IOError(err));
    }
};
DeviceDatabase.prototype.executeDML = function(statement, values, callback) {
    var rowsAffected;
    this.database.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
        console.log('exec tran start', statement, values);
        tx.executeSql(statement, values, onExecSuccess, onExecError);
    }
    function onTranError(err) {
        console.log('execute tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('execute trans completed', rowsAffected);
        callback(rowsAffected);
    }
    function onExecSuccess(tx, results) {
    	console.log('excute sql success', results.rowsAffected);
        rowsAffected = results.rowsAffected;
    	//if (results.rowsAffected === 0) {
    	//	callback(new IOError(1, 'No rows affected by update'));
    	//} else {
    	//	callback();
    	//}
    }
    function onExecError(tx, err) {
    	console.log('execute sql error', JSON.stringify(err));
    	callback(new IOError(err));
    }
};
DeviceDatabase.prototype.bulkExecuteDML = function(statement, array, callback) {
	this.database.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
  		console.log('bulk tran start', statement, array[0], onExecSuccess, onExecError);
  		for (var i=0; i<array.length; i++) {
        	tx.executeSql(statement, array[i]);
        }
    }
    function onTranError(err) {
        console.log('bulk tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('bulk tran completed');
        callback();
    }
    function onExecSuccess(tx, results) {
    	if (results.rowsAffected !== array.length) {
    		callback(new IOError(1, array.length + ' rows input, but ' + results.rowsAffected + ' processed.'));
    	} else {
    		callback();
    	}
    }
    function onExecError(tx, err) {
    	console.log('bulk sql error', JSON.stringify(err));
    	callback(IOError(err));
    }
};
DeviceDatabase.prototype.executeDDL = function(statement, callback) {
    this.database.transaction(onTranStart, onTranError);

    function onTranStart(tx) {
        console.log('exec tran start', statement);
        tx.executeSql(statement, [], onExecSuccess, onExecError);
    }
    function onTranError(err) {
        callback(new IOError(err));
    }
    function onExecSuccess(tx, results) {
        callback();
    }
    function onExecError(tx, err) {
        callback(new IOError(err));
    }
};

/**
* This class is the database adapter for the codex table
*/
function CodexAdapter(database) {
	this.database = database;
	this.className = 'CodexAdapter';
	Object.freeze(this);
}
CodexAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists codex', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop codex success', err);
			callback(err);
		}
	});
};
CodexAdapter.prototype.create = function(callback) {

};
CodexAdapter.prototype.load = function(array, callback) {

};
CodexAdapter.prototype.getChapter = function(values, callback) {

};/**
* This class is the database adapter for the concordance table
*/
function ConcordanceAdapter(database) {
	this.database = database;
	this.className = 'ConcordanceAdapter';
	Object.freeze(this);
}
ConcordanceAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists concordance', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop concordance success', err);
			callback(err);
		}
	});
};
ConcordanceAdapter.prototype.create = function(callback) {

};
ConcordanceAdapter.prototype.load = function(array, callback) {

};
ConcordanceAdapter.prototype.select = function(values, callback) {

};/**
* This class is the database adapter for the tableContents table
*/
function TableContentsAdapter(database) {
	this.database = database;
	this.className = 'TableContentsAdapter';
	Object.freeze(this);
}
TableContentsAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists tableContents', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop tableContents success', err);
			callback(err);
		}
	});
};
TableContentsAdapter.prototype.create = function(callback) {

};
TableContentsAdapter.prototype.load = function(array, callback) {

};
TableContentsAdapter.prototype.select = function(values, callback) {

};/**
* This class is the database adapter for the styleIndex table
*/
function StyleIndexAdapter(database) {
	this.database = database;
	this.className = 'StyleIndexAdapter';
	Object.freeze(this);
}
StyleIndexAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists styleIndex', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop styleIndex success', err);
			callback(err);
		}
	});
};
StyleIndexAdapter.prototype.create = function(callback) {

};
StyleIndexAdapter.prototype.load = function(array, callback) {

};/**
* This class is the database adapter for the styleUse table
*/
function StyleUseAdapter(database) {
	this.database = database;
	this.className = 'StyleUseAdapter';
	Object.freeze(this);
}
StyleUseAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists styleUse', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop styleUse success', err);
			callback(err);
		}
	});
};
StyleUseAdapter.prototype.create = function(callback) {

};
StyleUseAdapter.prototype.load = function(array, callback) {

};/**
* This class is the database adapter for the history table
*/
function HistoryAdapter(database) {
	this.database = database;
	this.className = 'HistoryAdapter';
	Object.freeze(this);
}
HistoryAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists history', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop history success', err);
			callback(err);
		}
	});
};
HistoryAdapter.prototype.create = function(callback) {

};
HistoryAdapter.prototype.select = function(values, callback) {

};
HistoryAdapter.prototype.insert = function(values, callback) {

};
HistoryAdapter.prototype.delete = function(values, callback) {

};/**
* This class is the database adapter for the questions table
*/
function QuestionsAdapter(database) {
	this.database = database;
	this.className = 'QuestionsAdapter';
	Object.freeze(this);
}
QuestionsAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists questions', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop questions success', err);
			callback(err);
		}
	});
};
QuestionsAdapter.prototype.create = function(callback) {

};
QuestionsAdapter.prototype.select = function(values, callback) {

};
QuestionsAdapter.prototype.insert = function(values, callback) {

};
QuestionsAdapter.prototype.update = function(values, callback) {

};
QuestionsAdapter.prototype.delete = function(values, callback) {

};/**
* This class is a facade over a collection in a database.  
* At this writing, it is a facade over a Web SQL Sqlite3 database, 
* but it intended to hide all database API specifics
* from the rest of the application so that a different database can be put in its
* place, if that becomes advisable.
* Gary Griswold, July 2, 2015
*/
function DeviceCollection(database, table) {
	this.database = database;
	this.table = table;
	Object.freeze(this);
}
DeviceCollection.prototype.drop = function(callback) {
	var table = this.table;
	this.database.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
    	tx.executeSql('drop table if exists ' + table);
    }
    function onTranError(err) {
        console.log('drop tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('drop transaction completed');
        callback();
    }
};
DeviceCollection.prototype.create = function(schema, callback) {
	var table = this.table;
	if (schema) {
    	this.database.transaction(onTranStart, onTranError, onTranSuccess);
	}

    function onTranStart(tx) {
    	var sql = 'create table if not exists ' + table + '(' + schema + ')';
		console.log(sql);
		tx.executeSql(sql);
    }
    function onTranError(err) {
        console.log('create tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('create transaction completed');
        callback();
    }
};
DeviceCollection.prototype.load = function(names, array, callback) {
	var that = this;
	if (names && array && array.length > 0) {
		this.database.transaction(onTranStart, onTranError, onTranSuccess);
	}
    function onTranStart(tx) {
  		var statement = that.insertStatement(names);
  		console.log(statement);
  		for (var i=0; i<array.length; i++) {
        	tx.executeSql(statement, array[i]);
        }
    }
    function onTranError(err) {
        console.log('load tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('load transaction completed');
        callback();
    }
};
DeviceCollection.prototype.insert = function(row, callback) {
	var that = this;
	if (row) {
		this.database.transaction(onTranStart, onTranError, onTranSuccess);
	}
    function onTranStart(tx) {
    	var names = Object.keys(row);
		var statement = that.insertStatement(names);
		var values = that.valuesToArray(names, row);
  		console.log(statement);
        tx.executeSql(statement, values);
    }
    function onTranError(err) {
        console.log('insert tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('insert transaction completed');
        callback();
    }
};
/** deprecated for consistency insert statement into insert and load db */
DeviceCollection.prototype.insertStatement = function(names) {
	var sql = [ 'insert into ', this.table, ' (' ];
	for (var i=0; i<names.length; i++) {
		if (i > 0) {
			sql.push(', ');
		}
		sql.push(names[i]);
	}
	sql.push(') values (');
	for (var i=0; i<names.length; i++) {
		if (i > 0) {
			sql.push(',');
		}
		sql.push('?');
	}
	sql.push(')');
	return(sql.join(''));
};
DeviceCollection.prototype.update = function(statement, values, callback) {
	// This should create an update statement from the element names 
};
DeviceCollection.prototype.replace = function(statement, values, callback) {
    this.database.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
        console.log(statement, values);
        tx.executeSql(statement, values);
    }
    function onTranError(err) {
        console.log('replace tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('replace transaction completed');
        callback();
    }
};
DeviceCollection.prototype.delete = function(statement, values, callback) {
	// This should delete the row for the key specified in the row object
};
DeviceCollection.prototype.select = function(statement, values, callback) {
    this.database.readTransaction(onTranStart, onTranError);

    function onTranStart(tx) {
        console.log(statement, values);
        tx.executeSql(statement, values, onSelectSuccess, onSelectError);
    }
    function onTranError(err) {
        console.log('select tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onSelectSuccess(tx, results) {
        console.log('success results', JSON.stringify(results.rows));
        callback(results);
    }
    function onSelectError(tx, err) {
        console.log('select error', err);
        callback(new IOError(err));
    }
};
DeviceCollection.prototype.get = function(statement, values, callback) {
    this.select(statement, values, function(results) {
        if (results instanceof IOError) {
            callback(results);
        } else if (results.rows.length > 0) {
            var row = results.rows.item(0);
            callback(row);
        } else {
            callback(null);
        }
    });
};
DeviceCollection.prototype.valuesToArray = function(names, row) {
	var values = [ names.length ];
	for (var i=0; i<names.length; i++) {
		values[i] = row[names[i]];
	}
	return(values);
};/**
* Unit Test Harness for AssetController
*/
var types = new AssetType('document', 'WEB');
types.chapterFiles = true;
types.tableContents = true;
types.concordance = true;
types.styleIndex = true;
types.history = true;
types.questions = true;
var database = new DeviceDatabase(types.versionCode, 'versionNameHere');

var builder = new AssetBuilder(types, database);
builder.build(function(err) {
	console.log('AssetControllerTest.build', err);
});
