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
function ConcordanceValidator(version, versionPath) {
	this.version = version;
	this.versionPath = versionPath;
	this.fs = require('fs');
	this.db = null;
	this.doValConcordance = false; // Change to try to generate ValConcordance takes 20 min.
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
		callback(that.db);
	});
};

ConcordanceValidator.prototype.normalize = function(callback) {
	var that = this;
	this.db.serialize(function() {
		createValPunctuation(function(err) { if (err) that.fatalError(err, 'createValPunctuation'); });
		normalizeConcordance(function(err, result) {
			if (err) that.fatalError(err, 'normalizeConcordance');
			var generatedText = that.generate(result);
			that.outputFile(generatedText);
			that.compare(generatedText, function(err) {
				if (err) that.fatalError(err, 'compare');
				callback();
			});
		});	
	});
	function createValPunctuation(callback) {
		console.log('drop valConcordance');
		that.db.run('drop table if exists valConcordance', [], function(err) { if (err) callback(err); });
		console.log('drop valPunct');
		that.db.run('drop table if exists valPunctuation', [], function(err) { if (err) callback(err); });
		var createValConcordance = 
			'CREATE TABLE valConcordance(' +
			' book text not null,' +
			' ordinal int not null,' +
			' chapter int not null,' +
			' verse int not null,' +
			' position int not null,' +
			' word text not null)';
		console.log('create valConcordance');
		that.db.run(createValConcordance, [], function(err) { if (err) callback(err);	});
		var createValPunctuation =
			'CREATE TABLE valPunctuation(' +
			' book text not null,' +
			' chapter int not null,' +
			' verse int not null,' +
			' position int not null,' +
			' charCode int not null,' +
			' char text not null)';
		console.log('create valPunct');
		that.db.run(createValPunctuation, [], function(err) { if (err) callback(err); });
		console.log('done create tables');
		callback();
	}
	function normalizeConcordance(callback) {
		var array = [];
		that.db.all('SELECT rowid, word, refList2 FROM concordance', [], function(err, results) {
			if (err) callback(err);
			for (var i=0; i<results.length; i++) {
				var row = results[i];
				console.log(i, row.word);
				var refList = row.refList2.split(',');
				for (var j=0; j<refList.length; j++) {
					var parts = refList[j].split(';');
					var pieces = parts[0].split(':');
					var ordinal = that.bookMap[pieces[0]];
					var verseSeq = pieces[2];
					var verseDash = verseSeq.indexOf('-');
					if (verseDash > 0) {
						verseSeq = verseSeq.substr(0, verseDash);
					}
					array.push({book:pieces[0], ordinal:ordinal, chapter:pieces[1], verse:pieces[2], verseSeq:verseSeq, position:parts[1], word:row.word });
				}
			}
			console.log(array.length, 'Normalized Concordance Records');
			if (that.doValConcordance) {
				populateValConcordance(array, function() {
					callback(null, array);
				});
			} else {
				callback(null, array);
			}
		});
	}
	/** optional by this.doValConcordance, becuase it takes many minutes to run */
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
		var versDiff = a.verseSeq - b.verseSeq;
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
				result.push({ book:priorBook, chapter:priorChap, verse:priorVers, text:generated.join('') });
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
		output.push([row.book, row.chapter, row.verse, row.text].join(':'));
	}
	this.fs.writeFile('output/' + this.version + '/generated.txt', output.join('\n'), { encoding: 'utf8'}, function(err) {
		if (err) fatalError(err, 'write generated');
	});
};
ConcordanceValidator.prototype.compare = function(generatedText, callback) {
	var that = this;
	var selectStmt = 'SELECT html FROM verses WHERE reference=?'; // BUG: this will skip a verse if absent from concordance.
	var insertStmt = that.db.prepare('INSERT INTO valPunctuation (book, chapter, verse, position, charCode, char) VALUES (?,?,?,?,?,?)');
	iterateEach(0);

	function iterateEach(index) {
		if (index < generatedText.length) {
			var line = generatedText[index];
			var reference = line.book + ':' + line.chapter + ':' + line.verse;
			that.db.get(selectStmt, reference, function(err, row) {
				if (err) callback(err);
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
		var gi = 0;
		for (var oi=0; oi < original.length; oi++) {
			if (generated.charAt(gi) === original.charAt(oi).toLowerCase()) {
				gi++;
			} else if (original.charCodeAt(oi) !== 32) {
				insertStmt.run(book, chapter, verse, oi, original.charCodeAt(oi), original.charAt(oi), function(err) { if (err) that.fatalError(err, 'compareOne'); });
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

var DB_PATH = '../../DBL/3prepared/';
	
if (process.argv.length < 3) {
	console.log('Usage: ./Validator.sh VERSION');
	process.exit(1);
} else {
	var fs = require('fs');
	var filename = DB_PATH + process.argv[2] + '.db';
	console.log('Process ' + filename);
	var val = new ConcordanceValidator(process.argv[2], filename);
	val.open(function(db) {
		val.normalize(function() {
			db.close(function() {
				val.open(function(db) {
					val.summary(function() {
						db.close();
					});
				});
			});
		});
	});
}



