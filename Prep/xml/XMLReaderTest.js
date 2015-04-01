/**
* This file is the unit test of XMLReader
*/
"use strict";

var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB World English Bible";
var OUT_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB_XML_OUT";

function symmetricTest(filename) {
	var reader = new XMLReader(WEB_BIBLE_PATH + "/" + filename);
	var writer = new XMLWriter(OUT_BIBLE_PATH + "/" + filename);
	var count = 0;
	var type;
	while (type !== XMLNodeType.END && count < 770000) {
		type = reader.nextToken();
		var value = reader.tokenValue();
		//console.log('type=|' + type + '|  value=|' + value + '|');
		writer.write(type, value);
		count++;
	};
	writer.close();
}
var fs = require("fs");
var files = fs.readdirSync(WEB_BIBLE_PATH);
var len = files.length;
for (var i=0; i<len; i++) {
	var file = files[i];
	symmetricTest(file);
};