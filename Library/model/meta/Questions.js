/**
* This class contains the list of questions and answers for this student
* or device.
*/
function Questions(collection, bibleCache, tableContents) {
	this.collection = collection;
	this.bibleCache = bibleCache;
	this.tableContents = tableContents;
	this.items = [];
	Object.seal(this);
}
Questions.prototype.size = function() {
	return(this.items.length);
};
Questions.prototype.find = function(index) {
	return((index >= 0 && index < this.items.length) ? this.items[index] : null);
};
Questions.prototype.addItem = function(questionItem, callback) {
	this.items.push(questionItem);
	// This method must add to the file, as well as add to the server
	// callback when the addQuestion, either succeeds or fails.
	this.insert(questionItem, function(result) {
		callback(result);
	});
};
Questions.prototype.fill = function(callback) {
	var that = this;
	var statement = 'select askedDateTime, book, chapter, verse, question, instructor, answerDateTime, answer ' +
		'from questions order by askedDateTime';
	this.collection.select(statement, [], function(results) {
		if (results instanceof IOError) {
			console.log('select questions failure ' + JSON.stringify(results));
			callback(results);
		} else {
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				var ref = new Reference(row.book, row.chapter, row.verse);
				var ques = new QuestionItem(ref, ref.nodeId, row.question, row.askedDt, row.instructor, row.answerDt, row.answer);
				that.items.push(ques);
			}
			callback(results);
		}
	});
};
Questions.prototype.createActs8Question = function(callback) {
	var acts8 = new QuestionItem();
	acts8.nodeId = 'ACT:8:30';
	acts8.askedDateTime = new Date();
	var refActs830 = new Reference('ACT:8:30');
	var refActs831 = new Reference('ACT:8:31');
	var refActs835 = new Reference('ACT:8:35');
	acts8.reference = this.tableContents.toString(refActs830);
	var verseActs830 = new VerseAccessor(this.bibleCache, refActs830);
	var verseActs831 = new VerseAccessor(this.bibleCache, refActs831);
	var verseActs835 = new VerseAccessor(this.bibleCache, refActs835);
	verseActs830.getVerse(function(textActs830) {
		acts8.questionText = textActs830;
		verseActs831.getVerse(function(textActs831) {
			acts8.questionText += textActs831;
			verseActs835.getVerse(function(textActs835) {
				acts8.answerText = textActs835;
				acts8.answeredDateTime = new Date();
				acts8.instructorName = '';
				callback(acts8);
			});
		});
	});
};
Questions.prototype.checkServer = function(callback) {
	var that = this;
	var lastItem = this.items[this.items.length -1];
	if (lastItem.answeredDateTime === null) {
		// send request to the server.

		// if there is an unanswered question, the last item is updated
		that.update(function(err) {
			callback();
		});
	}
	else {
		callback(null);
	}
};
Questions.prototype.insert = function(item, callback) {
	var statement = 'insert into questions(askedDateTime, book, chapter, verse, question) ' +
		'values (?,?,?,?,?)';
	var ref = new Reference(item.nodeId);
	var values = [ item.askedDateTime.toISOString(), ref.book, ref.chapter, ref.verse, item.questionText ];
	this.collection.replace(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('Error on Insert');
			callback(results)
		} else if (results.rowsAffected === 0) {
			console.log('nothing inserted');
			callback(new IOError(1, 'No rows were inserted in questions'));
		} else {
			callback();
		}
	});
};
Questions.prototype.update = function(callback) {
	var statement = 'update questions set instructor = ?, answerDateTime = ?, answer = ?' +
		'where askedDateTime = ?';
	var values = [ item.instructor, item.answerDateTime.toISOString(), item.answerText, item.askedDateTime.toISOString() ];
	this.collection.update(statement, values, function(results) {
		if (err instanceof IOError) {
			console.log('Error on update');
			callback(err);
		} else if (results.rowsAffected === 0) {
			callback(new IOError(1, 'No rows were update in questions'));
		} else {
			callback();
		}
	});
};
Questions.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};
