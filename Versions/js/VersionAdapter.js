/**
* This program reads files containing introductions and adds them to 
* the Version table.
*/
"use strict";
const REGIONS = require('../../Library/cdn/Regions.js').REGIONS;
function VersionAdapter(options) {
	var sqlite3 = (options.verbose) ? require('sqlite3').verbose() : require('sqlite3');
	this.db = new sqlite3.Database(options.filename);
	if (options.verbose) {
		this.db.on('trace', function(sql) {
			console.log('DO ', sql);
		});
		this.db.on('profile', function(sql, ms) {
			console.log(ms, 'DONE', sql);
		});
	}
	this.db.run("PRAGMA foreign_keys = ON");
	this.fs = require('fs');
	Object.seal(this);
}
VersionAdapter.prototype.loadIntroductions = function(directory, callback) {
	var fs = require('fs');
	var list = fs.readdirSync(directory);
	var dstore = list.indexOf('.DS_Store');
	if (dstore > -1) list.splice(dstore, 1);
	var values = [];
	for (var i=0; i<list.length; i++) {
		var filename = list[i];
		var parts = filename.split('.');
		if (parts.length != 2) {
			console.log('CANNOT PROCESS', filename);
		} else if (parts[1] != 'html') {
			console.log('WRONG FILE TYPE', filename);
		} else {
			var data = fs.readFileSync(directory + '/' + filename, { encoding: 'utf8'});
			values.push([data, parts[0]]);
		}
	}
	var updateStmt = 'UPDATE Version SET introduction = ? WHERE versionCode = ?';
	this.executeSQL(updateStmt, values, function(rowCount) {
		if (rowCount != list.length) {
			console.log('DID NOT UPDATE ALL RECORDS, rowCount=' + rowCount, ' list.length=' + list.length);
			process.exit(1);
		} else {
			console.log('Introductions Updated', rowCount);
			callback();
		}
	});
};
/*
* This method adds video introductions to the Video table.
*/
VersionAdapter.prototype.loadVideoIntroductions = function(directory, callback) {
	var fs = require('fs');
	var list = fs.readdirSync(directory);
	var dstore = list.indexOf('.DS_Store');
	if (dstore > -1) list.splice(dstore, 1);
	var values = [];
	for (var i=0; i<list.length; i++) {
		var filename = list[i];
		var parts = filename.split('.');
		if (parts.length != 2) {
			console.log('CANNOT PROCESS', filename);
		} else if (parts[1] != 'html') {
			console.log('WRONG FILE TYPE', filename);
		} else {
			var data = fs.readFileSync(directory + '/' + filename, { encoding: 'utf8'});
			var pieces = parts[0].split('-');
			values.push([data, pieces[0].toUpperCase(), pieces[1].toLowerCase()]);
		}
	}
	var updateStmt = 'UPDATE Video SET longDescription = ? WHERE mediaId = ? AND silCode = ?';
	this.executeSQL(updateStmt, values, function(rowCount) {
		if (rowCount != list.length) {
			console.log('DID NOT UPDATE ALL RECORDS, rowCount=' + rowCount, ' list.length=' + list.length);
			process.exit(1);
		} else {
			console.log('VideoIntroductions Updated', rowCount);
			callback();
		}
	});
};

