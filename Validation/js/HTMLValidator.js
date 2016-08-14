/**
* This validation program specifically checks that the generated HTML is identical in content
* to the original USX file.  To do this it reads the HTML data from the generated database,
* parses it, and generates USX files
*/
var fs = require("fs");
//var os = require("os");
var HTML_BIBLE_PATH = "../../DBL/3prepared/";
var OUT_BIBLE_PATH = "output/html/";
var USX_BIBLE_PATH = "../../DBL/2current/";
var EOL = '\r\n';

function HTMLValidator(version) {
	this.version = version;
	this.versionPath = HTML_BIBLE_PATH + version + '.db';
	this.parser = new HTMLParser();
	this.db = null;
}
HTMLValidator.prototype.open = function(callback) {
	var that = this;
	var sqlite3 = require('sqlite3');
	this.db = new sqlite3.Database(this.versionPath, sqlite3.OPEN_READWRITE, function(err) {
		if (err) that.fatalError(err, 'openDatabase');
		that.db.on('trace', function(sql) { console.log('DO ', sql); });
		that.db.on('profile', function(sql, ms) { console.log(ms, 'DONE', sql); });
		callback();
	});
};
HTMLValidator.prototype.validateBook = function(index, books, callback) {
	var that = this;
	if (index >= books.length) {
		callback();
	} else {
		var chapters = [];
		console.log('doing ', books[index]);
		var book = books[index].code;
		this.db.all("SELECT html FROM chapters WHERE reference LIKE ?", book + '%', function(err, results) {
			if (err) that.fatalError(err, 'select html');
			for (var i=0; i<results.length; i++) {
				//console.log(results[i].html);
				var node = that.parser.readBook(results[i].html);
				//console.log(node.toHTML());
				chapters.push(node);
			}
			var usx = convertHTML2USX(chapters);
			//console.log('-------');
			//console.log(usx);
			compareUSXFile(book, usx, function() {
				that.validateBook(index + 10000, books, callback);
			});
		});
	}
	
	function convertHTML2USX(chapters) {
		var usx = [];
		usx.push(String.fromCharCode('0xFEFF'));
		usx.push('<?xml version="1.0" encoding="utf-8"?>', EOL);
		usx.push('<usx version="2.0">', EOL);
		for (var i=0; i<chapters.length; i++) {
			recurseOverHTML(usx, chapters[i]);
		}
		usx.push('</usx>');
		return(usx.join(''));
	}
	
	function recurseOverHTML(usx, node) {
		convertOpenElement(usx, node);
		if (node.children) {
			for (var i=0; i<node.children.length; i++) {
				recurseOverHTML(usx, node.children[i]);		
			}
		}
		convertCloseElement(usx, node);
	}
	
	function convertOpenElement(usx, node) {
		//console.log(node.tagName);
		switch(node.tagName) {
			case 'ROOT':
				// do nothing
				break;
			case 'article':
				usx.push('<book code="' + node.id + '" style="' + node['class'] + '"></book>', EOL); 
				break;
			case 'section':
				var parts = node.id.split(':');
				usx.push('<chapter number="' + parts[1] + '" style="c" />', EOL);
				node.children = [];
				break;
			case 'p':
				if (node['class'] !== 'c') {
					usx.push('<para style="' + node['class'] + '">', EOL);
				}
				break;
			case 'span':
				if (node['class'] === 'v') {
					var parts = node.id.split(':');
					usx.push('<verse number="' + parts[2] + '" style="' + node['class'] + '" />');
					node.children = [];
				} else if (node['class'] === 'topf' || node['class'] === 'topx') {
					// output nothing
					clearTextChildren(node);
				} else if (node.note) {
					usx.push('<note caller="+" style="f"><char style="' + node['class'] + '">');
				} else {
					usx.push('<char style="' + node['class'] + '">');
				}
				break;
			case 'TEXT':
				usx.push(node.text);
				break;
			default:
				throw new Error('unexpected HTML element ' + node.tagName + '.');		
		}
	}
	
	function clearTextChildren(node) {
		for (var i=0; i<node.children.length; i++) {
			var child = node.children[i];
			if (child.tagName === 'TEXT') {
				child.text = '';
			}
		}
	}
	
	function convertCloseElement(usx, node) {
		switch(node.tagName) {
			case 'ROOT':
			case 'article':
			case 'section':
			case 'TEXT':
				// do nothing
				break;
			case 'p':
				if (node['class'] !== 'c') {
					usx.push('</para>', EOL);
				}
				break;
			case 'span':
				if (node['class'] === 'v') {
					// do nothing
				} else if (node['class'] === 'topf' || node['class'] === 'topx') {
					// do nothing
				} else if (node.note) {
					usx.push(node.note, '</char></note>');
				} else {
					usx.push('</span>');
				}
				break;
			default:
				throw new Error('unexpected HTML element ' + node.tagName + '.');
				
		}
	}
	
	
	function compareUSXFile(book, data, callback) {
		var inFile = USX_BIBLE_PATH + that.version + '/USX_1/' + book + '.usx';
		console.log('INFILE', inFile);
		var outFile = OUT_BIBLE_PATH + book + '.usx';
		console.log('OUTFILE', outFile);
		fs.writeFile(outFile, data, { encoding: 'utf8'}, function(err) {
			if (err) {
				//console.log('WRITE ERROR', JSON.stringify(err));
				//process.exit(1);
				that.fatalError(err, 'Write USX File');
			}
			console.log('COMPARE ', book);
			var proc = require('child_process');
			proc.exec('diff ' + inFile + ' ' + outFile, { encoding: 'utf8' }, function(err, stdout, stderr) {
				if (err) {
					console.log('Diff Error', JSON.stringify(err));
				}
				console.log('STDOUT', stdout);
				console.log('STDERR', stderr);
				callback();
			});
		});
	}
};
HTMLValidator.prototype.fatalError = function(err, source) {
	console.log('FATAL ERROR ', err, ' AT ', source);
	process.exit(1);
};
HTMLValidator.prototype.completed = function() {
	console.log('HTMLValidator COMPLETED');
	this.db.close();
	process.exit(0);
};

