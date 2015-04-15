"use strict"

var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/BibleApp Project/Bibles/USX/WEB World English Bible";
var fs = require("fs");
var builder = new StyleIndexBuilder();

function test(filename) {
	var data = fs.readFileSync(WEB_BIBLE_PATH + '/' + filename, "utf8");
	var rootNode = parser.readBook(data);
	builder.readBook(rootNode);
}

var parser = new USXParser();
var files = fs.readdirSync(WEB_BIBLE_PATH);
var len = files.length;
len = 66;
for (var i=0; i<len; i++) {
	var file = files[i];
	test(file);
};

var styleIndex = builder.styleIndex;
styleIndex.dumpAlphaSort();


var json = JSON.stringify(styleIndex, null, ' ');
fs.writeFileSync('/Users/garygriswold/Desktop/styleIndex.json', json, 'utf-8');