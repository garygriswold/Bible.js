/**
* This program does a series of checks of the S3 buckets that are configured to be part of the
* Bible App service.
*/
"use strict";
const REGIONS = require('../../../Library/cdn/Regions.js').REGIONS;
REGIONS['shortsands-na-va'] = '';

var S3 = require('aws-sdk/clients/s3');
console.log('REGIONS', REGIONS);
var verifyS3 = function() {
	console.log
	var awsOptions = {
		useDualstack: true,
		sslEnabled: true,
		s3ForcePathStyle: true,
		signatureVersion: 'v4'
	};
	var s3 = new S3(awsOptions); // Do I need to reset this for each region?
	var list = Object.keys(REGIONS);
	verify(list, function() {
		console.log('VERIFY COMPLETE');
	});
	
	function verify(list, callback) {
		var bucket = list.shift();
		if (bucket) {
			console.log('VALIDATING ', bucket);
			verifyLocation(bucket, function() {
				verifyLogging(bucket, function() {
					verifyContents(bucket, function() {
						verify(list, callback);
					});
				});
			});
		} else {
			callback();
		}
	};
	function verifyLocation(bucket, callback) {
		var region = REGIONS[bucket];
		s3.getBucketLocation({Bucket: bucket}, function(err, data) {
			if (err) {
				errorMessage(err, "VerifyS3.getBucketLocation");
			} else {
				if (region != data.LocationConstraint) {
					var message = "Bucket: " + bucket + " expected in region: " + region + " actually in region: " + data.LocationConstraint;
					errorMessage(null, message);
				}
				callback();
			}		
		});
	};
	function verifyLogging(bucket, callback) {
		s3.getBucketLogging({Bucket: bucket}, function(err, data) {
			if (err) {
				errorMessage(err, "VerifyS3.getBucketLogging");
			} else {
				if (data.LoggingEnabled) {
					if (data.LoggingEnabled.TargetBucket !== bucket + '-drop') {
						errorMessage(null, "Bucket: " + bucket + " does not have logging enabled to correct drop");
					}
				} else {
					errorMessage(null, "Bucket: " + bucket + " logging is not enabled");
				}
				//console.log('Logging', data);
				callback();
			}
		});
	};
	function verifyContents(bucket, callback) {
		s3.listObjectsV2({Bucket: bucket}, function(err, data) {
			if (err) {
				errorMessage(err, "VerifyS3.listObjects");
			} else {
				console.log('Object List Size', data.Contents.length);
				callback();
			}
		});
	};
	
	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error));
		process.exit(1);
	}
};

verifyS3();