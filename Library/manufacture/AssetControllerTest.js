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
var database = new DeviceDatabase(types.versionCode, 'versionNameHere');

var builder = new AssetBuilder(types, database);
builder.build(function(err) {
	console.log('AssetControllerTest.build', err);
});
