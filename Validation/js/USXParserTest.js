
var WEB_BIBLE_PATH = "../../DBL/2current/";
var OUT_BIBLE_PATH = "output/";

var fs = require("fs");

function testOne(fullPath, files, index, callback) {
	if (index >= files.length) {
		callback();
	} else {
		var file = files[index];
		symmetricTest(fullPath, file, function() {
			testOne(fullPath, files, index + 1, callback);			
		});
	}
}
function symmetricTest(fullPath, filename, callback) {
	if (filename.substr(0, 1) === '.') {
		callback();
	} else {
		var bookCode = filename.substring(0, 3);
		console.log(bookCode, filename);
		var inFile = fullPath + filename;
		fs.readFile(inFile, { encoding: 'utf8'}, function(err, data) {
			if (err) {
				console.log('READ ERROR', JSON.stringify(err));
				process.exit(1);
			}
			var rootNode = parser.readBook(data);
			var data = rootNode.toUSX();
			var outFile = OUT_BIBLE_PATH + filename;
			fs.writeFile(outFile, data, { encoding: 'utf8'}, function(err) {
				if (err) {
					console.log('WRITE ERROR', JSON.stringify(err));
					process.exit(1);
				}
				var proc = require('child_process');
				proc.exec('diff -w ' + inFile + ' ' + outFile, { encoding: 'utf8' }, function(err, stdout, stderr) {
					//if (err) {
					//	console.log('Diff Error', JSON.stringify(err));
					//}
					console.log('DIFF', stdout);
					callback();
				});
			});
		});
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
