
var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB World English Bible";
var OUT_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB_USX_OUT";
//var reader = new USXReader(WEB_BIBLE_PATH);
//reader.readAll();
//reader.readBook('049EPH.usx', 'EPH');
//reader.readBook('043JHN.usx', 'JHN');
var fs = require("fs");

function symmetricTest(filename) {
	var reader = new USXReader();
	var bookCode = filename.substring(3, 3);
	var data = fs.readFileSync(WEB_BIBLE_PATH + '/' + filename, "utf8");
	var rootNode = reader.readBook(data, bookCode);

	var data = rootNode.toUSX();
	fs.writeFileSync(OUT_BIBLE_PATH + '/' + filename, data, "utf8");
}

var files = fs.readdirSync(WEB_BIBLE_PATH);
console.log(files);
var len = files.length;
for (var i=0; i<len; i++) {
	var file = files[i];
	symmetricTest(file);
};