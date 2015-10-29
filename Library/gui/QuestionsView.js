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
					that.questions.addItemLocal(item, function(error) {
						presentView();
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
			displayAnswer(aQuestion);
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
		instructor.textContent = item.instructor;
		answerTop.appendChild(instructor);

		var ansDate = document.createElement('p');
		ansDate.setAttribute('class', 'ansDate');
		ansDate.textContent = formatter.localDatetime(item.answerDateTime);
		answerTop.appendChild(ansDate);

		var answer = document.createElement('p');
		answer.setAttribute('class', 'ansText');
		answer.textContent = item.answer;
		selected.appendChild(answer);
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

			that.questions.addItem(item, function(error) {
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