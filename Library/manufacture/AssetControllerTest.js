/**
* Unit Test Harness for AssetController
*/
"use strict";

var types = new AssetType('test2application', 'WEB');
types.chapterFiles = true;
types.tableContents = true;
types.concordance = true;
types.styleIndex = true;
var controller = new AssetController();
controller.check(types, function(resultTypes) {
	console.log('AssetControllerTest.check ', resultTypes);
	
});
controller.build(types, function(whatever) {
	console.log('AssetControllerTest.build');
});

