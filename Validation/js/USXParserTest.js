
var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/BibleApp Project/Bibles/USX/WEB World English Bible";
var OUT_BIBLE_PATH = "/Users/garygriswold/Desktop/BibleApp Project/Bibles/USX/WEB_USX_OUT";

var fs = require("fs");

function symmetricTest(filename) {
	var bookCode = filename.substring(3, 3);
	console.log(bookCode);
	var data = fs.readFileSync(WEB_BIBLE_PATH + '/' + filename, "utf8");
	var rootNode = parser.readBook(data);

	var data = rootNode.toUSX();
	fs.writeFileSync(OUT_BIBLE_PATH + '/' + filename, data, "utf8");
}

var parser = new USXParser();
var files = fs.readdirSync(WEB_BIBLE_PATH);
console.log(files);
var len = files.length;
len = 66;
for (var i=0; i<len; i++) {
	var file = files[i];
	symmetricTest(file);
};

//symmetricTest('049EPH.usx');
//symmetricTest('043JHN.usx');