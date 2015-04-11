/**
* This class is a file reader for Node.  It can be used with node.js and node-webkit.
* cordova requires using another class, but the interface should be the same.
*/
"use strict";

var FILE_ROOTS = { 'application': '', 'document': '?', 'temporary': '?' };

function NodeFileReader() {
	this.fs = require('fs');
	Object.freeze(this);
};
NodeFileReader.prototype.readTextFile = function(location, filepath, successCallback, failureCallback) {
	var fullPath = FILE_ROOTS[location] + filepath;
	console.log('fullpath ', fullPath);
	this.fs.readFile(fullPath, { encoding: 'utf-8'}, function(err, data) {
		if (err) {
			failureCallback(err);
		} else {
			successCallback(data);
		}
	});
};