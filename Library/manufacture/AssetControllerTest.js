/**
* Unit Test Harness for AssetController
*/
"use strict";

var types = new AssetType('test2application', 'WEB');
types.chapterFiles = true;
types.tableContents = true;
types.concordance = true;
types.styleIndex = true;
var controller = new AssetController(types);

controller.checkBuildLoad(function(loadedTypes) {
	console.log('AssetControllerTest.load', loadedTypes);
	console.log('TOC', controller.tableContents().size());
	console.log('Concordance', controller.concordance().size());
	console.log('StyleIndex', controller.styleIndex().size());
});

//controller.check(function(resultTypes) {
//	console.log('AssetControllerTest.check ', resultTypes);	
//});

//controller.build(function(whatever) {
//	console.log('AssetControllerTest.build');
//});

//controller.load(function(loadedTypes) {
//	console.log('AssetControllerTest.load', loadedTypes);
//	console.log('TOC', controller.tableContents().size());
//	console.log('Concordance', controller.concordance().size());
//	console.log('StyleIndex', controller.styleIndex().size());
//});


