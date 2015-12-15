/**
* This class is a file writer for Node.  It can be used with node.js and node-webkit.
* cordova requires using another class, but the interface should be the same.
*/
function FileWriter(location) {
	this.fs = require('fs');
	this.location = location;
	Object.freeze(this);
}
FileWriter.prototype.createDirectory = function(filepath, callback) {
	var fullPath = this.location + filepath;
	this.fs.mkdir(fullPath, function(err) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(filepath);
		}
	});
};
FileWriter.prototype.writeTextFile = function(filepath, data, callback) {
	var fullPath = this.location + filepath;
	this.fs.writeFile(fullPath, data, { encoding: 'utf8'}, function(err) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(filepath);
		}
	});
};