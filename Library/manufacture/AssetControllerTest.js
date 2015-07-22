/**
* Unit Test Harness for AssetController
*/
var types = new AssetType('document', 'WEB');
types.chapterFiles = true;
types.verseFiles = false;
types.tableContents = false;
types.concordance = false;
types.styleIndex = false;
types.history = false;
types.questions = false;
var database = new DeviceDatabase(types.versionCode + '.word1');

var builder = new AssetBuilder(types, database);
builder.build(function(err) {
	if (err instanceof IOError) {
		window.alert('AssetController.build error=' + JSON.stringify(err));
	} else {
		console.log('AssetControllerTest.build', err);
	}
});
