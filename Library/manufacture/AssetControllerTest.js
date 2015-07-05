/**
* Unit Test Harness for AssetController
*/
var types = new AssetType('document', 'WEB');
types.chapterFiles = false;
types.tableContents = false;
types.concordance = false;
types.styleIndex = false;
types.history = false;
types.questions = true;
var database = new DeviceDatabase(types.versionCode, 'versionNameHere');

var controller = new AssetController(types, database);
controller.build(function(err) {
	console.log('AssetControllerTest.build', err);
});



