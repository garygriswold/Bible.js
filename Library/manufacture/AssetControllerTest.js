/**
* Unit Test Harness for AssetController
*/
var types = new AssetType('document', 'WEB');
types.chapterFiles = true;
types.tableContents = true;
types.concordance = true;
types.styleIndex = true;
types.history = true;
types.questions = true;
var database = new DeviceDatabase(types.versionCode + '.word1');

var builder = new AssetBuilder(types, database);
builder.build(function(err) {
	if (err instanceof IOError) {
		window.alert('AssetController.build error=' + JSON.stringify(err));
	} else {
		console.log('AssetControllerTest.build', err);
	}
});
