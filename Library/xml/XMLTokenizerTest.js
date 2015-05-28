/**
* This file is the unit test of XMLTokenizer
*/
"use strict";

var fs = require("fs");
var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/BibleApp Project/Bibles/USX/WEB World English Bible";
var OUT_BIBLE_PATH = "/Users/garygriswold/Desktop/BibleApp Project/Bibles/USX/WEB_XML_OUT";

function XMLSerializer() {
	this.result = [];
	Object.seal(this);
}
XMLSerializer.prototype.write = function(nodeType, nodeValue) {
	switch(nodeType) {
		case XMLNodeType.ELE_OPEN:
			this.result.push('<', nodeValue);
			break;
		case XMLNodeType.ATTR_NAME:
			this.result.push(' ', nodeValue, '=');
			break;
		case XMLNodeType.ATTR_VALUE:
			this.result.push('"', nodeValue, '"');
			break;
		case XMLNodeType.ELE_END:
			this.result.push('>');
			break;
		case XMLNodeType.WHITESP:
			this.result.push(nodeValue);
			break;
		case XMLNodeType.TEXT:
			this.result.push(nodeValue);
			break;
		case XMLNodeType.ELE_EMPTY:
			this.result.push(' />');
			break;
		case XMLNodeType.ELE_CLOSE:
			this.result.push('</', nodeValue, '>');
			break;
		case XMLNodeType.PROG_INST:
			this.result.push('\uFEFF', nodeValue);
			break;
		case XMLNodeType.END:
			break;
		default:
			throw new Error('The XMLNodeType ' + nodeType + ' is unknown in XMLWriter');
	}
};
XMLSerializer.prototype.close = function() {
	return(this.result.join(''));
};

function symmetricTest(filename) {
	var inFile = WEB_BIBLE_PATH + "/" + filename;
	var data = fs.readFileSync(inFile, "utf8");
	var reader = new XMLTokenizer(data);
	var writer = new XMLSerializer();
	var count = 0;
	var type;
	while (type !== XMLNodeType.END && count < 770000) {
		type = reader.nextToken();
		var value = reader.tokenValue();
		//console.log('type=|' + type + '|  value=|' + value + '|');
		writer.write(type, value);
		count++;
	};
	var result = writer.close();
	var outFile = OUT_BIBLE_PATH + "/" + filename;
	fs.writeFileSync(outFile, result, "utf8");
}
var files = fs.readdirSync(WEB_BIBLE_PATH);
var len = files.length;
for (var i=0; i<len; i++) {
	var file = files[i];
	symmetricTest(file);
};