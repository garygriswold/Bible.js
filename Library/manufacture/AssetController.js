/**
* Unit Test Harness for AssetController
*/
var FILE_PATH = process.env.HOME + '/DBL/current/';

var versionNode = document.getElementById('versionNode');
var responseNode = document.getElementById('responseNode');
var submitBtn = document.getElementById('submitBtn');
submitBtn.addEventListener('click', function(event) {
	
	responseNode.textContent = '';
	var versionCode = versionNode.value.toUpperCase();

	console.log('received', versionCode);
	if (versionCode.toUpperCase() === 'EXIT') {
		read.close();
		process.exit();
	} else if (versionCode && versionCode.length > 2) {
		var types = new AssetType(FILE_PATH, versionCode);
		types.chapterFiles = true;
		types.tableContents = true;
		types.concordance = true;
		types.styleIndex = true;
		types.history = true;
		types.questions = true;
		types.statistics = true;
		var database = new DeviceDatabase(versionCode + '.db1');
		
		var builder = new AssetBuilder(types, database);
		builder.build(function(err) {
			if (err instanceof IOError) {
				console.log('FAILED', JSON.stringify(err));
				process.exit();
			} else {
				responseNode.textContent = 'Success, Database created';
			}
		});	
	}
});
