/**
* Unit Test Harness for AssetController
*/
var types = new AssetType('document', 'WEB');
types.chapterFiles = false;
types.tableContents = true;
types.concordance = true;
types.styleIndex = false;
var database = new DeviceDatabase(types.versionCode, 'versionNameHere');

var controller = new AssetController(types, database);
controller.build(function(err) {
	console.log('AssetControllerTest.build', err);
});



