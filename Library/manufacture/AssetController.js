/**
* The class controls the construction and loading of asset objects.  It is designed to be used
* one both the client and the server.  It is a "builder" controller that uses the AssetType
* as a "director" to control which assets are built.
*
* Deprecated.  This should be removed, and just use builder in Publisher and
* validate in Publisher and smokeTest in BibleApp.
* Remove after testing removal in Publisher.  It is not used in BibleAppNW
*/
function AssetController(types, database) {
	this.types = types;
	this.database = database;
}
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
