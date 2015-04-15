"use strict"

var path = FILE_ROOTS.test2application + 'usx/WEB/';
var fs = require("fs");
var builder = new TOCBuilder();

function buildToc(filename) {
	var data = fs.readFileSync(path + filename, "utf8");
	var rootNode = parser.readBook(data);
	builder.readBook(rootNode);
}

var parser = new USXParser();
var files = fs.readdirSync(path);
var count = 0;
for (var i=0; i<files.length && count < 66; i++) {
	var file = files[i];
	if (file.indexOf('.usx') > 0) {
		count++;
		buildToc(files[i]);
	}
};

var toc = builder.toc.bookList;

var json = JSON.stringify(toc, null, ' ');
fs.writeFileSync(path + 'toc.json', json, 'utf-8');
