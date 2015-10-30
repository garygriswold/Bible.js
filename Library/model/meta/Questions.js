/**
* This class contains the list of questions and answers for this student
* or device.
*/
function Questions(questionsAdapter, versesAdapter, tableContents) {
	this.questionsAdapter = questionsAdapter;
	this.versesAdapter = versesAdapter;
	this.tableContents = tableContents;
	this.httpClient = new HttpClient(SERVER_HOST, SERVER_PORT);
	this.items = [];
	Object.seal(this);
}
Questions.prototype.size = function() {
	return(this.items.length);
};
Questions.prototype.find = function(index) {
	return((index >= 0 && index < this.items.length) ? this.items[index] : null);
};
Questions.prototype.addQuestion = function(item, callback) {
	var that = this;
	var versionId = this.questionsAdapter.database.code;
	var postData = {versionId:versionId, displayRef:item.displayRef, message:item.question};
	this.httpClient.put('/question', postData, function(status, results) {
		if (status !== 200 && status !== 201) {
			callback(results);
		} else {
			item.discourseId = results.discourseId;
			item.askedDateTime = new Date(results.timestamp);
			that.addQuestionLocal(item, callback);
		}
	});
};
Questions.prototype.addQuestionLocal = function(item, callback) {
	var that = this;
	this.questionsAdapter.replace(item, function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else {
			that.items.push(item);
			callback();
		}
	});
};
Questions.prototype.addAnswerLocal = function(item, callback) {
	this.questionsAdapter.update(item, function(results) {
		if (results instanceof IOError) {
			console.log('Error on update', results);
			callback(results);
		} else {
			callback();
		}
	});
};
Questions.prototype.fill = function(callback) {
	var that = this;
	this.questionsAdapter.selectAll(function(results) {
		if (results instanceof IOError) {
			console.log('select questions failure ' + JSON.stringify(results));
			callback(results);
		} else {
			that.items = results;
			callback(results);// needed to determine if zero length result
		}
	});
};
Questions.prototype.createActs8Question = function(callback) {
	var acts8 = new QuestionItem();
	acts8.reference = 'ACT:8:30';
	acts8.askedDateTime = new Date();
	var refActs830 = new Reference('ACT:8:30');
	acts8.displayRef = this.tableContents.toString(refActs830);
	var verseList = [ 'ACT:8:30', 'ACT:8:31', 'ACT:8:35' ];
	this.versesAdapter.getVerses(verseList, function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else {
			var acts830 = results.rows.item(0);
			var acts831 = results.rows.item(1);
			var acts835 = results.rows.item(2);
			acts8.discourseId = 'NONE';
			acts8.question = acts830.html + ' ' + acts831.html;
			acts8.answer = acts835.html;
			acts8.instructor = 'Philip';
			acts8.answerDateTime = new Date();
			callback(acts8);
		}
	});
};
Questions.prototype.checkServer = function(callback) {
	var that = this;
	var unanswered = findUnansweredQuestions();
	var discourseIds = Object.keys(unanswered);
	if (discourseIds.length > 0) {
		var path = '/response/' + discourseIds.join('/');
		this.httpClient.get(path, function(status, results) {
			if (status === 200) {
				var indexes = updateAnsweredQuestions(unanswered, results);
				callback(indexes);
			} else {
				callback([]);
			}
		});
	} else {
		callback([]);
	}
	function findUnansweredQuestions() {
		var indexes = {};
		for (var i=0; i<that.items.length; i++) {
			var item = that.items[i];
			if (item.answerDateTime === null || item.answerDateTime === undefined) {
				indexes[item.discourseId] = i;
			}
		}
		return(indexes);
	}
	function updateAnsweredQuestions(unanswered, results) {
		var indexes = [];
		for (var i=0; i<results.length; i++) {
			var row = results[i];
			var itemId = unanswered[row.discourseId];
			var item = that.items[itemId];
			if (item.discourseId !== row.discourseId) {
				console.log('Attempt to update wrong item in Questions.checkServer');
			} else {
				item.instructor = row.pseudonym;
				item.answerDateTime = row.timestamp;
				item.answer = row.message;
				indexes.push(itemId);
			}
		}
		return(indexes);
	}
};
Questions.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};