function HTMLParser() {
}
HTMLParser.prototype.readBook = function(data) {
	var reader = new XMLTokenizer(data);
	var rootNode = new HTMLRoot();
	var nodeStack = [rootNode];
	var node = null;
	var count = 0;
	while (tokenType !== XMLNodeType.END && count < 300000) {

		var tokenType = reader.nextToken();

		var tokenValue = reader.tokenValue();
		//console.log('type=|' + tokenType + '|  value=|' + tokenValue + '|');
		count++;

		switch(tokenType) {
			case XMLNodeType.ELE_OPEN:
				node = new HTMLElement(tokenValue);
				node.whiteSpace = (priorType === XMLNodeType.WHITESP) ? priorValue : '';
				break;
			case XMLNodeType.ATTR_NAME:
				// do nothing
				break;
			case XMLNodeType.ATTR_VALUE:
				if (priorValue !== 'onclick') {
					node[priorValue] = tokenValue;
				}
				break;
			case XMLNodeType.ELE_END:
				node.emptyElement = false;
				nodeStack[nodeStack.length -1].addChild(node);
				nodeStack.push(node);
				break;
			case XMLNodeType.TEXT:
				node = new HTMLTextNode(tokenValue);
				nodeStack[nodeStack.length -1].addChild(node);
				break;
			case XMLNodeType.ELE_EMPTY:
				node.emptyElement = true;
				nodeStack[nodeStack.length -1].addChild(node);
				break;
			case XMLNodeType.ELE_CLOSE:
				node = nodeStack.pop();
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
				throw new Error('The XMLNodeType ' + tokenType + ' is unknown in HTMLParser.');
		}
		var priorType = tokenType;
		var priorValue = tokenValue;
	}
	return(rootNode);
};

function HTMLElement(tagName) {
	this.tagName = tagName;
	this.id = null;
	this['class'] = null;
	this.note = null;
	this.emptyElement = false;
	this.whiteSpace = '';
	this.children = [];
	Object.seal(this);
}
HTMLElement.prototype.addChild = function(node) {
	this.children.push(node);
};
HTMLElement.prototype.toString = function() {
	var array = [];
	this.buildHTML(array, false);
	return(array.join(''));	
};
HTMLElement.prototype.toHTML = function() {
	var array = [];
	this.buildHTML(array, true);
	return(array.join(''));	
};
HTMLElement.prototype.buildHTML = function(array, includeChildren) {
	array.push(EOL, '<', this.tagName);
	if (this.id) array.push(' id="', this.id, '"');
	if (this['class']) array.push(' class="', this['class'], '"');
	if (this.note) array.push(' note="', this.note, '"');
	if (this.emptyElement) {
		array.push(' />');
	} else {
		array.push('>');
		if (includeChildren) {
			for (var i=0; i<this.children.length; i++) {
				this.children[i].buildHTML(array, includeChildren);
			}
		}
		array.push('</', this.tagName, '>');
	}
};

function HTMLTextNode(text) {
	this.tagName = 'TEXT';
	this.text = text;
	Object.seal(this);
}
HTMLTextNode.prototype.toString = function() {
	return(this.text);
};
HTMLTextNode.prototype.buildHTML = function(array) {
	array.push(this.text);
};

function HTMLRoot() {
	this.tagName = 'ROOT';
	this.children = [];
}
HTMLRoot.prototype.addChild = function(node) {
	this.children.push(node);
};
HTMLRoot.prototype.toHTML = function() {
	var array = [];
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildHTML(array, true);
	}
	return(array.join(''));	
};


if (process.argv.length < 3) {
	console.log('Usage: HTMLValidator.sh  version');
	process.exit(1);
}
fs.lstat(OUT_BIBLE_PATH, function(err, stat) {
	if (err) {
		fs.mkdirSync(OUT_BIBLE_PATH);
	}
	var version = process.argv[2];
	var htmlValidator = new HTMLValidator(version);
	htmlValidator.open(function() {
		var canon = new Canon();
		htmlValidator.validateBook(0, canon.books, function() {
			htmlValidator.completed();
			console.log('HTMLValidator DONE');
		});
	});
});

