"use strict"

var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB World English Bible";
var fs = require("fs");
var builder = new TOCBuilder();

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
	test(files[i]);
};

var toc = builder.toc;
//styleIndex.dumpAlphaSort();

console.log('after dump alpha sort');

var json = JSON.stringify(toc, null, ' ');
fs.writeFileSync('/Users/garygriswold/Desktop/toc.json', json, 'utf-8');
