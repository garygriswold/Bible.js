/**
* This file is the unit test for the Questions.js class.
*/
function QuestionsTest() {
	this.types = new AssetType('document', 'WEB');
	this.questions = new Questions(this.types);
	this.readline = require('readline');
	var that = this;
	this.questions.read(0, function(result) {
		processOneQuestion();
	});

	
	function processOneQuestion() {
		that.displayQuestions();
		that.promptForQuestion(function(item) {
			that.questions.addItem(item, function(result) {
				console.log('question added');
				that.displayQuestions();
				that.promptForAnswer(item, function(item) {
					that.questions.write(function(result) {
						console.log('answer added');
						that.displayQuestions();
					});
				});
			});
		});
	}
}
QuestionsTest.prototype.promptForQuestion = function(callback) {
	var item = new QuestionItem();
	item.askedDateTime = new Date();
	var input = this.readline.createInterface(process.stdin, process.stdout);
	input.question('Enter Reference ', function(reference) {
		item.reference = reference;

		input.question('Enter nodeId ', function(nodeId) {
			item.referenceNodeId = nodeId;

			input.question('Enter question ', function(text) {
				item.questionText = text;
				input.close();

				callback(item);
			});
		});
	});
};
QuestionsTest.prototype.promptForAnswer = function(item, callback) {
	var input = this.readline.createInterface(process.stdin, process.stdout);
	input.question('Enter Instructor ', function(instructor) {
		item.instructorName = instructor;

		input.question('Enter Answer ', function(answer) {
			item.answerText = answer;
			input.close();

			item.answeredDateTime = new Date();
			callback(item);
		});
	});
};
QuestionsTest.prototype.displayQuestions = function() {
	console.log('Display Questions');
	var num = this.questions.size();
	for (var i=0; i<num; i++) {
		console.log(this.questions.find(i));
	}
};

var test = new QuestionsTest();
