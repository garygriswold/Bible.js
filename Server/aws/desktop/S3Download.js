/**
* This class is used to list objects in an S3 bucket, download them, and return the
* contents of each file for processing.
* It also includes a delete method to delete the object after its processing is complete.
*/
"use strict";
var S3 = require('aws-sdk/clients/s3');

function S3Download(bucketMap) {
	this.bucketMap = bucketMap
	var awsOptions = {
		useDualstack: true,
		sslEnabled: true,
		s3ForcePathStyle: true,
		signatureVersion: 'v4'
	};
	this.s3 = new S3(awsOptions);
	this.itemList = [];
	this.itemListIndex = -1;
	Object.seal(this);
}

S3Download.prototype.begin = function(callback) { // callback returns length of itemList
	var that = this;
	var bucketList = Object.keys(this.bucketMap);
	doBuckets(bucketList, callback);
	
	function doBuckets(bucketList, callback) {
		var bucket = bucketList.shift();
		if (bucket) {
			that.s3.listObjects({Bucket: bucket}, function(err, data) {
				if (err) {
					that.errorMessage(err, "S3DownloadS3.readBucketList");
				} else {
					var entries = data.Contents;
					for (var i=0; i<entries.length; i++) {
						var item = entries[i];
						console.log('ENTRY', bucket, item.Key);
						that.itemList.push({Bucket: bucket, Key: item.Key});
					}
					doBuckets(bucketList, callback);
				}
			});				
		} else {
			callback(that.itemList.length);
		}
	}
};

S3Download.prototype.nextObject = function(callback) {
	var that = this;
	this.itemListIndex += 1;
	if (this.itemListIndex < this.itemList.length) {
		var item = this.itemList[this.itemListIndex];
		console.log('GET OBJECT ', item.Bucket, item.Key);
		this.s3.getObject(item, function(err, data) {
			if (err) {
				that.errorMessage(err, "DownloadS3Logs.getLogFromS3");
			} else {
				callback(String(data.Body));
			}
		});
	} else {
		callback();
	}
};

S3Download.prototype.deleteObject = function(callback) {
	var that = this;
	var item = this.itemList[this.itemListIndex];
	console.log('DELETE OBJECT ', item.Bucket, item.Key);
	//this.s3.deleteObject(item, function(err, data) {
	//	if (err) {
	//		that.errorMessage(err, "S3Download.delete");
	//	} else {
			callback();
	//	}
	//});	
};

S3Download.prototype.errorMessage = function(error, message) {
	console.log('ERROR', message, JSON.stringify(error));
	process.exit(1);	
};

module.exports = S3Download;

/*
// Unit Test
var REGIONS = {
//	"shortsands-as-jp-log": "ap-northeast-1", 	// Tokoyo
//	"shortsands-as-sg-log": "ap-southeast-1",	// Singapore
	"shortsands-eu-ie-log": "eu-west-1"//,		// Ireland
//	"shortsands-na-va-log": "us-east-1",		// Virginia
//	"shortsands-oc-au-log": "ap-southeast-2"	// Sydney
};


var download = new S3Download(REGIONS);
download.begin(function(count) {
	console.log("COUNT " + count);
	console.log("COUNT2 " + download.itemList.length);
	console.log("FIRST " + JSON.stringify(download.itemList[0]));
	doNext();
	
	function doNext() {
		download.nextObject(function(entry) {
			if (entry != null) {
				console.log("ENTRY " + entry);
				// do my things here
				download.deleteObject(function() {
					doNext();
				});
			} else {
				// do closeing things here
			}
		});
	}
});

*/
