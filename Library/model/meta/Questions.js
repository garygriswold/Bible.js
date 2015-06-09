/**
* This class contains the list of questions and answers for this student
* or device.
*/
function Questions(types, bibleCache, tableContents) {
	this.types = types;
	this.bibleCache = bibleCache;
	this.tableContents = tableContents;
	this.items = [];
	this.fullPath = this.types.getAppPath('questions.json');
	Object.seal(this);
}
Questions.prototype.fill = function(itemList) {
	if (itemList) {
		for (var i=0; i<itemList.length; i++) {
			var item = itemList[i];
			item.askedDateTime = new Date(item.askedDateTime);
			item.answeredDateTime = new Date(item.answeredDateTime);
		}
		this.items = itemList;
	}
};
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
	this.write(function(result) {
		callback(result);
	});
};
Questions.prototype.read = function(pageNum, callback) {
	var that = this;
	var reader = new NodeFileReader(this.types.location);
	reader.readTextFile(this.fullPath, function(data) {
		if (data.errno === -2) {
			createActs8Question(function(item) {
				that.items.push(item);
				that.write(function(result) {});
				callback(that);			
			});
		} else if (data.errno) {
			console.log('read questions.json failure ' + JSON.stringify(data));
			callback(data);
		} else {
			var questionList = JSON.parse(data);
			that.fill(questionList);
			callback(that);
		}
	});

	function createActs8Question(callback) {
		var acts8 = new QuestionItem();
		acts8.referenceNodeId = 'ACT:8:30';
		acts8.askedDateTime = new Date();
		var refActs830 = new Reference('ACT:8:30');
		var refActs831 = new Reference('ACT:8:31');
		var refActs835 = new Reference('ACT:8:35');
		acts8.reference = that.tableContents.toString(refActs830);
		var verseActs830 = new VerseAccessor(that.bibleCache, refActs830);
		var verseActs831 = new VerseAccessor(that.bibleCache, refActs831);
		var verseActs835 = new VerseAccessor(that.bibleCache, refActs835);
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
	}
};
Questions.prototype.checkServer = function(callback) {
	var that = this;
	var lastItem = this.items[this.items.length -1];
	if (lastItem.answeredDateTime === null) {
		// send request to the server.

		// if there is an unanswered question, the last item is updated
		that.write(function(result) {
			callback(lastItem);
		});
	}
	else {
		callback(null);
	}
};
Questions.prototype.write = function(callback) {
	var data = this.toJSON();
	var writer = new NodeFileWriter(this.types.location);
	writer.writeTextFile(this.fullPath, data, function(result) {
		if (result.errno) {
			console.log('write questions.json failure ' + JSON.stringify(result));
		}
		callback(result);
	});
};
Questions.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};
