/**
* This class reads USX files and creates an equivalent object tree
* elements = [usx, book, chapter, para, verse, note, char];
* paraStyle = [b, d, cl, cp, h, li, p, pc, q, q2, mt, mt2, mt3, mte, toc1, toc2, toc3, ide, ip, ili, ili2, is, m, mi, ms, nb, pi, s, sp];
* charStyle = [add, bk, it, k, fr, fq, fqa, ft, wj, qs, xo, xt];
*/
"use strict";
var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB World English Bible";
var OLD_TESTAMENT = ["GEN", "EXO" ];
var NEW_TESTAMENT = [];

function USXReader(path) {
	this._path = path;
	this._fs = require("fs");
};
USXReader.prototype.books = function() {
	return(this._books);
};
USXReader.prototype.readAll = function() {
	var files = this._fs.readdirSync(this._path);
	var len = files.length;
	for (var i=0; i<len; i++) {
		var file = files[i];
		var bookCode = file.substr(3, 3);
		this.readBook(file, bookCode);
	};
};
USXReader.prototype.readCanon = function() {

};
USXReader.prototype.readBook = function(filename, bookCode) {
	console.log(filename, bookCode);

	var data = this._fs.readFileSync(this._path + '/' + filename, 'utf8');
	var sax = require("sax");
	var parser = sax.parser(true);
		
	var nodeStack = [];

	parser.onerror = function(err) {
  		//console.log(err, parser.line, parser.column, parser.position);
	};
	parser.ontext = function(text) {
		var textNode = new Text(text);
		console.log('inside ontext len ' + nodeStack.length, text.length);
		//nodeStack[nodeStack.length -1].addChild(textNode);
		console.log(textNode.text);
		//console.log(text);
		//console.log("text |" + text + "|");
		//console.log(typeof text);
		//console.log(text.length);
		//console.log(text[0]);
		//for (var i=0; i<text.length; i++) {
		//	console.log(text.charCodeAt(i));
		//}
  		// got some text.  t is the string of text.
	};
	parser.onopentag = function(node) {
		switch(node.name) {
			case 'usx':
				var usxNode = new USX(node.attributes.version);
				nodeStack.push(usxNode);
				console.log('*** push usx ' + nodeStack.length);
				console.log(usxNode.toUSX());
				break;
			case 'book':
				var bookNode = new Book(node.attributes.code, node.attributes.style);
				nodeStack[0].addChild(bookNode);
				console.log(bookNode.toUSX());
				break;
			case 'chapter':
				var chapterNode = new Chapter(node.attributes.number, node.attributes.style);
				nodeStack[0].addChild(chapterNode);
				console.log(chapterNode.toUSX());
				break;
			case 'para':
				var paraNode = new Para(node.attributes.style);
				nodeStack.push(paraNode);
				console.log('*** push para ' + nodeStack.length);
				nodeStack[0].addChild(paraNode);
				console.log(paraNode.toUSX());
				break;
			case 'verse':
				var verseNode = new Verse(node.attributes.number, node.attributes.style);
				nodeStack[1].addChild(verseNode);
				console.log(verseNode.toUSX());
				break;
			case 'note':
				var noteNode = new Note(node.attributes.caller, node.attributes.style);
				nodeStack[1].addChild(noteNode);
				console.log(noteNode.toUSX());
				break;
			case 'char':
				var charNode = new Char(node.attributes.style);
				nodeStack.push(charNode);
				console.log('*** push char ' + nodeStack.length);
				nodeStack[1].addChild(charNode);
				console.log('******* char' + node);
				break;
			default:
				// nothing yet
		}
	};
	parser.onclosetag = function(node) {
		switch(node) {
			case 'usx':
			case 'para':
			case 'char':
				console.log('*** pop ' + node + ' ' + nodeStack.length);
				var popped = nodeStack.pop();
				//console.log(popped);
				if (popped.name !== node) { // popped has no name
					//throw Error("Popped " + popped.name + ", but expected " + node);
				}
				break;
		}
	};
	parser.onattribute = function(attr) {
  		// an attribute.  attr has "name" and "value"
	};
	parser.onend = function() {
  		console.log('********* onend event fired *****************');
	};
	parser.write(data);
};
