
const DATABASE = './TestAnalytics.db';
const DB_VERBOSE = true;

function Sqlite(databaseName, verbose) {
	this.databaseName = databaseName;
	this.verbose = verbose;

	var sqlite3 = (verbose) ? require('sqlite3').verbose() : require('sqlite3');
	this.database = new sqlite3.Database(databaseName);
	if (verbose) {
		this.database.on('trace', function(sql) {
			console.log('DO ', sql);
		});
		this.database.on('profile', function(sql, ms) {
			console.log(ms, 'DONE', sql);
		});
	}
	this.database.run("PRAGMA foreign_keys = ON");
	Object.freeze(this);
};

Sqlite.prototype.execute = function(statement, records, callback) {
	var that = this;
	this.database.run('BEGIN TRANSACTION', function(err) {
		if (err) {
			that.errorMessage(err, 'DownloadS3Logs.BEGIN_TRAN');
		} else {
			doRecords(statement, records, callback);
		}
	});
	
	function doRecords(statement, records, callback) {
		var row = records.shift();
		if (row) { 
			that.database.run(statement, row, function(err) {
				if (err) {
					that.database.run('ROLLBACK', function(rollErr) {
						if (rollErr) {
							that.errorMessage(rollErr, 'Sqlite.ROLLBACK');
						} else {
							that.errorMessage(err, "Sqlite.doRecords");
						}
					});
				} else {
					doRecords(statement, records, callback);
				}
			});
		} else {
			that.database.run('COMMIT', function(err) {
				if (err) {
					that.errorMessage(err, 'Downloads3Logs.COMMIT');
				} else {
					callback();
				}
			});
		}
	}
};

Sqlite.prototype.close = function(callback) { // optional callback
	var that = this;
	this.database.close(function(err) {
		if (err) {
			that.errorMessage('Sqlite.close', err);
		} else {
			console.log('Database closed');
			if (callback != null) {
				callback();
			}
		}
	});
};

Sqlite.prototype.errorMessage = function(message, error) {
	console.log('ERROR', message, JSON.stringify(error));
	process.exit(1);
};

/*
// Unit Test
var database = new Sqlite("TestAnalytics.db", true);
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
var record = '{ "bucket":"shortsands-as-jp", "datetime":"24/May/2017:01:59:54 +0000", "userid":"-", "requestid":"7E41404412E02502", "operation":"REST.HEAD.BUCKET", "filename":"-", "httpStatus":"301", "error":"PermanentRedirect", "tranSize":"447", "fileSize":"-", "totalms":"6", "s3ms":"-", "userAgent":"aws-internal/3, S3Console/0.4" }';
var log = JSON.parse(record);
var row = [ log.requestid, log.bucket, "2017-01-01T12:31:29", log.userid, log.operation, log.filename,
				log.httpStatus, log.prefLocale, log.locale, log.error, log.tranSize, log.fileSize, log.totalms, 
				log.s3ms, log.userAgent ];
database.execute(statement, [row], function() {
	database.close();
});
*/
