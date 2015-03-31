/**
* This class reads USX files and creates an equivalent object tree
* elements = [usx, book, chapter, para, verse, note, char];
* paraStyle = [b, d, cl, cp, h, li, p, pc, q, q2, mt, mt2, mt3, mte, toc1, toc2, toc3, ide, ip, ili, ili2, is, m, mi, ms, nb, pi, s, sp];
* charStyle = [add, bk, it, k, fr, fq, fqa, ft, wj, qs, xo, xt];
*/
"use strict";

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

	var reader = new XMLReader(this._path + "/" + filename);
	var nodeStack = [];
	var node;
	var tempNode = {}

	var tokenType;
	var tokenValue;
	var priorToken;
	var count = 0;
	while (tokenType !== XMLNodeType.END && count < 300000) {
		tokenType = reader.nextToken();
		priorToken = tokenValue;
		tokenValue = reader.tokenValue();
		//console.log('type=|' + type + '|  value=|' + value + '|');
		count++;

		switch(tokenType) {
			case XMLNodeType.ELE_OPEN:
				tempNode = { tagName: tokenValue };
				break;
			case XMLNodeType.ATTR_NAME:
				tempNode[tokenValue] = '';
				break;
			case XMLNodeType.ATTR_VALUE:
				tempNode[priorToken] = tokenValue;
				break;
			case XMLNodeType.ELE_END:
				node = this.createUSXObject(tempNode);
				console.log(node.openElement());
				if (nodeStack.length > 0) {
					nodeStack[nodeStack.length -1].addChild(node);
				}
				nodeStack.push(node);
				break;
			case XMLNodeType.TEXT:
				node = new Text(tokenValue);
				console.log(node.text);
				nodeStack[nodeStack.length -1].addChild(node);
				break;
			case XMLNodeType.ELE_EMPTY:
				node = this.createUSXObject(tempNode);
				console.log(node.openElement());
				nodeStack[nodeStack.length -1].addChild(node);
				break;
			case XMLNodeType.ELE_CLOSE:
				node = nodeStack.pop();
				console.log(node.closeElement());
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
				throw new Error('The XMLNodeType ' + nodeType + ' is unknown in USXReader.');
		}
	};
};
USXReader.prototype.createUSXObject = function(tempNode) {
	switch(tempNode.tagName) {
		case 'char':
			return(new Char(tempNode.style));
			break;
		case 'note':
			return(new Note(tempNode.caller, tempNode.style));
			break;
		case 'verse':
			return(new Verse(tempNode.number, tempNode.style));
			break;
		case 'para':
			return(new Para(tempNode.style));
			break;
		case 'chapter':
			return(new Chapter(tempNode.number, tempNode.style));
			break;
		case 'book':
			return(new Book(tempNode.code, tempNode.style));
			break;
		case 'usx':
			return(new USX(tempNode.version));
			break;
		default:
			throw new Error('USX element name ' + tempNode.tagName + ' is not known to USXReader.');
	}
};
