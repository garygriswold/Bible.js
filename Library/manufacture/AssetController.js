/**
* The class controls the construction and loading of asset objects.  It is designed to be used
* one both the client and the server.  It is a building controller that uses the AssetType
* as a director to control which assets are built.
*/
"use strict";

function AssetController() {

};
AssetController.prototype.check = function(types, callback) {
	var checker = new AssetChecker(types);
	checker.check(function(resultTypes) {
		console.log('finished to be built types', resultTypes);
		callback(resultTypes);
	});
};
AssetController.prototype.build = function(types, callback) {
	var builder = new AssetBuilder(types);
	builder.build(function(resultTypes) {
		console.log('');
		callback(resultTypes);
	});
};
AssetController.prototype.load = function(types) {

};
