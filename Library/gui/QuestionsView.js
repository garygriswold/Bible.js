/**
* This class provides the user interface to the question and answer feature.
* This view class differs from some of the others in that it does not try
* to keep the data in memory, but simply reads the data from a file when
* needed.  Because the question.json file could become large, this approach
* is essential.
*/
function QuestionsView(types, bibleCache, tableContents) {
	this.bibleCache = bibleCache;
	this.tableContents = tableContents;
	this.questions = new Questions(types, bibleCache, tableContents);
	this.viewRoot = null;
	this.rootNode = document.getElementById('questionsRoot');
	Object.seal(this);
}
QuestionsView.prototype.showView = function() {
	var that = this;
	this.questions.read(0, function(results) {
		if (results === undefined || results.errno === undefined || results.errno === -2) {
			that.viewRoot = that.buildQuestionsView();
			that.rootNode.appendChild(that.viewRoot);

			that.questions.checkServer(function(results) {
				//that.appendToQuestionView();
				// when a question comes back from the server
				// we are able to display input block.
			});
		}
	});
};
QuestionsView.prototype.hideView = function() {
	for (var i=this.rootNode.children.length -1; i>=0; i--) {
		this.rootNode.removeChild(this.rootNode.children[i]);
	}
	this.viewRoot = null;
	this.questions = null;
};
QuestionsView.prototype.buildQuestionsView = function() {
	var that = this;
	var formatter = new DateTimeFormatter();
	var root = document.createElement('div');
	root.setAttribute('id', 'questionsView');
	var numQuestions = this.questions.size();
	for (var i=0; i<numQuestions; i++) {
		buildOneQuestion(root, i);
	}
	return(root);

	function buildOneQuestion(parent, i) {
		var item = that.questions.find(i);

		var aQuestion = document.createElement('div');
		aQuestion.setAttribute('id', 'que' + i);
		aQuestion.setAttribute('class', 'oneQuestion');
		parent.appendChild(aQuestion);

		var line1 = document.createElement('div');
		line1.setAttribute('class', 'queTop');
		aQuestion.appendChild(line1);

		var reference = document.createElement('p');
		reference.setAttribute('class', 'queRef');
		reference.textContent = item.reference;
		line1.appendChild(reference);

		var questDate = document.createElement('p');
		questDate.setAttribute('class', 'queDate');
		questDate.textContent = formatter.localDatetime(item.askedDateTime);
		line1.appendChild(questDate);

		var question = document.createElement('p');
		question.setAttribute('class', 'queText');
		question.textContent = item.questionText;
		aQuestion.appendChild(question);

		if (i === numQuestions -1) {
			displayAnswer(aQuestion);
		} else {
			aQuestion.addEventListener('click', displayAnswerOnRequest);	
		}
	}

	function displayAnswerOnRequest(event) {
		var selectedId = this.id;
		var selected = document.getElementById(this.id);
		selected.removeEventListener('click', displayAnswerOnRequest);
		displayAnswer(selected);
	}

	function displayAnswer(selected) {
		var idNum = selected.id.substr(3);
		var item = that.questions.find(idNum);

		var line = document.createElement('hr');
		line.setAttribute('class', 'ansLine');
		selected.appendChild(line);

		var answerTop = document.createElement('div');
		answerTop.setAttribute('class', 'ansTop');
		selected.appendChild(answerTop);

		var instructor = document.createElement('p');
		instructor.setAttribute('class', 'ansInstructor');
		instructor.textContent = item.instructorName;
		answerTop.appendChild(instructor);

		var ansDate = document.createElement('p');
		ansDate.setAttribute('class', 'ansDate');
		ansDate.textContent = formatter.localDatetime(item.answeredDateTime);
		answerTop.appendChild(ansDate);

		var answer = document.createElement('p');
		answer.setAttribute('class', 'ansText');
		answer.textContent = item.answerText;
		selected.appendChild(answer);
	}

	function includeInputBlock(parentNode) {
		// create top level div
		// create reference input block
		// create question input block
		// create submit input button
	}
};