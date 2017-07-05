/**
* This program parses the userAgent field in order to extract:
* manufacturer, model, osType, osVersion and populate the
* BibleDownload table with the results.
*/
"use strict";
var postProcessBibleDownload = function(callback) {

	var Sqlite = require('./Sqlite.js');
	var database = new Sqlite('Analytics.db', true);
	
	var statement = 'SELECT rowid, userAgent FROM BibleDownload WHERE osType IS NULL';
	database.selectAll(statement, [], function(userAgentArray) {
		processUserAgent(0, userAgentArray);
	});
	
	function processUserAgent(index, array) {
		var row = array[index];
		if (row) {
			if (row.userAgent.indexOf('Android') > -1) {
				parseAndroidUserAgent(row);
			} else if (row.userAgent.indexOf('iPhone') > -1) {
				parseIOSUserAgent(row);
			} else if (row.userAgent.indexOf('iPad') > -1) {
				parseIOSUserAgent(row);
			} else if (row.userAgent.indexOf('Console') > -1) {
				parseConsoleUserAgent(row);
			} else if (row.userAgent.indexOf('aws') > -1) {
				parseAWSUserAgent(row);
			} else {
				parseOther(row);
			}
			processUserAgent(index + 1, array);
		} else {
			updateBibleDownload(array, function() {
				finish();
			});
		}
	}
	
	function parseAndroidUserAgent(row) {
		var parts = row.userAgent.split(' ');
		var android = parts.indexOf('Android');
		row.osType = parts[android];
		row.osVersion = parts[android +1];
		row.osVersion = row.osVersion.replace(';', '');
		row.manufacturer = parts[android +2];
		row.model = (parts[android +3].indexOf('Build') > -1 ) ? null : parts[android +3];
		//console.log('Android ', row);
	}
	
	function parseIOSUserAgent(row) {
		var parts = row.userAgent.split(' ');
		row.osType = 'iOS';
		var os = parts.indexOf('OS');
		row.osVersion = parts[os +1].replace(/_/g, '.');
		row.manufacturer = 'Apple';
		row.model = parts[1].replace(/[(;]/g, '');
		//console.log('iOS ', row);		
	}
	
	function parseConsoleUserAgent(row) {
		var parts = row.userAgent.split(/[ \/]/g);
		var item = parts.indexOf('S3Console');
		if (item < 0) item = parts.indexOf('Console');
		row.osType = 'AWS';
		row.osVersion = parts[item +1];
		row.manufacturer = 'AWS';
		row.model = 'S3Console';
		//console.log('Console ', row);
	}
	
	function parseAWSUserAgent(row) {
		var parts = row.userAgent.split(/[ \/]/g);
		row.osType = parts[0];
		row.osVersion = parts[1];
		row.manufacturer = 'AWS';
		row.model = (parts.length > 2) ? parts[2] + ' ' + parts[3] : null;
		//console.log('AWS ', row);		
	}
	
	function parseOther(row) {
		var parts = row.userAgent.split(/[ \/]/g);
		row.osType = parts[0];
		row.osVersion = parts[1];
		row.manufacturer = 'Other';
		row.model = null;
		//console.log('Other ', row);		
	}
	
	function updateBibleDownload(array, callback) {
		var records = [];
		for (var i=0; i<array.length; i++) {
			var row = array[i];
			records.push([row.osType, row.osVersion, row.manufacturer, row.model, row.rowid]);
		}
		var statement = 'UPDATE BibleDownload SET osType=?, osVersion=?, manufacturer=?, model=? WHERE rowid=?';
		database.execute(statement, records, function() {
			callback();
		});
	}
	
	function finish() {
		database.close()
	}
	
	function errorMessage(error, message) {
		database.close();
		console.log('ERROR', message, JSON.stringify(error));
		process.exit(1);
	}
};

postProcessBibleDownload(function() {
	console.log('DONE WITH POST PROCESS BibleDownload');
});