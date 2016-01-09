/**
* This class provides a convenient JS interface to a the Version.db database.
* The interface is intended to be useful for any kind of database,
* but this implementation is for SQLite3.
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
	this.fs = require('fs');
	this.directory = null;
	Object.seal(this);
}
DatabaseAdapter.prototype.create = function(callback) {
	var statements = [
		'DROP TABLE IF EXISTS TextTranslation',
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
			' countryCode text PRIMARY KEY NOT NULL,' +
			' englishName text NOT NULL,' +
			' primLanguage text REFERENCES Language(silCode) NOT NULL,' +
			' localName text NOT NULL,' +
			' flagIcon blob NULL,' +
			' comment text NULL)',
			
		'CREATE INDEX countryLanguageIdx ON Country(primLanguage)',
			
		'CREATE TABLE Owner(' +
			' ownerCode text PRIMARY KEY NOT NULL,' +
			' ownerName text NOT NULL,' +
			' comment text NULL)',
			
		'CREATE TABLE Version(' +
			' versionCode text PRIMARY KEY NOT NULL,' +
			' silCode text REFERENCES Language(silCode) NOT NULL,' +
			' dblName text NULL,' +
			' ownerCode text REFERENCES Owner(ownerCode) NOT NULL,' +
			' copyrightYear text NULL,' + // should be not null
			' scope text CHECK(scope IN("BIBLE","NT","PNT")) NULL,' + // should be not null
			' filename text NULL,' +
			' isQaActive boolean NULL,' + // values are T, F, null
			' comment text NULL)',
			
		'CREATE INDEX versionLanguageIdx ON Version(silCode)',
		'CREATE INDEX versionOwnerIdx ON Version(ownerCode)',
		'CREATE UNIQUE INDEX versionFilenameIdx ON Version(filename)',
		
		'CREATE TABLE CountryVersion(' +
			' countryCode text REFERENCES Country(countryCode) NOT NULL,' +
			' versionCode text REFERENCES Version(versionCode) NOT NULL,' +
			' localLanguageName text NOT NULL,' +
			' localVersionName text NULL,' +
			' comment text NULL,' +
			' PRIMARY KEY(countryCode, versionCode))',
			
		'CREATE INDEX countryVersionCodeIdx ON CountryVersion(countryCode)',
		'CREATE INDEX countryVersionVersionIdx ON CountryVersion(versionCode)',
		
		'CREATE TABLE TextTranslation(' +
			' silCode text REFERENCES Language(silCode) NOT NULL,' +
			' word text NOT NULL,' +
			' translated text NOT NULL,' +
			' PRIMARY KEY(silCode, word))'
	];
	this.executeDDL(statements, callback);
};
DatabaseAdapter.prototype.loadAll = function(directory) {
	var that = this;
	this.directory = directory;
	var file = '/Owner-Table 1.csv';
	var statement = 'INSERT INTO Owner(ownerCode, ownerName, comment) values (?,?,?)';
	this.loadFile(file, statement, function(rowCount) {
		console.log('Owner count', rowCount);
		
		file = '/Language-Table 1.csv';
		statement = 'INSERT INTO Language(silCode, silName, silPage, population, comment) values (?,?,?,?,?)';
		that.loadFile(file, statement, function(rowCount) {
			console.log('Language count', rowCount);
			
			file = '/Country-Table 1.csv';
			statement = 'INSERT INTO Country(countryCode, englishName, primLanguage, localName, flagIcon, comment) values (?,?,?,?,?,?)';
			that.loadFile(file, statement, function(rowCount) {
				console.log('Country count', rowCount);
				
				file = '/Version-Table 1.csv';
				statement = 'INSERT INTO Version(versionCode, silCode, dblName, ownerCode, copyrightYear, scope, filename, isQaActive, comment) values ' +
						' (?,?,?,?,?,?,?,?,?)';
				that.loadFile(file, statement, function(rowCount) {
					console.log('Version count', rowCount);
					
					file = '/CountryVersion-Table 1.csv';
					statement = 'INSERT INTO CountryVersion(countryCode, versionCode, localLanguageName, localVersionName, comment) values (?,?,?,?,?)';
					that.loadFile(file, statement, function(rowCount) {
						console.log('CountryVersion count', rowCount);
						
						file = '/TextTranslation-Table 1.csv';
						statement = 'INSERT INTO TextTranslation(silCode, word, translated) values (?,?,?)';
						that.loadFile(file, statement, function(rowCount) {
							console.log('TextTranslation count', rowCount);
						})
					});
				});
			});
		});
	});
};
DatabaseAdapter.prototype.loadFile = function(file, statement, callback) {
	var that = this;
	var filename = this.directory + '/' + file;
	console.log('filename', filename);
	this.fs.readFile(filename, { encoding: 'utf8'}, function(error, data) {
		if (error) {
			console.log(error);
			process.exit(1);
		} else {
			var array = that.safeCSVSplit(data);
			that.executeSQL(statement, array, function(rowCount) {
				callback(rowCount);
			});
		}
	});	
};
DatabaseAdapter.prototype.safeCSVSplit = function(results) {
	var array = results.split('\r\n');
	array.shift(); // discard header
	for (var line=0; line<array.length; line++) {
		var row = array[line];
		var insideQuote = false;
		var fields = [];
		var oneField = [];
		for (var c=0; c<row.length; c++) {
			var char = row.charAt(c);
			if (insideQuote) {
				if (char === '"') {
					insideQuote = false;
				} else {
					oneField.push(char);
				}
			} else {
				if (char === '"') {
					insideQuote = true;
				} else if (char === ',') {
					fields.push(buildField(oneField));
					oneField = [];
				} else {
					oneField.push(char);
				}
			}
		}
		fields.push(buildField(oneField));
		array[line] = fields;
	}
	return(array);
	
	function buildField(one) {
		return((one.length > 0) ? one.join('') : null);
	}	
};
DatabaseAdapter.prototype.executeDDL = function(statements, callback) {
	var that = this;
	executeStatement(0);
		
	function executeStatement(index) {
		if (index < statements.length) {
			console.log('run', statements[index]);
			that.db.run(statements[index], function(err) {
				if (err) {
					console.log('Has error ', err);
					process.exit(1);
				} else {
					executeStatement(index + 1);
				}
			});
		} else {
			callback();
		}
	}
};
DatabaseAdapter.prototype.executeSQL = function(statement, values, callback) {
	var that = this;
	var rowCount = 0;
	executeStatement(0);
		
	function executeStatement(index) {
		if (index < values.length) {
			that.db.run(statement, values[index], function(err) {
				if (err) {
					console.log('Has error ', err);
					process.exit(1);
				} else {
					rowCount += this.changes;
					executeStatement(index + 1);
				}
			});
		} else {
			callback(rowCount);
		}
	}
};

module.exports = DatabaseAdapter;