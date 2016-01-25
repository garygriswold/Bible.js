"use strict";
/**
* This class contains the Canon of Scripture as 66 books.  It is used to control
* which books are published using this App.  The codes are used to identify the
* books of the Bible, while the names, which are in English are only used to document
* the meaning of each code.  These names are not used for display in the App.
*/
function Canon() {
	this.books = [
    	{ code: 'GEN', name: 'Genesis' },
    	{ code: 'EXO', name: 'Exodus' },
    	{ code: 'LEV', name: 'Leviticus' },
    	{ code: 'NUM', name: 'Numbers' },
    	{ code: 'DEU', name: 'Deuteronomy' },
    	{ code: 'JOS', name: 'Joshua' },
    	{ code: 'JDG', name: 'Judges' },
    	{ code: 'RUT', name: 'Ruth' },
    	{ code: '1SA', name: '1 Samuel' },
    	{ code: '2SA', name: '2 Samuel' },
    	{ code: '1KI', name: '1 Kings' },
    	{ code: '2KI', name: '2 Kings' },
    	{ code: '1CH', name: '1 Chronicles' },
    	{ code: '2CH', name: '2 Chronicles' },
    	{ code: 'EZR', name: 'Ezra' },
    	{ code: 'NEH', name: 'Nehemiah' },
    	{ code: 'EST', name: 'Esther' },
    	{ code: 'JOB', name: 'Job' },
    	{ code: 'PSA', name: 'Psalms' },
    	{ code: 'PRO', name: 'Proverbs' },
    	{ code: 'ECC', name: 'Ecclesiastes' },
    	{ code: 'SNG', name: 'Song of Solomon' },
    	{ code: 'ISA', name: 'Isaiah' },
    	{ code: 'JER', name: 'Jeremiah' },
    	{ code: 'LAM', name: 'Lamentations' },
    	{ code: 'EZK', name: 'Ezekiel' },
    	{ code: 'DAN', name: 'Daniel' },
    	{ code: 'HOS', name: 'Hosea' },
    	{ code: 'JOL', name: 'Joel' },
    	{ code: 'AMO', name: 'Amos' },
    	{ code: 'OBA', name: 'Obadiah' },
    	{ code: 'JON', name: 'Jonah' },
    	{ code: 'MIC', name: 'Micah' },
    	{ code: 'NAM', name: 'Nahum' },
    	{ code: 'HAB', name: 'Habakkuk' },
    	{ code: 'ZEP', name: 'Zephaniah' },
    	{ code: 'HAG', name: 'Haggai' },
    	{ code: 'ZEC', name: 'Zechariah' },
    	{ code: 'MAL', name: 'Malachi' },
    	{ code: 'MAT', name: 'Matthew' },
    	{ code: 'MRK', name: 'Mark' },
    	{ code: 'LUK', name: 'Luke' },
    	{ code: 'JHN', name: 'John' },
    	{ code: 'ACT', name: 'Acts' },
    	{ code: 'ROM', name: 'Romans' },
    	{ code: '1CO', name: '1 Corinthians' },
    	{ code: '2CO', name: '2 Corinthians' },
    	{ code: 'GAL', name: 'Galatians' },
    	{ code: 'EPH', name: 'Ephesians' },
    	{ code: 'PHP', name: 'Philippians' },
    	{ code: 'COL', name: 'Colossians' },
    	{ code: '1TH', name: '1 Thessalonians' },
    	{ code: '2TH', name: '2 Thessalonians' },
    	{ code: '1TI', name: '1 Timothy' },
    	{ code: '2TI', name: '2 Timothy' },
    	{ code: 'TIT', name: 'Titus' },
    	{ code: 'PHM', name: 'Philemon' },
    	{ code: 'HEB', name: 'Hebrews' },
    	{ code: 'JAS', name: 'James' },
    	{ code: '1PE', name: '1 Peter' },
    	{ code: '2PE', name: '2 Peter' },
    	{ code: '1JN', name: '1 John' },
    	{ code: '2JN', name: '2 John' },
    	{ code: '3JN', name: '3 John' },
    	{ code: 'JUD', name: 'Jude' },
    	{ code: 'REV', name: 'Revelation' } ];
}
Canon.prototype.sequenceMap = function() {
	var result = {};
	for (var i=0; i<this.books.length; i++) {
		var item = this.books[i];
		result[item.code] = i;
	}
	return(result);
};
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
		//createValConcordance(function(err) { if (err) that.fatalError(err, 'createValConcordance'); });
		normalizeConcordance(function(err, result) {
			if (err) that.fatalError(err, 'normalizeConcordance')
			var generatedText = that.generate(result);
			that.compare(generatedText, function(err) {
				if (err) that.fatalError(err, 'compare');
				callback();
			});
			//populateValConcordance(result, function(err) {
			//	if (err) that.fatalError(err, 'populateValConcordance');
			//	callback();
			//});
		});	
	});	

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
					var ordinal = that.bookMap[parts[0]];
					for (var k=3; k<parts.length; k++) {
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
	return(result);
};
ConcordanceValidator.prototype.displayText = function(generatedText) {
	for (var i=0; i<generatedText.length; i++) {
		var row = generatedText[i];
		console.log(row.book, row.chapter, row.verse, row.text);
	}	
};
ConcordanceValidator.prototype.compare = function(generatedText, callback) {
	var that = this;
	var selectStmt = 'SELECT html FROM verses WHERE reference=?';
	iterateEach(0);

	function iterateEach(index) {
		if (index < generatedText.length) {
			var line = generatedText[index];
			var reference = line.book + ':' + line.chapter + ':' + line.verse;
			console.log('KEY', reference);
			that.db.get(selectStmt, reference, function(err, row) {
				if (err) callback(err);
				console.log(line.book, line.chapter, line.verse, row.html);
				iterateEach(index + 1);
			});
		} else {
			callback();
		}
	}
};
	
//	function compare(book, chapter, verse, text) {
//		var reference = book + ':' + chapter + ':' + verse;
//		
//		
//	}
//};
ConcordanceValidator.prototype.fatalError = function(err, source) {
	console.log('FATAL ERROR ', err, ' AT ', source);
	process.exit(1);
};
ConcordanceValidator.prototype.completed = function() {
	console.log('COMPLETED');
	this.db.close();
	process.exit(0);
};

var val = new ConcordanceValidator('WEB.db1');
val.open(function() {
	val.normalize(function() {
		val.completed();
	});
});

