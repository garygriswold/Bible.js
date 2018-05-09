/**
* This program reads a flat file of S3 keys, and provides
* a summary of the keys by damId
*/

"use strict";
var fs = require('fs');

var summarizeKeys = function(callback) {
	
	var damIdMap = {};

	readTextFile("dbpdev_keys.txt", function(keys) {
		for (var i=0; i<keys.length; i++) {
			var key = keys[i];
			var parts = key.split('/');
			var damId = parts[0];
			if (parts.length > 1) {
				damId += "/" + parts[1];
			}
			if (parts.length > 3) {
				damId += "/" + parts[2];
			}
			var count = damIdMap[damId];
			if (count) {
				damIdMap[damId] = count + 1;
			} else {
				damIdMap[damId] = 1;
			}
		}
		var results = [];
		var lines = Object.keys(damIdMap);
		for (var j=0; j<lines.length; j++) {
			var line = lines[j];
			var count = damIdMap[line];
			results.push("\n" + line + ":" + count);
		}
		fs.writeFile("dbpdev_summary.txt", results, function(err) {
			if (err) {
				errorMessage(err, "WRITE FILE");
			}
		});
	});
					
	function readTextFile(filename, callback) {
		fs.readFile(filename, function(err, data) {
			if (err) {
				errorMessage(err, "READ FILE");
			} else {
				var array = data.toString().split("\n");
				console.log("NUM: ", array.length);
				callback(array);
			}
		});		
	}
	
	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error.message));
		process.exit(1);
	}				
}

summarizeKeys(function() {
	console.log('DONE WITH SUMMARIZE KEYS');
});