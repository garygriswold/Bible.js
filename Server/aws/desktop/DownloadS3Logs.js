/**
* This program downloads AWS S3 logs from shortsands-log and inserts them into a sqlite3
* database.  This database can then be used to provide statistics about the downloads 
* of Bibles by the App.
*/
"use strict";
const cdnBuckets = require('../../../Library/cdn/Regions.js').REGIONS;
var bucketList = Object.keys(cdnBuckets);
var REGIONS = {};
for (var i=0; i<bucketList.length; i++) {
	var bkt = bucketList[i];
	REGIONS[bkt + '-log'] = cdnBuckets[bkt];
}
REGIONS['shortsands-log'] = 'us-west-2';
console.log('REGIONS', REGIONS);

const DATABASE = './TestAnalyticsBaseline.db';
const DB_VERBOSE = false;
const MONTHS = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ];

var S3 = require('aws-sdk/clients/s3');

var downloadS3Logs = function() {
	var awsOptions = {
		useDualstack: true,
		sslEnabled: true,
		s3ForcePathStyle: true,
		signatureVersion: 'v4'
	};
	var s3 = new S3(awsOptions);
	openDatabase(function(database) {
		var regions = Object.keys(REGIONS);
		doRegions(regions, database, function() {
			console.log('FINISHED');
		});
	});		
	
	function doRegions(regions, database, callback) {
		var bucket = regions.shift();
		if (bucket) {
			readBucketList(s3, bucket, function(logEntries) {
				iterateList(s3, bucket, database, logEntries.Contents, function() {
					doRegions(regions, database, callback);
				});
			});				
		} else {
			closeDatabase(database, function() {
				callback();
			});
		}	
	}

	function openDatabase(callback) {
		var sqlite3 = (DB_VERBOSE) ? require('sqlite3').verbose() : require('sqlite3');
		var database = new sqlite3.Database(DATABASE);
		if (DB_VERBOSE) {
			database.on('trace', function(sql) {
				console.log('DO ', sql);
			});
			database.on('profile', function(sql, ms) {
				console.log(ms, 'DONE', sql);
			});
		}
		database.run("PRAGMA foreign_keys = ON");
		callback(database);
	};
	function closeDatabase(database, callback) {
		database.close(function(err) {
			if (err) {
				errorMessage(err, "DownloadS3Logs.closeDatabase");
			} else {
				console.log('Database closed');
				callback();
			}
		});
	};
	function readBucketList(s3, bucket, callback) {
		s3.listObjects({Bucket: bucket}, function(err, data) {
			if (err) {
				errorMessage(err, "DownloadS3Logs.readBucketList");
			} else {
				//console.log(data);
				callback(data);
			}
		});
	};
	function iterateList(s3, bucket, database, list, callback) {
		var item = list.shift();
		if (item) {
			getLogFromS3(s3, bucket, item, function(logFile) {
				insertIntoDatabase(database, logFile, function() {
					deleteFromS3(s3, bucket, item, function() {
						iterateList(s3, bucket, database, list, callback);
					});
				});				
			});
		} else {
			callback();
		}
	};
	function getLogFromS3(s3, bucket, item, callback) {
		console.log('GET OBJECT ', item.Key);
		s3.getObject({Bucket: bucket, Key: item.Key}, function(err, data) {
			if (err) {
				errorMessage(err, "DownloadS3Logs.getLogFromS3");
			} else {
				callback(String(data.Body));
			}
		});
	};
	function insertIntoDatabase(database, logFile, callback) {
		console.log('111READ FILE', logFile);
		var statement = 'INSERT INTO BibleDownload (' +
			' requestid,' +
			' bucket,' +
			' datetime,' +
			' userid,' +
			' operation,' +
			' filename,' +
			' httpStatus,' +
			' prefLocale,' +
			' locale,' +
			' error,' + 
			' tranSize,' + 
			' fileSize,' + 
			' totalms,' + 
			' s3ms,' + 
			' userAgent) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
		database.run('BEGIN TRANSACTION', function(err) {
			if (err) {
				errorMessage(err, 'DownloadS3Logs.BEGIN_TRAN');
			} else {
				var records = logFile.split('\n');
				insertRecords(database, statement, records, function() {
					callback();
				});
			}
		});
	};
	function insertRecords(database, statement, records, callback) {
		var record = records.shift();
		console.log('RECORD', record);
		if (record) {
			var log = JSON.parse(record.trim());
			var datetimeISO = parseDatetime(log.datetime);
			var row = [ log.requestid, log.bucket, datetimeISO, log.userid, log.operation, log.filename,
				log.httpStatus, log.prefLocale, log.locale, log.error, log.tranSize, log.fileSize, log.totalms, 
				log.s3ms, log.userAgent ];
			database.run(statement, row, function(err) {
				if (err) {
					database.run('ROLLBACK', function(rollErr) {
						if (rollErr) {
							errorMessage(rollErr, 'DownloadS3Logs.ROLLBACK');
						} else {
							errorMessage(err, "DownloadS3Logs.insertRecords");
						}
					});
				} else {
					insertRecords(database, statement, records, callback);
				}
			});
		} else {
			database.run('COMMIT', function(err) {
				if (err) {
					errorMessage(err, 'Downloads3Logs.COMMIT');
				} else {
					callback();
				}
			});
		}
	};
	function parseDatetime(datetime) {
		var parts = datetime.split(' ');
		var pieces = parts[0].split(':');
		var dateParts = pieces[0].split('/');
		var month = MONTHS.indexOf(dateParts[1]) + 1;
		if (month < 1) month = dateParts[1];
		var result = dateParts[2] + '-' + month + '-' + dateParts[0] + 'T' + pieces[1] + ':' + pieces[2] + ':' + pieces[3];
		console.log('DATE CONVERSION ', datetime, ' TO ', result);
		return(result);
	};
	function deleteFromS3(s3, bucket, item, callback) {
		console.log('DO NOT DELETE OBJECT IN TEST', item.Key);
		//s3.deleteObject({Bucket: bucket, Key: item.Key}, function(err, data) {
		//	if (err) {
		//		errorMessage(err, "DownloadS3Logs.deleteFromS3");
		//	} else {
				callback();
		//	}
		//});
	}
	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error));
		process.exit(1);
	}
};

downloadS3Logs();
