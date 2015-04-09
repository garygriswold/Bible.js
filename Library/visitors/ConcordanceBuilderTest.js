"use strict"

var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB World English Bible";
var fs = require("fs");
var builder = new ConcordanceBuilder();

function test(filename) {
	var bookCode = filename.substring(3, 3);
	console.log(bookCode);
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

var concordance = builder.concordance;
//concordance.dumpAlphaSort();

concordance.dumpFrequencySort();
console.log('after dump alpha sort');

var json = JSON.stringify(concordance, null, ' ');
fs.writeFileSync('/Users/garygriswold/Desktop/concordance.json', json, 'utf-8');