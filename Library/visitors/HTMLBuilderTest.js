/**
* The HTMLBuilderTest parses a book of the Bible and outputs an HTML document of that book.
*
* This test does not work with the current HTMLBuilder
*/
var WEB_BIBLE_PATH = "/Users/garygriswold/Desktop/BibleApp Project/Bibles/USX/WEB World English Bible";
//var OUT_BIBLE_PATH = "/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB_HTML_OUT";
var OUT_BIBLE_PATH = "/Users/garygriswold/BibleApp/UnitTestCSS1/www/html";

var fs = require("fs");

function test(filename) {
	var reader = new USXParser();
	var bookCode = filename.substring(3, 3);
	var data = fs.readFileSync(WEB_BIBLE_PATH + '/' + filename, "utf8");
	var rootNode = reader.readBook(data, bookCode);

	var data = rootNode.toHTML();
	fs.writeFileSync(OUT_BIBLE_PATH + '/' + filename.substring(0,6) + '.html', data, "utf8");
}

var files = fs.readdirSync(WEB_BIBLE_PATH);
console.log(files);
var len = files.length;
len = 66;
for (var i=0; i<len; i++) {
	var file = files[i];
	test(file);
};
test('100FRT.usx');
test('109GLO.usx');
