/**
* The class controls the construction and loading of asset objects.  It is designed to be used
* one both the client and the server.  It is a "builder" controller that uses the AssetType
* as a "director" to control which assets are built.
*/
function AssetController(types, database) {
	this.types = types;
	this.database = database;
	this.checker = new AssetChecker(types);
	this.loader = new AssetLoader(types);
}
AssetController.prototype.tableContents = function() {
	return(this.loader.toc);
};
AssetController.prototype.concordance = function() {
	return(this.loader.concordance);
};
AssetController.prototype.history = function() {
	return(this.loader.history);
};
AssetController.prototype.styleIndex = function() {
	return(this.loader.styleIndex);
};
AssetController.prototype.build = function(callback) {
	var builder = new AssetBuilder(this.types, this.database);
	builder.build(function(err) {
		console.log('finished asset build');
		callback(err);
	});
};
AssetController.prototype.validate = function(callback) {
	// to be written for publisher and server
	callback(this.types);
};
AssetController.prototype.smokeTest = function(callback) {
	// to be written for device use
	callback(this.types);
};
/* deprecated */
AssetController.prototype.load = function(callback) {
	this.loader.load(function(loadedTypes) {
		console.log('finished assetcontroller load');
		callback(loadedTypes);
	});
};
