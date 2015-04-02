/**
* This file is the unit test of XMLReader
*/
"use strict";

var fs = require("fs");
var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB World English Bible";
var OUT_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB_XML_OUT";

function symmetricTest(filename) {
	var inFile = WEB_BIBLE_PATH + "/" + filename;
	var data = fs.readFileSync(inFile, "utf8");
	var reader = new XMLReader(data);
	var writer = new XMLWriter();
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