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
		return('<note caller="' + this.caller + '" style="' + this.style + elementEnd);
	} else {
		return('<note style="' + this.style + '" caller="' + this.caller + elementEnd);
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
* This class holds data for the table of contents of the entire Bible, or whatever part of the Bible was loaded.
*/
"use strict";

function TOC(books) {
	this.bookList = books || [];
	this.bookMap = {};
	this.filename = 'toc.json';
	for (var i=0; i<this.bookList.length; i++) {
		var book = this.bookList[i];
		this.bookMap[book.code] = book;
		Object.freeze(book);
	}
	Object.freeze(this);
};
TOC.prototype.addBook = function(book) {
	this.bookList.push(book);
	this.bookMap[book.code] = book;
};
TOC.prototype.find = function(code) {
	return(this.bookMap[code]);
};
// This needs a better solution. Filename should be stored somewhere
TOC.prototype.findFilename = function(book) {
	for (var i=0; i<this.bookList.length; i++) {
		if (book.code === this.bookList[i].code) {
			var num = i +1;
			var zeroPad = (num < 10) ? '00' : '0';
			return(zeroPad + num + book.code + '.usx');
		}
	}
	return(null);
};
TOC.prototype.toJSON = function() {
	return(JSON.stringify(this.bookList, null, ' '));
};/**
* This class holds the table of contents data each book of the Bible, or whatever books were loaded.
*/
"use strict";

function TOCBook(code) {
	this.code = code;
	this.encoding = '';
	this.heading = '';
	this.title = '';
	this.name = '';
	this.abbrev = '';
	this.lastChapter = 0;
	Object.seal(this);
};/**
* This class holds the concordance of the entire Bible, or whatever part of the Bible was available.
*/
"use strict";

function Concordance(words) {
	this.index = words || {};
	console.log('index assigned ' , Object.keys(this.index).length);
	this.filename = 'concordance.json';
	Object.freeze(this);
};
Concordance.prototype.addEntry = function(word, reference) {
	if (this.index[word] === undefined) {
		this.index[word] = [];
	}
	this.index[word].push(reference);
};
Concordance.prototype.size = function() {
	return(Object.keys(this.index).length);
}
Concordance.prototype.find = function(word) {
	return(this.index[word]);
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
* This class holds an index of styles of the entire Bible, or whatever part of the Bible was loaded into it.
*/
"use strict";

function StyleIndex() {
	this.index = {};
	this.filename = 'styleIndex.json';
	this.completed = [ 'book.id', 'para.ide', 'para.h', 'para.toc1', 'para.toc2', 'para.toc3', 'para.cl',
		'para.mt', 'para.mt2', 'para.mt3', 'para.ms', 'para.d',
		'chapter.c', 'verse.v',
		'para.p', 'para.m', 'para.b', 'para.mi', 'para.pi', 'para.li', 'para.nb',
		'para.sp', 'para.q', 'para.q2',
		'note.f', 'note.x',
		'char.wj', 'char.qs'];
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
NodeFileReader.prototype.fileExists = function(filepath, successCallback, failureCallback) {
	this.fs.stat(filepath, function(err, stat) {
		if (err) {
			err.filepath;
			failureCallback(err);
		} else {
			successCallback(stat);
		}
	});
};
NodeFileReader.prototype.readDirectory = function(filepath, successCallback, failureCallback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	console.log('read directory ', fullPath);
	this.fs.readdir(fullPath, function(err, data) {
		if (err) {
			err.filepath = filepath;
			failureCallback(err);
		} else {
			successCallback(data);
		}
	});
};
NodeFileReader.prototype.readTextFile = function(filepath, successCallback, failureCallback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	console.log('read file ', fullPath);
	this.fs.readFile(fullPath, { encoding: 'utf-8'}, function(err, data) {
		if (err) {
			failureCallback(err);
		} else {
			successCallback(data);
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
NodeFileWriter.prototype.writeTextFile = function(filepath, data, successCallback, failureCallback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	var options = { encoding: 'utf-8'};
	this.fs.writeFile(fullPath, data, options, function(err) {
		if (err) {
			err.filepath = filepath;
			failureCallback(err);
		} else {
			successCallback(filepath);
		}
	});
};/**
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
	this.bookCode = '';
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
* This class traverses a DOM tree in order to create an equivalent HTML document.
*/
"use strict"

function HTMLBuilder() {
	this.result = [];
	this.filename = 'bible.html';
	Object.freeze(this);
};
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
			break;
	}
	if ('childNodes' in node) {
		for (var i=0; i<node.childNodes.length; i++) {
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
* The Table of Contents and Concordance must be created by processing the entire text.  Since the parsing of the XML
* is a significant amount of the time to do this, this class reads over the entire Bible text and creates
* all of the required assets.
*/
"use strict";

function AssetBuilder(location, versionCode, options) {
	this.versionCode = versionCode;
	this.builders = [];
	if (options.buildTableContents) {
		this.builders.push(new TOCBuilder());
	}
	if (options.buildConcordance) {
		this.builders.push(new ConcordanceBuilder());
	}
	if (options.buildStyleIndex) {
		this.builders.push(new StyleIndexBuilder());
	}
	if (options.buildHTML) {
		this.builders.push(new HTMLBuilder()); // HTMLBuilder does NOT yet have the correct interface for this.
	}
	this.reader = new NodeFileReader(location);
	this.parser = new USXParser();
	this.writer = new NodeFileWriter(location);
	this.filesToProcess = [];
	Object.freeze(this);
};
AssetBuilder.prototype.build = function(successCallback, failureCallback) {
	var that = this;
	this.reader.readDirectory(this.getPath(''), dirReadSuccess, dirReadFailure);

	function dirReadFailure(err) {
		console.log('directory read err ', JSON.stringify(err));
		failureCallback(err);
	}
	function dirReadSuccess(files) {
		var count = 0
		for (var i=0; i<files.length && count < 66; i++) {
			if (files[i].indexOf('.usx') > 0) {
				that.filesToProcess.push(files[i]);
				count++;
			}
		}
		processReadFile(that.filesToProcess.shift());
	}
	function fileReadFailure(err) {
		console.log('file read err ', JSON.stringify(err));
		failureCallback(err);
	}
	function fileReadSuccess(data) {
		var rootNode = that.parser.readBook(data);
		for (var i=0; i<that.builders.length; i++) {
			that.builders[i].readBook(rootNode);
		}
		processReadFile(that.filesToProcess.shift());
	}
	function processReadFile(file) {
		if (file) {
			that.reader.readTextFile(that.getPath(file), fileReadSuccess, fileReadFailure);
		} else {
			processWriteResult(that.builders.shift());
		}
	}
	function processWriteResult(builder) {
		if (builder) {
			var json = builder.toJSON();
			var filepath = that.getPath(builder.filename);
			that.writer.writeTextFile(filepath, json, fileWriteSuccess, fileWriteFailure);
		} else {
			successCallback();
		}
	}
	function fileWriteFailure(err) {
		console.log('file write failure ', err);
		failureCallback(err);
	}
	function fileWriteSuccess(filename) {
		console.log('file write success ', filename);
		processWriteResult(that.builders.shift());
	}
};
AssetBuilder.prototype.getPath = function(filename) {
	return('usx/' + this.versionCode + '/' + filename);
};/**
* This class traverses the USX data model in order to find each book, and chapter
* in order to create a table of contents that is localized to the language of the text.
*/
"use strict"

function TOCBuilder() {
	this.toc = new TOC([]);
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
			this.tocBook = new TOCBook(node.code);
			this.toc.addBook(this.tocBook);
			break;
		case 'chapter':
			this.tocBook.lastChapter = node.number;
			break;
		case 'para':
			switch(node.style) {
				case 'ide':
					this.tocBook.encoding = node.children[0].text;
					break;
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
* This class presents the table of contents, and responds to user actions.
*/
"use strict";

function TableContentsView(versionCode) {
	this.versionCode = versionCode;
	this.toc = null;
	var bodyNodes = document.getElementsByTagName('body');
	this.bodyNode = bodyNodes[0];
	Object.seal(this);
};
TableContentsView.prototype.showTocBookList = function() {
	if (this.toc) { // should check the version
		this.buildTocBookList();
	}
	else {
		var that = this;
		var reader = new NodeFileReader('application');
		var filename = 'usx/' + this.versionCode + '/toc.json';
		reader.readTextFile(filename, readSuccessHandler, readFailureHandler);
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
	var parts = nodeId.split(':');
	var book = this.toc.find(parts[0]);
	var filename = this.toc.findFilename(book);
	console.log('open chapter', nodeId);
	this.bodyNode.dispatchEvent(new CustomEvent(EVENT.TOC2PASSAGE, { detail: { filename: filename, id: nodeId }}));
};


/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

function CodexView(versionCode) {
	this.versionCode = versionCode;
	var bodyNodes = document.getElementsByTagName('body');
	this.bodyNode = bodyNodes[0];
	Object.freeze(this);
};
CodexView.prototype.showPassage = function(filename, nodeId) {
	var that = this;
	var reader = new NodeFileReader();
	var filepath = 'usx/' + this.versionCode + '/' + filename;
	reader.readTextFile('application', filepath, readSuccessHandler, readFailedHandler);

	function readSuccessHandler(data) {
		var parser = new USXParser();
		var usxNode = parser.readBook(data);
	
		var dom = new DOMBuilder();
		var fragment = dom.toDOM(usxNode);

		that.removeBody();
		var bodyNodes = document.getElementsByTagName('body');
		bodyNodes[0].appendChild(fragment);

		that.scrollTo(nodeId);
	};
	function readFailedHandler(err) {
		console.log(JSON.stringify(err));
	};
};
CodexView.prototype.scrollTo = function(nodeId) {
	console.log('verse', nodeId);
	var verse = document.getElementById(nodeId);
	var rect = verse.getBoundingClientRect();
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
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
"use strict"

var EVENT = { TOC2PASSAGE: 'toc2passage' };

function AppViewController(versionCode) {
	this.versionCode = versionCode;
	this.tableContents = new TableContentsView(versionCode);
	this.codex = new CodexView(versionCode);
	this.searchViewBuilder = new SearchViewBuilder(versionCode);

	this.bodyNode = this.tableContents.bodyNode;
	this.bodyNode.addEventListener(EVENT.TOC2PASSAGE, toc2PassageHandler);
	var that = this;
	Object.freeze(this);

	function toc2PassageHandler(event) {
		var detail = event.detail;
		console.log(JSON.stringify(detail));
		that.codex.showPassage(detail.filename, detail.id);	
	}
};
AppViewController.prototype.begin = function() {
	//this.tableContents.showTocBookList();
	this.searchViewBuilder.showSearch();
};


/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
"use strict";

function SearchView(concordance) {
	this.concordance = concordance;
	Object.freeze(this);
};
SearchView.prototype.build = function() {

};/**
* This class does a lazy construction of all of the parts of the SearchView, or just attaches
* the searchView if it already exists.
*/
"use strict";

function SearchViewBuilder(versionCode) {
	this.versionCode = versionCode;
	this.searchView = null;
	this.concordance = new Concordance();

	Object.seal(this);
};
SearchViewBuilder.prototype.showSearch = function() {
	if (this.searchView) {
		this.attachSearchView();
	} 
	else if (this.concordance.size > 1000) {
		this.buildSearchView();
	}
	else {
		var that = this;
		var reader = new NodeFileReader('application');
		reader.fileExists(this.getPath(this.concordance.filename), existsSuccessHandler, existsFailureHandler);
	}

	function existsFailureHandler(err) {
		if (err.code === 'ENOENT') {
			console.log('check exists concordance json is not found');
			that.createConcordanceFile();
		} 
		else {
			console.log('check exists concordance.json failure ' + JSON.stringify(err));
		}
	}
	function existsSuccessHandler(stat) {
		console.log('concordance.json exists ' + JSON.stringify(stat));
		that.readConcordanceFile();
 	}
};
SearchViewBuilder.prototype.createConcordanceFile = function() {
	var that = this;
	var options = { buildTableContents: true, buildConcordance: true, buildStyleIndex: true };
	var builder = new AssetBuilder('application', this.versionCode, options);
	builder.build(createConcordanceSuccess, createConcordanceFailure);

	function createConcordanceFailure(err) {
		console.log('create concordance file failure');
	}
	function createConcordanceSuccess() {
		that.readConcordanceFile();
	}
};
SearchViewBuilder.prototype.readConcordanceFile = function() {
	var that = this;
	var reader = new NodeFileReader('application');
	var fullPath = this.getPath(this.concordance.filename);
	reader.readTextFile(fullPath, readSuccessHandler, readFailureHandler);
	
	function readFailureHandler(err) {
		console.log('read concordance.json failure ' + JSON.stringify(err));
	};
	function readSuccessHandler(data) {
		that.concordance = new Concordance(JSON.parse(data));
		console.log('condordance word ' + that.concordance.size());
		that.buildSearchView();
	};
};
SearchViewBuilder.prototype.buildSearchView = function() {
	this.searchView = new SearchView(this.concordance);
	this.searchView.build();
	this.attachSearchView();
};
SearchViewBuilder.prototype.attachSearchView = function() {
	var appTop = document.getElementById('appTop');
	for (var i=appTop.children.length -1; i>=0; i--) {
		var child = appTop.children[i];
		appTop.removeChild(child);
	}
	//appTop.appendChild(this.searchView);
};
SearchViewBuilder.prototype.processFailure = function(err) {
	console.log('process failure  ' + JSON.stringify(err));
};
SearchViewBuilder.prototype.getPath = function(filename) {
	return('usx/' + this.versionCode + '/' + filename);
};
