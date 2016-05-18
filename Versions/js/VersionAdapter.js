/**
* This program reads files containing introductions and adds them to 
* the Version table.
*/
"use strict";
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
	//this.directory = null;
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
database.loadIntroductions('data/VersionIntro', function() {
	database.close();
	console.log('SUCCESSFULLY CREATED Versions.db');
});

module.exports = VersionAdapter;
