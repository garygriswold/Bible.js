
var WEB_BIBLE_PATH = "../../DBL/2current/";
var OUT_BIBLE_PATH = "output/";

var fs = require("fs");

function testOne(fullPath, files, index, callback) {
	if (index >= files.length) {
		callback();
	} else {
		var file = files[index];
		symmetricTest(fullPath, file);
		testOne(fullPath, files, index + 1, callback);
	}
}
function symmetricTest(fullPath, filename) {
	var bookCode = filename.substring(0, 3);
	console.log(bookCode, filename);
	try {
		var inFile = fullPath + filename;
		var data = fs.readFileSync(inFile, "utf8");
		var rootNode = parser.readBook(data);
	
		var data = rootNode.toUSX();
		var outFile = OUT_BIBLE_PATH + filename;
		fs.writeFileSync(outFile, data, "utf8");
		
		const proc = require('child_process');
		var output = proc.execSync('diff -w ' + inFile + ' ' + outFile, { stdio: 'inherit', encoding: 'utf8' });
	} catch(err) {
		console.log('ERROR', JSON.stringify(err));
	}
}

if (process.argv.length < 3) {
	console.log('Usage: USXParserTest.sh  version');
	process.exit(1);
}
var parser = new USXParser();
var fullPath = WEB_BIBLE_PATH + process.argv[2] + '/USX_1/';
var files = fs.readdirSync(fullPath);
testOne(fullPath, files, 0, function() {
	console.log('USXParserTest DONE');
});
