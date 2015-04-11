/**
* This class is a file writer for Node.  It can be used with node.js and node-webkit.
* cordova requires using another class, but the interface should be the same.
*/
"use strict";

function NodeFileWriter() {
	this.fs = require('fs');
	Object.freeze(this);
};
NodeFileWriter.prototype.writeTextFile = function(location, filepath, data, successCallback, failureCallback) {
	var fullPath = FILE_ROOTS[location] + filepath;
	var options = { encoding: 'utf-8'};
	this.fs.writeFile(fullPath, data, options, function(err) {
		if (err) {
			failureCallback(err);
		} else {
			successCallback();
		}
	});
};