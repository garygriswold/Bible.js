/**
* This class provides the user interface to the question and answer feature.
* This view class differs from some of the others in that it does not try
* to keep the data in memory, but simply reads the data from a file when
* needed.  Because the question.json file could become large, this approach
* is essential.
*/
function QuestionsView(types) {
	this.questions = new Questions(types);
	this.viewRoot = null;
	this.rootNode = document.getElementById('questionsRoot');
	Object.seal(this);
}
QuestionsView.prototype.showView = function() {
	var that = this;
	this.questions.read(0, function(results) {
		if (results === undefined || results.errno === undefined) {
			that.viewRoot = that.buildQuestionsView();
			that.rootNode.appendChild(that.viewRoot);

			that.questions.checkServer(function(results) {
				//that.appendToQuestionView();
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
	console.log('numQuestions', numQuestions);
	for (var i=0; i<numQuestions; i++) {
		var item = this.questions.find(i);

		var aQuestion = document.createElement('div');
		aQuestion.setAttribute('id', 'que' + i);
		aQuestion.setAttribute('class', 'oneQuestion');
		root.appendChild(aQuestion);

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

		aQuestion.addEventListener('click', displayAnswerOnRequest);
	}
	return(root);

	function displayAnswerOnRequest(event) {
		console.log('selected', this.id);
		var selectedId = this.id;
		var idNum = selectedId.substr(3);
		item = that.questions.find(idNum);

		var selected = document.getElementById(this.id);
		selected.removeEventListener('click', displayAnswerOnRequest);

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

	function includeActs8() {

	}
};