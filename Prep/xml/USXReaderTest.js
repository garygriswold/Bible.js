
var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB World English Bible";
var OUT_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB_USX_OUT";
//var reader = new USXReader(WEB_BIBLE_PATH);
//reader.readAll();
//reader.readBook('049EPH.usx', 'EPH');
//reader.readBook('043JHN.usx', 'JHN');
var fs = require("fs");

function symmetricTest(filename) {
	var reader = new USXReader(WEB_BIBLE_PATH);
	var bookCode = filename.substring(3, 3);
	var rootNode = reader.readBook(filename, bookCode);

	var result = [];
	console.log('before to USX');
	result.push(rootNode.toUSX());
	console.log('after to USX');
	var data = result.join('');
	fs.writeFileSync(OUT_BIBLE_PATH + '/' + filename, data, "utf8");
}

var files = fs.readdirSync(WEB_BIBLE_PATH);
console.log(files);
var len = files.length;
for (var i=0; i<len; i++) {
	var file = files[i];
	symmetricTest(file);
};