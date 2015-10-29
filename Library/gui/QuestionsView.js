/**
* This class provides the user interface to the question and answer feature.
* This view class differs from some of the others in that it does not try
* to keep the data in memory, but simply reads the data from a file when
* needed.  Because the question.json file could become large, this approach
* is essential.
*/
function QuestionsView(questionsAdapter, versesAdapter, tableContents) {
	this.tableContents = tableContents;
	this.questions = new Questions(questionsAdapter, versesAdapter, tableContents);
	this.formatter = new DateTimeFormatter();
	this.viewRoot = null;
	this.rootNode = document.getElementById('questionsRoot');
	this.referenceInput = null;
	this.questionInput = null;
	Object.seal(this);
}
QuestionsView.prototype.showView = function() {
	var that = this;
	this.hideView();
	this.questions.fill(function(results) {
		if (results instanceof IOError) {
			console.log('Error: QuestionView.showView.fill');
		} else {
			if (results.length === 0) {
				that.questions.createActs8Question(function(item) {
					that.questions.addQuestionLocal(item, function(error) {
						that.questions.addAnswerLocal(item, function(error) {
							presentView();
						});
					});
				});
			} else {
				presentView();
			}
		}
	});
	function presentView() {
		that.viewRoot = that.buildQuestionsView();
		that.rootNode.appendChild(that.viewRoot);

		that.questions.checkServer(function(results) {
			//that.appendToQuestionView();
			// when a question comes back from the server
			// we are able to display input block.
		});		
	}
};
QuestionsView.prototype.hideView = function() {
	for (var i=this.rootNode.children.length -1; i>=0; i--) {
		this.rootNode.removeChild(this.rootNode.children[i]);
	}
	this.viewRoot = null;
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
	includeInputBlock(root);
	return(root);

	function buildOneQuestion(parent, i) {
		var item = that.questions.find(i);

		var aQuestion = addNode(parent, 'div', 'que' + i, 'oneQuestion');
		var line1 = addNode(aQuestion, 'div', null, 'queTop');
		var reference = addNode(line1, 'p', null, 'queRef', item.displayRef);
		var questDate = addNode(line1, 'p', null, 'queDate', formatter.localDatetime(item.askedDateTime));
		var question = addNode(aQuestion, 'p', null, 'queText', item.question);
		
		var discId = addNode(aQuestion, 'p', null, null, item.discourseId);

		if (i === numQuestions -1) {
			that.displayAnswer(aQuestion);
		} else {
			aQuestion.addEventListener('click', displayAnswerOnRequest);	
		}
		
		function addNode(parent, type, id, clas, content) {
			var node = document.createElement(type);
			if (id) node.setAttribute('id', id);
			if (clas) node.setAttribute('class', clas);
			if (content) node.textContent = content;
			parent.appendChild(node);
			return(node);
		}
	}

	function displayAnswerOnRequest(event) {
		var selected = document.getElementById(this.id);
		selected.removeEventListener('click', displayAnswerOnRequest);
		that.displayAnswer(selected);
	}
	function includeInputBlock(parentNode) {
		var inputTop = document.createElement('div');
		inputTop.setAttribute('id', 'quesInput');
		parentNode.appendChild(inputTop);

		that.referenceInput = document.createElement('input');
		that.referenceInput.setAttribute('id', 'inputRef');
		that.referenceInput.setAttribute('type', 'text');
		that.referenceInput.setAttribute('placeholder', 'Reference');
		inputTop.appendChild(that.referenceInput);

		that.questionInput = document.createElement('textarea');
		that.questionInput.setAttribute('id', 'inputText');
		that.questionInput.setAttribute('placeholder', 'Matt 7:7 goes here');
		that.questionInput.setAttribute('rows', 10);
		inputTop.appendChild(that.questionInput);

		var quesBtn = document.createElement('button');
		quesBtn.setAttribute('id', 'inputBtn');
		inputTop.appendChild(quesBtn);
		quesBtn.appendChild(drawSendIcon(50, '#777777'));

		quesBtn.addEventListener('click', function(event) {
			console.log('submit button clicked');

			var item = new QuestionItem();
			// set item.reference by position of page
			item.displayRef = that.referenceInput.value;
			item.question = that.questionInput.value;

			that.questions.addQuestion(item, function(error) {
				if (error) {
					console.error('error at server', error);
				} else {
					console.log('file is written to disk and server');
					that.hideView();
					that.viewRoot = that.buildQuestionsView();
					that.rootNode.appendChild(that.viewRoot);
				}
			});
		});
	}
};
QuestionsView.prototype.displayAnswer = function(parent) {
	var idNum = parent.id.substr(3);
	var item = this.questions.find(idNum);
	console.log('displayAnswer', parent.id, parent.id.substr(3), idNum, item);

	var dom = new DOMBuilder();
	dom.addNode(parent, 'hr', 'ansLine');
	var answerTop = dom.addNode(parent, 'div', 'ansTop');
	dom.addNode(answerTop, 'p', 'ansInstructor', item.instructor);
	dom.addNode(answerTop, 'p', 'ansDate', this.formatter.localDatetime(item.answerDateTime));
	dom.addNode(parent, 'p', 'ansText', item.answer);
};
