"use strict"

var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB World English Bible";
var fs = require("fs");
var visitor = new ConcordanceVisitor();

function test(filename) {
	var bookCode = filename.substring(3, 3);
	var data = fs.readFileSync(WEB_BIBLE_PATH + '/' + filename, "utf8");
	var rootNode = parser.readBook(data, bookCode);

	visitor.readBook(rootNode);
}

var parser = new USXParser();
var files = fs.readdirSync(WEB_BIBLE_PATH);
var len = files.length;
len = 1;
for (var i=0; i<len; i++) {
	var file = files[i];
	test(file);
};

var concordance = visitor.concordance;
concordance.dumpAlphaSort();
console.log('after dump alpha sort');
//concordance.dumpFrequencySort();