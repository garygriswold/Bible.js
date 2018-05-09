/**
* This program provides a list of all damId's that are found, so that it can be
* compared to what I should be able to see.  i.e. so that permissions can be
* verified.
*/


"use strict";
var fs = require('fs');
var AWS = require('aws-sdk');
var cred = require('./Credentials.js');
var MAX_KEYS = 1000

var logger = fs.createWriteStream('audit.txt');

var readKeys = function(callback) {
	
	AWS.config.update({
		accessKeyId: cred.AWS_KEY_ID, 
		secretAccessKey: cred.AWS_SECRET, 
		region: 'us-west-2'
	});
	var s3 = new AWS.S3();
	console.log("USER " + cred.AWS_KEY_ID);
	console.log("PASS " + cred.AWS_SECRET);
	
	list1000Objects('', function() {
		console.log('DONE WITH OUTPUT');
	});
	
	function list1000Objects(prefix, callback) {
	
		var params = { 
			Bucket: 'dbp-dev',
			MaxKeys: MAX_KEYS,
			Marker: prefix
		}
	
		s3.listObjects(params, function (err, results) {
			if (err) {
				errorMessage(err, "LIST OBJECTS");
			} else {
				var contents = results.Contents;
				for (var i=0; i<contents.length; i++) {
					var row = contents[i];
					var key = row.Key;
					console.log("KEY ", key);
					logger.write(key);
					logger.write("\n");
					//logger.flush();
					//var parts = key.split('/');
					//var damId = parts[0];
					//if (parts.length > 1) {
					//	damId += "/" + parts[1];
					//}
					//if (parts.length > 3) {
					//	damId += "/" + parts[2];
					//}
					//var count = damIdMap[damId];
					//if (count) {
					//	damIdMap[damId] = count + 1;
					//} else {
					//	damIdMap[damId] = 1;
					//}
				}
				if (results.IsTruncated == true) {
					list1000Objects(key, callback);
				} else {
					callback();
				}
			}
		});
	}

	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error.message));
		process.exit(1);
	}
};


readKeys(function() {
	console.log('DONE WITH PERMISSION AUDIT');
});