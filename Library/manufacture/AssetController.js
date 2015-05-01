/**
* The class controls the construction and loading of asset objects.  It is designed to be used
* one both the client and the server.  It is a "builder" controller that uses the AssetType
* as a "director" to control which assets are built.
*/
"use strict";

function AssetController(types) {
	this.types = types;
	this.checker = new AssetChecker(types);
	this.loader = new AssetLoader(types);
};
AssetController.prototype.tableContents = function() {
	return(this.loader.toc);
};
AssetController.prototype.concordance = function() {
	return(this.loader.concordance);
}
AssetController.prototype.styleIndex = function() {
	return(this.loader.styleIndex);
}
AssetController.prototype.checkBuildLoad = function(callback) {
	var that = this;
	this.checker.check(function(absentTypes) {
		var builder = new AssetBuilder(absentTypes);
		builder.build(function() {
			that.loader.load(function(loadedTypes) {
				callback(loadedTypes)
			});
		});
	});
};
AssetController.prototype.check = function(callback) {
	this.checker.check(function(absentTypes) {
		console.log('finished to be built types', absentTypes);
		callback(absentTypes);
	});
};
AssetController.prototype.build = function(callback) {
	var builder = new AssetBuilder(this.types);
	builder.build(function() {
		console.log('finished asset build');
		callback();
	});
};
AssetController.prototype.load = function(callback) {
	this.loader.load(function(loadedTypes) {
		console.log('finished assetcontroller load');
		callback(loadedTypes);
	});
};
