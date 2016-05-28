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
	this.fs = require('fs');
	this.db = null;
	var canon = new Canon();
	this.bookMap = canon.sequenceMap();
}
ConcordanceValidator.prototype.open = function(callback) {
	var that = this;
	var sqlite3 = require('sqlite3');
	this.db = new sqlite3.Database(this.versionPath, sqlite3.OPEN_READWRITE, function(err) {
		if (err) that.fatalError(err, 'openDatabase');
		//that.db.on('trace', function(sql) { console.log('DO ', sql); });
		//that.db.on('profile', function(sql, ms) { console.log(ms, 'DONE', sql); });
		callback();
	});
};

ConcordanceValidator.prototype.normalize = function(callback) {
	var that = this;
	this.db.serialize(function() {
		createValPunctuation(function(err) { if (err) that.fatalError(err, 'createValPunctuation'); });
		normalizeConcordance(function(err, result) {
			if (err) that.fatalError(err, 'normalizeConcordance')
			var generatedText = that.generate(result);
			that.outputFile(generatedText);
			that.compare(generatedText, function(err) {
				if (err) that.fatalError(err, 'compare');
				that.summary(function(err) {
					if (err) that.fatalError(err, 'summary');
					callback();
				});
			});
		});	
	});
	function createValPunctuation(callback) {
		//console.log('drop valConcordance');
		//that.db.run('drop table if exists valConcordance', [], function(err) { if (err) callback(err); });
		console.log('drop valPunct');
		that.db.run('drop table if exists valPunctuation', [], function(err) { if (err) callback(err); });
		//var createValConcordance = 
		//	'CREATE TABLE valConcordance(' +
		//	'book text not null, ' +
		//	'ordinal int not null, ' +
		//	'chapter int not null, ' +
		//	'verse int not null, ' +
		//	'position int not null, ' +
		//	'word text not null)';
		//console.log('create valConcordance');
		//that.db.run(createValConcordance, [], function(err) { if (err) callback(err);	});
		var createValPunctuation =
			'CREATE TABLE valPunctuation(' +
			'book text not null, ' +
			'chapter int not null, ' +
			'verse int not null, ' +
			'char text not null)';
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
					var ordinal = that.bookMap[parts[0]];
					for (var k=3; k<parts.length; k++) {
						array.push({book:parts[0], ordinal:ordinal, chapter:parts[1], verse:parts[2], position:parts[k], word:row.word });
					}	
				}
			}
			console.log(array.length, 'Normalized Concordance Records');
			callback(null, array);
		});
	}
	/** deprecated, not used becuase it takes many minutes to run */
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
};
ConcordanceValidator.prototype.generate = function(concordance) {
	concordance.sort(function(a, b) {
		var bookDiff = a.ordinal - b.ordinal;
		if (bookDiff !== 0) return(bookDiff);
		var chapDiff = a.chapter - b.chapter;
		if (chapDiff !== 0) return(chapDiff);
		var versDiff = a.verse - b.verse;
		if (versDiff !== 0) return(versDiff);
		return(a.position - b.position);
	});
	var result = [];
	var priorBook = '';
	var priorChap = '';
	var priorVers = '';
	var generated = null;
	for (var i=0; i<concordance.length; i++) {
		var row = concordance[i];
		if (row.book != priorBook || row.chapter != priorChap || row.verse != priorVers) {
			if (generated != null) {
				result.push({ book:priorBook, chapter:priorChap, verse:priorVers, text:generated.join(' ') });
			}
			priorBook = row.book;
			priorChap = row.chapter;
			priorVers = row.verse;
			generated = [];
		}
		generated.push(row.word);
	}
	console.log(result.length, 'Generated Verses');
	return(result);
};
ConcordanceValidator.prototype.outputFile = function(generatedText) {
	var output = [];
	for (var i=0; i<generatedText.length; i++) {
		var row = generatedText[i];
		//console.log(row.book, row.chapter, row.verse, row.text);
		output.push([row.book, row.chapter, row.verse, row.text].join(':'));
	}
	this.fs.writeFile('output/generated.txt', output.join('\n'), { encoding: 'utf8'}, function(err) {
		if (err) fatalError(err, 'write generated');
	});
};
ConcordanceValidator.prototype.compare = function(generatedText, callback) {
	var that = this;
	var insertStmt = this.db.prepare('INSERT INTO valPunctuation (book, chapter, verse, char) VALUES (?,?,?,?)');
	var selectStmt = 'SELECT html FROM verses WHERE reference=?';
	iterateEach(0);

	function iterateEach(index) {
		if (index < generatedText.length) {
			var line = generatedText[index];
			var reference = line.book + ':' + line.chapter + ':' + line.verse;
			that.db.get(selectStmt, reference, function(err, row) {
				if (err) callback(err);
				//console.log(line.book, line.chapter, line.verse, row.html);
				compareOne(line.book, line.chapter, line.verse, line.text, ((row) ? row.html : ''));
				iterateEach(index + 1);
			});
		} else {
			callback();
		}
	}
	/*
	* This compare assumes that one string is complete, and the other a substring.
	* So it does all of its lookaheads on the whole string.  If this assumption turns
	* out to be false, and the substring contains characters that are not in the whole
	* string, this will result in many errors found in that compare, which is OK because
	* it is a serious and unexpected.
	*/
	function compareOne(book, chapter, verse, generated, original) {
		//console.log('compare', book, chapter, verse);
		var gi = 0;
		for (var oi=0; oi < original.length; oi++) {
			if (generated.charAt(gi) === original.charAt(oi).toLowerCase()) {
				gi++;
			} else if (generated.charAt(gi) === ' ') {
				gi++;
				oi--;
			} else {
				insertStmt.run(book, chapter, verse, original.charAt(oi), function(err) { if (err) callback(err); });
			}
		}
	}
};
ConcordanceValidator.prototype.summary = function(callback) {
	var stmt = 'SELECT char, count(*) as count FROM valPunctuation GROUP BY char';
	this.db.all(stmt, [], function(err, results) {
		if (err) callback(err);
		for (var i=0; i<results.length; i++) {
			var row = results[i];
			console.log(row.char, row.count);
		}
		callback();
	});
};
ConcordanceValidator.prototype.fatalError = function(err, source) {
	console.log('FATAL ERROR ', err, ' AT ', source);
	process.exit(1);
};
ConcordanceValidator.prototype.completed = function() {
	console.log('COMPLETED');
	this.db.close();
	process.exit(0);
};


var DB_PATH = '../../DBL/3prepared/';
	
if (process.argv.length < 3) {
	console.log('Usage: ./Validator.sh VERSION');
	process.exit(1);
} else {
	var fs = require('fs');
	var filename = DB_PATH + process.argv[2] + '.db';
	console.log('Process ' + filename);
	var val = new ConcordanceValidator(filename);
	val.open(function() {
		val.normalize(function() {
			val.completed();
		});
	});
}


