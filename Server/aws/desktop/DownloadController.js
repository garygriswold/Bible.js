

"use strict";
var downloadController = function(callback) {

	var Sqlite = require('./Sqlite.js');
	var InsertDownloadLogs = require('./InsertDownloadLogs.js');
	var S3Download = require('./S3Download.js');
	
	var database = new Sqlite('TestAnalyticsNew.db', true);
	var insertLogs = new InsertDownloadLogs(database);
	
	const cdnBuckets = require('../../../Library/cdn/Regions.js').REGIONS;
	var bucketList = Object.keys(cdnBuckets);
	var REGIONS = {};
	for (var i=0; i<bucketList.length; i++) {
		var bkt = bucketList[i];
		REGIONS[bkt + '-log'] = cdnBuckets[bkt];
	}
	REGIONS['shortsands-log'] = 'us-west-2';
	
	var s3Download = new S3Download(REGIONS);

	s3Download.begin(function(count) {
		doNext();
	});
	
	function doNext() {
		s3Download.nextObject(function(s3Object) {
			if (s3Object != null) {
				console.log("ENTRY " + s3Object);
				var s3Obj = s3Object.trim();
				if (s3Obj.charAt(0) == "{") {
					insertLogs.insert(s3Obj, function() {
						finishNext();
					});
				} else if (s3Obj.substr(0, 10) == "VideoBegV1") {
					console.log("VideoBegV1 being processed");
					errorMessage("DownloadController.doNext", "unknown record type " + s3Obj);
				} else if (s3Obj.substr(0, 10) == "VideoEndV1") {
					console.log("VideoEndV1 being processed");
					errorMessage("DownloadController.doNext", "unknown record type " + s3Obj);
				} else {
					errorMessage("DownloadController.doNext", "unknown record type " + s3Obj);
				}
			} else {
				database.close();
				callback();
			}
		});
	}
	
	function finishNext() {
		s3Download.deleteObject(function() {
			doNext();
		});
	}
	
	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error));
		process.exit(1);
	}
};

downloadController(function() {
	console.log('DOWN WITH DOWNLOAD');
});