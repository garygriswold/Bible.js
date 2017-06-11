/**
* This class handles the task of downloading all Bible download logs, video analytics
* and audio analytics.  It updates the correct tables with this data, and deletes
* the S3 objects downloaded once the update is complete.
* Any error in processing will stop the process immediately.
*/
"use strict";
var downloadController = function(callback) {

	var S3Download = require('./S3Download.js');
	var Sqlite = require('./Sqlite.js');
	var InsertDownloadLogs = require('./InsertDownloadLogs.js');
	var InsertVideoViews = require('./InsertVideoViews.js');

	
	var database = new Sqlite('Analytics.db', true);
	var insertLogs = new InsertDownloadLogs(database);
	var insertVideo = new InsertVideoViews(database);
	
	const cdnBuckets = require('../../../Library/cdn/Regions.js').REGIONS;
	var bucketList = Object.keys(cdnBuckets);
	var REGIONS = {};
	for (var i=0; i<bucketList.length; i++) {
		var bkt = bucketList[i];
		REGIONS[bkt + '-log'] = cdnBuckets[bkt];
	}
	REGIONS['shortsands-log'] = 'us-west-2';
	REGIONS['analytics-us-east-1-shortsands'] = 'us-east-1';
	
	var s3Download = new S3Download(REGIONS);

	s3Download.begin(function(count) {
		doNext();
	});
	
	function doNext() {
		s3Download.nextObject(function(s3Object) {
			if (s3Object != null) {
				console.log("ENTRY " + s3Object);
				var prefix = s3Object.substr(0, 12);
				if (prefix.indexOf("Video") < 0 && prefix.indexOf("Audio") < 0) {
					insertLogs.insert(s3Object, function() {
						finish();
					});					
				} else {
					var jsonObject = null;
					try {
						jsonObject = JSON.parse(s3Object);
					} catch(jsonError) {
						errorMessage(jsonErr, "DownloadController.JSON.parse()");
					}	
					if (jsonObject.VideoBegV1) {
						insertVideo.insert(jsonObject.VideoBegV1, function() {
							finish();
						});						
					}
					else if (jsonObject.VideoEndV1) {
						insertVideo.update(jsonObject.VideoEndV1, function() {
							finish();
						});
					} else {
						errorMessage("DownloadController.doNext", "unknown record type " + s3Object);
					}
				}
			} else {
				database.close();
				callback();
			}
		});
	}
	
	function finish() {
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
	console.log('DONE WITH DOWNLOAD');
});