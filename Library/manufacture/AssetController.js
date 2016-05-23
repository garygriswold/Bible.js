/**
* Unit Test Harness for AssetController
*/
var FILE_PATH = process.env.HOME + '/ShortSands/DBL/2current/';
var DB_PATH = process.env.HOME + '/ShortSands/DBL/3prepared/';
	
if (process.argv.length < 3) {
	console.log('Usage: ./Publisher.sh VERSION');
	process.exit(1);
} else {
	var version = process.argv[2];
	console.log('received', version);
	if (version && version.length > 2) {
		var types = new AssetType(FILE_PATH, version.toUpperCase());
		types.chapterFiles = true;
		types.tableContents = true;
		types.concordance = true;
		types.styleIndex = true;
		types.statistics = true;
		var database = new DeviceDatabase(DB_PATH + version.toUpperCase() + '.db');
		
		var builder = new AssetBuilder(types, database);
		builder.build(function(err) {
			if (err instanceof IOError) {
				console.log('FAILED', JSON.stringify(err));
				process.exit(1);
			} else {
				console.log('Success, Database created');
			}
		});	
	}
}

