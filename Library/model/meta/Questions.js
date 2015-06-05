/**
* This class contains the list of questions and answers for this student
* or device.
*/
function Questions(types) {
	this.types = types;
	this.items = [];
	this.fullPath = this.types.getAppPath('questions.json');
	Object.seal(this);
}
Questions.prototype.fill = function(itemList) {
	this.items = itemList;
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
		if (data.errno) {
			console.log('read questions.json failure ' + JSON.stringify(data));
			callback(data);
		} else {
			var questionList = JSON.parse(data);
			that.fill(questionList);
			callback(this);
		}
	});
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
		console.log('write result', result);
		callback(result);
	});
};
Questions.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};
