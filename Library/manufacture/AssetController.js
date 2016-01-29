/**
* Unit Test Harness for AssetController
*/
var FILE_PATH = process.env.HOME + '/DBL/current/';
//var DB_PATH = process.env.HOME + '/DBL/
	
var readline = require('readline');
var io = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

io.question('Enter Version Code: ', function (version) {
	console.log('received', version);
	if (version.toUpperCase() === 'EXIT') {
		io.close();
		process.exit(-1);
	} else if (version && version.length > 2) {
		var types = new AssetType(FILE_PATH, version.toUpperCase());
		types.chapterFiles = true;
		types.tableContents = true;
		types.concordance = true;
		types.styleIndex = true;
		types.history = true;
		types.questions = true;
		types.statistics = true;
		var database = new DeviceDatabase(version.toUpperCase() + '.db1');
		
		var builder = new AssetBuilder(types, database);
		builder.build(function(err) {
			if (err instanceof IOError) {
				console.log('FAILED', JSON.stringify(err));
				io.close();
				process.exit();
			} else {
				console.log('Success, Database created');
				io.close();
			}
		});	
	}
});