/**
* This method computes URL signatures for AWS cloudfront, and adds this information to the Version table	
*/
VersionAdapter.prototype.addCloudfrontSignatures = function(callback) {
	var that = this;
	var signer = require('aws-cloudfront-sign');
	var pkeyPath = '../../Credentials/AWSCloudfront/pk-APKAJ7UXJKWYASMHCDEA.pem.txt';
	var expireTime = new Date(2038, 0, 1); // This is maximum unix Date.
	var options = {keypairId: 'APKAJ7UXJKWYASMHCDEA', privateKeyPath: pkeyPath, expireTime: expireTime};
	this.db.all('SELECT versionCode, filename FROM Version', [], function(err, results) {
		if (err) {
			console.log('SQL Error in VersionAdapter.addCloudfrontSignatures');
			callback(err);
		} else {
			var signed = [];
			for (var i=0; i<results.length; i++) {
				var row = results[i];
				var url = 'https://d1obplp0ybf6eo.cloudfront.net/' + row.filename + '.zip';
				var signedURL = signer.getSignedUrl(url, options);
				//console.log(row.versionCode, 'Signed URL', signedURL);
				signed.push([signedURL, row.versionCode]);
			}
			that.executeSQL('UPDATE Version SET URLSignature=? WHERE versionCode=?', signed, function(rowCount) {
				console.log(rowCount, 'Rows of the version table updated');
				callback();
			});
		}
	});
};
/**
* This method computes URL signatures for AWS cloudfront, and adds this information to the Version table	
*/
VersionAdapter.prototype.addS3URLSignatures = function(callback) {
	var that = this;
	var cred = require('../../../Credentials/UsersGroups/BibleApp.js');
	var S3 = require('aws-sdk/clients/s3');
	var expireTime = 60 * 60 * 24 * 365 * 20;
	console.log('expireTime = ', expireTime);
	this.db.all('SELECT versionCode, filename FROM Version', [], function(err, versions) {
		if (err) {
			console.log('SQL Error in VersionAdapter.addS3URLSignatures');
			callback(err);
		} else {
			that.db.all('SELECT distinct awsRegion FROM Region', [], function(err, regions) {
				if (err) {
					console.log('SQL Error in VersionAdapter.select Region.awsRegion');
					callback(err);
				} else {
					var signed = [];
					for (var i=0; i< regions.length; i++) {
						var reg = regions[i];
						console.log('DOING REGION', reg.awsRegion, REGIONS[reg.awsRegion]);
						var awsOptions = {
								useDualstack: true,
								accessKeyId: cred.BIBLE_APP_KEY_ID,
								secretAccessKey: cred.BIBLE_APP_SECRET_KEY,
								region: REGIONS[reg.awsRegion],
								sslEnabled: true,
								s3ForcePathStyle: true
						};
						var s3 = new S3(awsOptions);
						for (var j=0; j<versions.length; j++) {
							var ver = versions[j];
							var params = {Bucket: reg.awsRegion, Key: ver.filename + '.zip', Expires: expireTime};
							var signedURL = s3.getSignedUrl('getObject', params);
							console.log(reg.awsRegion, ver.versionCode, 'Signed URL', signedURL);
							signed.push([ver.filename, reg.awsRegion, signedURL]);
						}
					}
					that.executeSQL('INSERT INTO DownloadURL (filename, awsRegion, signedURL) VALUES (?,?,?)', signed, function(rowCount) {
						console.log('INSERTED INTO DownloadURL', rowCount);
						callback();
					});
				}
			});
		}
	});
};
/**
* This method validates that the translation table is complete for all languages in use,
* and that the same items have been translated for all languages.
*/
VersionAdapter.prototype.validateTranslation = function(callback) {
	var statement = 'SELECT target, count(*) AS count FROM Translation GROUP BY target';
	this.db.all(statement, [], function(err, results) {
		if (err) {
			console.log('SQL Error in VersionAdapter.validateTranslation');
			callback(err);
		} else {
			var sum = 0;
			for (var i=0; i<results.length; i++) {
				sum += results[i].count;
			}
			var avg = Math.round(sum / results.length);
			var errorCount = 0;
			for (i=0; i<results.length; i++) {
				if (results[i].count != avg) {
					errorCount++;
					console.log('Translation Average=' + avg + ' ' + results[i].target + '=' + results[i].count);
				}
			}
			callback(errorCount);
		}
	});
};
VersionAdapter.prototype.executeSQL = function(statement, values, callback) {
	var that = this;
	var rowCount = 0;
	executeStatement(0);
		
	function executeStatement(index) {
		if (index < values.length) {
			that.db.run(statement, values[index], function(err) {
				if (err) {
					console.log('Has error ', err);
					process.exit(1);
				} else if (this.changes === 0) {
					console.log('SQL did not update', statement, values[index]);
				} else {
					rowCount += this.changes;
				}
				executeStatement(index + 1);
			});
		} else {
			callback(rowCount);
		}
	}
};
VersionAdapter.prototype.close = function() {
	this.db.close(function(err) {
		if (err) {
			console.log('Error on close', err);
			process.exit(1);
		}
	});	
};

var database = new VersionAdapter({filename: './Versions.db', verbose: false});
console.log('Start Version Adapter');
database.loadIntroductions('data/VersionIntro', function() {
	console.log('Loaded Introductions');	
	//database.addCloudfrontSignatures(function() { // Use for Cloudfront
	database.addS3URLSignatures(function() {		// Use for S3
		console.log('Added URL Signatures');
		database.validateTranslation(function(errCount) {
			console.log('Validated Translation');
			database.close();
			console.log('Database Closed');
			if (errCount == 0) {
				console.log('SUCCESSFULLY CREATED Versions.db');
			} else {
				console.log('COMPLETED WITH ERRORS', errCount);
			}
		});
	});
});

module.exports = VersionAdapter;
