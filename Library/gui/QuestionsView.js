/**
* This class provides the user interface to the question and answer feature.
* This view class differs from some of the others in that it does not try
* to keep the data in memory, but simply reads the data from a file when
* needed.  Because the question.json file could become large, this approach
* is essential.
*/
function QuestionsView(questionsAdapter, versesAdapter, tableContents) {
	this.tableContents = tableContents;
	this.versesAdapter = versesAdapter;
	this.questions = new Questions(questionsAdapter, versesAdapter, tableContents);
	this.formatter = new DateTimeFormatter();
	this.dom = new DOMBuilder();
	this.viewRoot = null;
	this.rootNode = document.getElementById('questionsRoot');
	this.referenceInput = null;
	this.questionInput = null;
	Object.seal(this);
}
QuestionsView.prototype.showView = function() {
	var that = this;
	document.body.style.backgroundColor = '#FFF';
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
			for (var i=0; i<results.length; i++) {
				var itemId = results[i];
				var questionNode = document.getElementById('que' + itemId);
				that.displayAnswer(questionNode);
			}
		});		
	}
};
QuestionsView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		// why not save scroll position
		for (var i=this.rootNode.children.length -1; i>=0; i--) {
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
		this.viewRoot = null;
	}
};
QuestionsView.prototype.buildQuestionsView = function() {
	var that = this;
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

		var questionBorder = that.dom.addNode(parent, 'div', 'questionBorder');
		var aQuestion = that.dom.addNode(questionBorder, 'div', 'oneQuestion', null, 'que' + i);
		var line1 = that.dom.addNode(aQuestion, 'div', 'queTop');
		that.dom.addNode(line1, 'p', 'queRef', item.reference);
		that.dom.addNode(line1, 'p', 'queDate', that.formatter.localDatetime(item.askedDateTime));
		that.dom.addNode(aQuestion, 'p', 'queText', item.question);

		if (i === numQuestions -1) {
			that.displayAnswer(aQuestion);
		} else {
			aQuestion.addEventListener('click', displayAnswerOnRequest);	
		}
	}
	function displayAnswerOnRequest(event) {
		var selected = document.getElementById(this.id);
		selected.removeEventListener('click', displayAnswerOnRequest);
		that.displayAnswer(selected);
	}
	function includeInputBlock(parentNode) {
		var refTop = that.dom.addNode(parentNode, 'div', 'questionBorder', null, 'quesInput');

		that.referenceInput = that.dom.addNode(refTop, 'input', 'questionField', null, 'inputRef');
		that.referenceInput.setAttribute('type', 'text');
		that.referenceInput.setAttribute('placeholder', 'Reference');

		var inputTop = that.dom.addNode(parentNode, 'div', 'questionBorder');
		that.questionInput = that.dom.addNode(inputTop, 'textarea', 'questionField', null, 'inputText');
		that.questionInput.setAttribute('rows', 10);

		var quesBtn = that.dom.addNode(parentNode, 'button', null, null, 'inputBtn');
		quesBtn.appendChild(drawSendIcon(50, '#F7F7BB'));

		quesBtn.addEventListener('click', function(event) {
			console.log('submit button clicked');

			var item = new QuestionItem();
			item.reference = that.referenceInput.value;
			item.question = that.questionInput.value;

			that.questions.addQuestion(item, function(error) {
				if (error) {
					console.error('error at server', error);
				} else {
					console.log('file is written to disk and server');
					that.viewRoot = that.buildQuestionsView();
					that.rootNode.appendChild(that.viewRoot);
				}
			});
		});
		that.versesAdapter.getVerses(['MAT:7:7'], function(results) {
			if (results instanceof IOError) {
				console.log('Error while getting MAT:7:7');
			} else {
				if (results.rows.length > 0) {
					var row = results.rows.item(0);
					that.questionInput.setAttribute('placeholder', row.html);
				}	
			}
		});
	}
};
QuestionsView.prototype.displayAnswer = function(parent) {
	var idNum = parent.id.substr(3);
	var item = this.questions.find(idNum);

	this.dom.addNode(parent, 'hr', 'ansLine');
	var answerTop = this.dom.addNode(parent, 'div', 'ansTop');
	this.dom.addNode(answerTop, 'p', 'ansInstructor', item.instructor);
	this.dom.addNode(answerTop, 'p', 'ansDate', this.formatter.localDatetime(item.answerDateTime));
	this.dom.addNode(parent, 'p', 'ansText', item.answer);
};
