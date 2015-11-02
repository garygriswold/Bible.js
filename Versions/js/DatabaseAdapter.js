/**
* This class provides a convenient JS interface to a SQL database.
* The interface is intended to be useful for any kind of database,
* but this implementation is for SQLite3.
*
* Note: as of 8/24/2015, when no rows are updated or deleted, because
* key was wrong, no error is being generated.
*/
"use strict";
function DatabaseAdapter(options) {
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
}
DatabaseAdapter.prototype.create = function(callback) {
	var statements = [
		'DROP TABLE IF EXISTS CountryVersion',
		'DROP TABLE IF EXISTS Version',
		'DROP TABLE IF EXISTS Owner',
		'DROP TABLE IF EXISTS Country',
		'DROP TABLE IF EXISTS Language',

		'CREATE TABLE Language(' +
			' silCode text PRIMARY KEY NOT NULL,' +
			' silName text NOT NULL,' +
			' silPage number NULL,' +
			' population number NULL,' +
			' comment text NULL)',
			
		'CREATE TABLE Country(' +
			' code text PRIMARY KEY NOT NULL,' +
			' englishName text NOT NULL,' +
			' primLanguage text REFERENCES Language(silCode) NOT NULL,' +
			' localName text NOT NULL,' +
			' flagIcon blob NULL,' +
			' comment text NULL)',
			
		'CREATE INDEX countryLanguageIdx ON Country(primLanguage)',
			
		'CREATE TABLE Owner(' +
			' code text PRIMARY KEY NOT NULL,' +
			' name text NOT NULL,' +
			' comment text NULL)',
			
		'CREATE TABLE Version(' +
			' code text PRIMARY KEY NOT NULL,' +
			' silCode text REFERENCES Language(silCode) NOT NULL,' +
			' dblName text NULL,' +
			' ownerCode text REFERENCES Owner(code) NOT NULL,' +
			' copyrightYear text NOT NULL,' +
			' scope text CHECK(scope IN("BIBLE","NT","PNT")) NULL,' + // should be not null
			' filename text NULL,' +
			' comment text NULL)',
			
		'CREATE INDEX versionLanguageIdx ON Version(silCode)',
		'CREATE INDEX versionOwnerIdx ON Version(ownerCode)',
		
		'CREATE TABLE CountryVersion(' +
			' countryCode text NOT NULL,' +
			' versionCode text NOT NULL,' +
			' localLanguageName text NOT NULL,' +
			' localversionName text NOT NULL,' +
			' PRIMARY KEY(countryCode, versionCode))'
	];

	var values = new Array(statements.length);
	this.executeSQL(statements, values, callback);
};
DatabaseAdapter.prototype.executeSQL = function(statements, values, callback) {
	var that = this;
	var rowCount = 0;
	executeStatement(0);
		
	function executeStatement(index) {
		if (index < statements.length) {
			console.log('run', statements[index]);
			that.db.run(statements[index], values[index], function(err) {
				if (err) {
					console.log('Has error ', err);
					callback(err);
				} else {
					rowCount += this.changes;
					executeStatement(index + 1);
				}
			});
		} else {
			callback(null, rowCount);
		}
	}
};

//var database = new DatabaseAdapter({filename: './TestDatabase.db', verbose: true});
//database.create(function(err) { console.log('CREATE ERROR', err); });

module.exports = DatabaseAdapter;