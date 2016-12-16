/**
* This program will upload a Bible file in zip form to each of the S3 servers that it is configured to send.
* It will also check that logging is set up for each of the buckets as well.
*
* NOTE: performance of this program could be improved by uploading to one bucket and copying to all the others.
*/
"use strict";
const REGIONS = require('../../../Library/cdn/Regions.js').REGIONS;
const FILE_PATH = "../../DBL/5ready/";
const S3 = require('aws-sdk/clients/s3');
const fs = require('fs');


var uploadBible = function(version) {
	var awsOptions = {
		useDualstack: true,
		sslEnabled: true,
		s3ForcePathStyle: true,
		signatureVersion: 'v4'
	};
	var s3 = new S3(awsOptions);
	
	var filename = version + '.db.zip';
	fs.readFile(FILE_PATH + filename, function(err, content) {
		if (err) {
			errorMessage(err, "UploadBible.readFile");
		} else {
			var list = Object.keys(REGIONS);
			upload(list, content, function() {
				console.log(version + ' UPLOAD COMPLETE');
			});
		}
	});
	
	function upload(list, content, callback) {
		var bucket = list.shift();
		if (bucket) {
			console.log('Upload Object to ', bucket);
			s3.putObject({Bucket: bucket, Key: filename, Body: content, ContentType: 'application/zip'}, function(err, data) {
				if (err) {
					errorMessage(err, "UploadBible.upload");
				} else {
					upload(list, content, callback);
				}
			});					
		} else {
			callback();
		}
	}
	
	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error));
		process.exit(1);
	}
};

if (process.argv.length < 3) {
	console.log('Usage: ./UploadBible.sh VERSION');
	process.exit(1);
} else {
	uploadBible(process.argv[2]);
}