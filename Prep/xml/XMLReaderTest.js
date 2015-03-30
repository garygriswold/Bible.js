/**
* This file is the unit test of XMLReader
*/
"use strict";
var fs = require("fs");
var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB World English Bible";
var BOOK_PATH = "043JHN.usx";
var data = fs.readFileSync(WEB_BIBLE_PATH + "/" + BOOK_PATH, "utf8");
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
console.log(writer.close());