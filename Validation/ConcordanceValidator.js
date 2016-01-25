/**
* This class validates the concordance table in a bible, by reading the refPositions column,
* which contains both reference and word positions.  Using this it recreates the entire Bible
* without punctuation.  Then it can compare the generated Bible with the text stored in the verses
* table.  It does a character by character comparison.  There must be no extra characters in the
* generated; that would indicate a severe error in the process that generated the concordance or
* the process that generated the verses table.  However, the presence of extra punctuation characters 
* in the verses table is expected.  Each such character should be recorded.  At the end of the process
* a frequency table is produced of how many times each punctuation character is used.  It must be
* manually verified that each of these is a punctuation character in that language.
*/
function ConcordanceValidator(versionPath) {
	this.versionPath = versionPath;
	this.db = null;
}
ConcordanceValidator.prototype.open = function(callback) {
	var sqlite3 = require('sqlite3');
	this.db = new sqlite3.Database(this.versionPath, sqlite3.OPEN_READWRITE, function(err) {
		if (err) fatalError(err, 'openDatabase');
		//db.on('trace', function(sql) { console.log('DO ', sql); });
		//db.on('profile', function(sql, ms) { console.log(ms, 'DONE', sql); });
		callback();
	});
};

ConcordanceValidator.prototype.normalize = function() {
	var that = this;
	this.db.serialize(function() {
		createValConcordance(function(err) { if (err) fatalError(err, 'createValConcordance'); });
		normalizeConcordance(function(err, result) {
			if (err) fatalError(err, 'normalizeConcordance')
			populateValConcordance(result, function(err) {
				if (err) fatalError(err, 'populateValConcordance');
				else completed();
			});
		});	
	});	

	// 6. Sort this datatable by book ordinal, verse, position
	// 7. Using one string per verse, recreate each verse.
	// 8. Read that verse from verses table, and compare with generated verse by verse.
	// 9. Each character in the original that is not found in the generated is stored in a table of book, verse, position, character
	// 10. Optionally, the generated Bible is written to an output file line by line.
	// 11. At the end of the process a frequence count is displayed of the different characters.
	// 12. It is up to the developer to go look at the table of missing characters.
	// 13. It is essential that this process produces an error if there is an extra character in the generated that is not in the verses.
	// This would probably indicate a problem in the verses table.
	function createValConcordance(callback) {
		console.log('drop valConcordance');
		that.db.run('drop table if exists valConcordance', [], function(err) { if (err) callback(err); });
		console.log('drop valPunct');
		that.db.run('drop table if exists valPunctuation', [], function(err) { if (err) callback(err); });
		var createValConcordance = 
			'CREATE TABLE valConcordance(' +
			'book text not null, ' +
			'ordinal int not null, ' +
			'chapter int not null, ' +
			'verse int not null, ' +
			'position int not null, ' +
			'word text not null)';
		console.log('create valConcordance');
		that.db.run(createValConcordance, [], function(err) { if (err) callback(err);	});
		var createValPunctuation =
			'CREATE TABLE valPunctuation(' +
			'book text not null, ' +
			'book_ordinal int not null, ' +
			'chapter int not null, ' +
			'verse int not null, ' +
			'position int not null, ' +
			'character text not null)';
		console.log('create valPunct');
		that.db.run(createValPunctuation, [], function(err) { if (err) callback(err); });
		console.log('done create tables');
		callback();
	}
	function normalizeConcordance(callback) {
		var array = [];
		that.db.all('SELECT rowid, word, refPosition FROM concordance', [], function(err, results) {
			if (err) callback(err);
			for (var i=0; i<results.length; i++) {
				var row = results[i];
				console.log(i, row.word);
				var refList = row.refPosition.split(',');
				for (var j=0; j<refList.length; j++) {
					var reference = refList[j];
					var parts = reference.split(':');
					var ordinal = 0;
					for (var k=3; k<parts.length; k++) {
						var position = parts[k];
						array.push({book:parts[0], ordinal:ordinal, chapter:parts[1], verse:parts[2], position:parts[k], word:row.word });
					}
				}
			}
			console.log('RESULT size ', array.length);
			callback(null, array);
		});
	}
	function populateValConcordance(array, callback) {
		var insertStmt = 'INSERT INTO valConcordance(book, ordinal, chapter, verse, position, word) VALUES (?,?,?,?,?,?)';
		var insertVal = that.db.prepare(insertStmt, [], function(err) { if (err) callback(err) });
		insertValConcordanceRow(0, array, callback);

		function insertValConcordanceRow(index, array, callback) {
			if (index < array.length) {
				var row = array[index];
				console.log(index);
				insertVal.run(row.book, row.ordinal, row.chapter, row.verse, row.position, row.word, function(err) { 
					if (err) callback(err);
					insertValConcordanceRow(index + 1, array, callback);
				});
			} else {
				callback();
			}
		}
	}
	function fatalError(err, source) {
		console.log('FATAL ERROR ', err, ' AT ', source);
		process.exit(1);
	}
	function completed() {
		console.log('COMPLETED');
		that.db.close();
		process.exit(0);
	}
};

var val = new ConcordanceValidator('WEB.db1');
val.open(function() {
	val.normalize();
});

