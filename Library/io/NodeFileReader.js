/**
* This class is a file reader for Node.  It can be used with node.js and node-webkit.
* cordova requires using another class, but the interface should be the same.
*/
"use strict";

function NodeFileReader(location) {
	this.fs = require('fs');
	this.location = location;
	Object.freeze(this);
};
NodeFileReader.prototype.fileExists = function(filepath) {
	// to be written.
	return(false);
}
NodeFileReader.prototype.readDirectory = function(filepath, successCallback, failureCallback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	console.log('read directory ', fullPath);
	this.fs.readdir(fullPath, function(err, data) {
		if (err) {
			err.filepath = filepath;
			failureCallback(err);
		} else {
			successCallback(data);
		}
	});
};
NodeFileReader.prototype.readTextFile = function(filepath, successCallback, failureCallback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	console.log('read file ', fullPath);
	this.fs.readFile(fullPath, { encoding: 'utf-8'}, function(err, data) {
		if (err) {
			failureCallback(err);
		} else {
			successCallback(data);
		}
	});
};