/**
* This program reads the Identity tables of all of the databases in the DBL/5ready directory,
* and copies the data into a table named Identity in the Versions.db database
*/

const DATABASE_PATH = process.env.HOME + '/ShortSands/DBL/5ready/';
const VERSIONS_DB = 'Versions.db';

var versionIdentity = function() {
	var bibles = getListOfBibles();
	var sqlite3 = require('sqlite3');
	var database = new sqlite3.Database(VERSIONS_DB);
	createIdentityTable(database, function() {
		processBibles(database, bibles, function() {
			database.close(function(err) {
				if (err) {
					errorMessage(err, 'VersionIdentity.closeDatabase');
				} else {
					console.log('DONE');	
				}
			});
		});		
	});

	
	function getListOfBibles() {
		var fs = require('fs');
		var list = fs.readdirSync(DATABASE_PATH);
		var result = [];
		for (var i=0; i<list.length; i++) {
			var item = list[i];
			var type = item.split('.').pop();
			if (type === 'db') {
				result.push(item);
			}
		}
		return(result);
	}
	function createIdentityTable(database, callback) {
		var statement = 'DROP TABLE IF EXISTS Identity';
		database.run(statement, function(err) {
			if (err) {
				errorMessage(err, 'VersionIdentity.dropTableIdentity');
			} else {
				statement = 'CREATE TABLE Identity(' +
					' versionCode TEXT NOT NULL PRIMARY KEY,' +
					' filename TEXT NOT NULL,' +
					' bibleVersion TEXT NOT NULL,' +
					' datetime TEXT NOT NULL,' +
					' appVersion TEXT NOT NULL,' +
					' publisher TEXT NOT NULL)';
				database.run(statement, function(err) {
					if (err) {
						errorMessage(err, 'VersionDiff.createIdentity');
					} else {
						callback();
					}
				});
			}
		});		
	}
	function processBibles(versionsDB, bibles, callback) {
		var bible = bibles.shift();
		if (bible) {
			console.log('PROCESSING', bible);
			readIdentityTable(versionsDB, bible, function() {
				processBibles(versionsDB, bibles, callback);
			});
		} else {
			callback();
		}
	}
	function readIdentityTable(versionsDB, bible, callback) {
		var sqlite3 = require('sqlite3');
		var database = new sqlite3.Database(DATABASE_PATH + bible);
		var statement = 'SELECT versionCode, filename, bibleVersion, datetime, appVersion, publisher FROM identity';
		database.get(statement, function(err, row) {
			if (err) {
				errorMessage(err, 'VersionIdentity.selectIdentity');
			} else {
				statement = 'INSERT INTO Identity(versionCode, filename, bibleVersion, datetime, appVersion, publisher) VALUES (?,?,?,?,?,?)';
				versionsDB.run(statement, [row.versionCode, row.filename, row.bibleVersion, row.datetime, row.appVersion, row.publisher], function(err, results) {
					if (err) {
						errorMessage(err, 'VersionIdentity.insertIdentity');
					} else {
						database.close(function(err) {
							if (err) {
								errorMessage(err, 'VersionIdentity.closeDatabase');
							} else {
								callback();
							}
						});
					}
				});
			}
		});
	}
	function errorMessage(err, message) {
		console.log(message, JSON.stringify(err));
		process.exit(1);
	}
};

versionIdentity();
