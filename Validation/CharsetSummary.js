/**
* This program reads any number of Bible versions in sqlite format, and reads the charset table, and creates
* a single table, which it outputs in CSV format.  This table is usd to identify characters that should affect
* the concordance builder program.  Both characters that are to serve as word separators and punctuation characters that
* must be removed must be identified in the concordance program.
*/
function CharsetSummary(versionsPath) {
	this.versionsPath = versionsPath;
	this.fs = require('fs');
	this.normalized = [];
	this.versions = [];
}
CharsetSummary.prototype.readData = function(callback) {
	var that = this;
	readDirectory(function(files) {
		var bibles = filterBibles(files);
		console.log('BIBLES', bibles);
		readAllCharsets(bibles, 0, function(results) {
			//for (var i=0; i<results.length; i++) {
			//	var row = results[i];
			//	console.log('ROW', row);
			//}
			callback(results);
		});
	});

	function readDirectory(callback) {
		that.fs.readdir(that.versionsPath, function(err, data) {
			if (err) { that.fatalError(err, 'readdir'); } 
			callback(data);
		});	
	}	
	function filterBibles(files) {
		var result = [];
		for (var i=0; i<files.length; i++) {
			if (files[i].indexOf('.db') > 0) {
				result.push(files[i]);
			}
		}
		return(result);
	}
	function readAllCharsets(files, index, callback) {
		if (index < files.length) {
			var file = files[index];
			that.versions.push(file);
			console.log('READ DB ', file);
			readCharsetTable(file, function(results) {
				for (var i=0; i<results.length; i++) {
					var row = results[i];
					row.version = file;
					that.normalized.push(row);
				}
				readAllCharsets(files, index + 1, callback);
			});
		} else {
			callback(that.normalized);
		}
	}
	function readCharsetTable(file, callback) {
		var sqlite3 = require('sqlite3');
		var db = new sqlite3.Database(file, sqlite3.OPEN_READONLY, function(err) {
			if (err) that.fatalError(err, 'openDatabase');
			//db.on('trace', function(sql) { console.log('DO ', sql); });
			db.all('SELECT hex, char FROM charset', [], function(err, results) {
				db.close();
				if (err) that.fatalError(err, 'select charset');
				callback(results);
			});
		});		
	}
};
CharsetSummary.prototype.fatalError = function(err, source) {
	console.error('FATAL ERROR', err, ' AT ', source);
	process.exit(1);	
};

var summary = new CharsetSummary('.');
	summary.readData(function(results) {
			for (var i=0; i<results.length; i++) {
				var row = results[i];
				console.log('ROW', row);
			}	
	console.log('DONE');
});
// 3) Open each file and read the charset table.
// 4) Identify each version by the name without the file suffix.
// 5) Build a Map where the name is the hex code, and the valu
// 8) Also build a list of versions and sort.
// 9) When all data is collected, sort codes, and versions
// 10) Build a two dimensional array of codes and versions
// 12) Put an X is each matrix where it is found.