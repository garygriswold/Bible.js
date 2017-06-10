/**
* This class processes Bible download log entries and inserts them into the BibleDownload table.
*/

"use strict";
const MONTHS = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ];

function InsertDownloadLogs(database) {
	this.database = database;
}

InsertDownloadLogs.prototype.insert = function(logFile, callback) {

	console.log('READ FILE', logFile);
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
	var records = [];
	var logRecords = logFile.split('\n');
	for (var i = 0; i< logRecords.length; i++) {
		var logRec = logRecords[i];
		var log = JSON.parse(logRec.trim());
		var datetimeISO = parseDatetime(log.datetime);
		var row = [ log.requestid, log.bucket, datetimeISO, log.userid, log.operation, log.filename,
				log.httpStatus, log.prefLocale, log.locale, log.error, log.tranSize, log.fileSize, log.totalms, 
				log.s3ms, log.userAgent ];
		records.push(row);
	}
	this.database.execute(statement, records, function() {
		callback();
	});
	
	function parseDatetime(datetime) {
		var parts = datetime.split(' ');
		var pieces = parts[0].split(':');
		var dateParts = pieces[0].split('/');
		var month = MONTHS.indexOf(dateParts[1]) + 1;
		if (month < 1) month = dateParts[1];
		var result = dateParts[2] + '-' + month + '-' + dateParts[0] + 'T' + pieces[1] + ':' + pieces[2] + ':' + pieces[3];
		console.log('DATE CONVERSION ', datetime, ' TO ', result);
		return(result);
	}
	
	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error));
		process.exit(1);
	}
};

module.exports = InsertDownloadLogs;