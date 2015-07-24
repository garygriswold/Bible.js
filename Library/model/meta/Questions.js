/**
* This class contains the list of questions and answers for this student
* or device.
*/
function Questions(questionsAdapter, versesAdapter, tableContents) {
	this.questionsAdapter = questionsAdapter;
	this.versesAdapter = versesAdapter;
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
	// This method must add to the database, as well as add to the server
	// callback when the addQuestion, either succeeds or fails.
	this.insert(questionItem, function(result) {
		callback(result);
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
	acts8.book = 'ACT';
	acts8.chapter = 8;
	acts8.verse = 30;
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
			acts8.question = acts830.html + ' ' + acts831.html;
			acts8.answer = acts835.html;
			acts8.instructor = '';
			acts8.answerDateTime = new Date();
			callback(acts8);
		}
	});
};
Questions.prototype.checkServer = function(callback) {
	var that = this;
	var lastItem = this.items[this.items.length -1];
	if (lastItem.answeredDateTime === null) {
		// send request to the server.

		
		if (lastItem.answeredDateTime) { // if updated by server
			that.update(lastItem, function(err) {
				callback();
			});
		} else {
			callback();
		}
	}
	else {
		callback();
	}
};
Questions.prototype.insert = function(item, callback) {
	this.questionsAdapter.replace(item, function(results) {
		if (results instanceof IOError) {
			console.log('Error on Insert');
			callback(results);
		} else {
			callback();
		}
	});
};
Questions.prototype.update = function(item, callback) {
	this.questionsAdapter.update(item, function(results) {
		if (results instanceof IOError) {
			console.log('Error on update', results);
			callback(results);
		} else {
			callback(results);
		}
	});
};
Questions.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};
