/**
* This program validates that all of the audio files that are referenced in the meta data
* do exist in AWS S3 buckets.  To use this program, first run the OSX Swift program
* ValidateAudio, which generates a list of keys and buckets based upon the metadata.
* That program places its output in the Download directory.
*
* This program reads the file of bucket names and keys and performs a HEAD of each object
* to insure that it exists.  GNG Feb 22, 2018
*/

"use strict";
var fs = require('fs');
var S3 = require('aws-sdk/clients/s3');

var validateAudio = function(callback) {
	
	var INPUT_FILE = process.env.HOME + "/Downloads/test.txt";
	var BUCKET_SUFFIX = ".shortsands.com";
	
	var awsOptions = {
		//useDualstack: true,
		sslEnabled: true,
		s3ForcePathStyle: true,
		signatureVersion: 'v4'
	};
	var s3 = new S3(awsOptions);
	//var database = new Sqlite(VERSIONS_DB, false);
	
	fs.readFile(INPUT_FILE, function(err, content) {
		if (err) {
			errorMessage(err, "READ INPUT FILE");
		} else {
			var array = content.toString().split("\n");
			console.log("ARRAY LEN " + array.length);
			doObjectHeads(0, array, function() {
				callback()
			});
		}
	});
	
	function doObjectHeads(index, array, callback) {
		console.log("LEN " + index);
		if (index < array.length) {
			var item = array[index++];
			var parts = item.split("|");
			getObjectHead(parts[0] + BUCKET_SUFFIX, parts[1]);
			doObjectHeads(index, array, callback);
		} else {
			callback();
		}
	};
	
	function getObjectHead(bucket, key) {
		var params = {
			Bucket: bucket, 
			Key: key
 		};
 		s3.headObject(params, function(err, data) {
 			if (err) {
	 			console.log("NOT FOUND " + bucket + "/" + key + "  " + err);
	 		} else {
		 		console.log("FOUND " + bucket + "/" + key);
		 	}
		});
	}

	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error.message));
		process.exit(1);
	}
};



validateAudio(function() {
	console.log('DONE WITH VALIDATE AUDIO');
});