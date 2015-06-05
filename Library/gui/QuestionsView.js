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
		if (results.errno === undefined) {
			that.viewRoot = that.buildQuestionsView();
			this.rootNode.appendChild(this.viewRoot);

			that.questions.checkServer(function(results) {
				that.appendToQuestionView();
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
	var root = document.createElement('div');
	root.setAttribute('id', 'questionsView');
	var numQuestion = this.questions.size();
	for (var i=0; i<numQuestions; i++) {

		//var historyNodeId = this.history.items[i].nodeId;
		//var tab = document.createElement('li');
		//tab.setAttribute('class', 'historyTab');
		//root.appendChild(tab);

		//var btn = document.createElement('button');
		//btn.setAttribute('id', 'his' + historyNodeId);
		//btn.setAttribute('class', 'historyTabBtn');
		//btn.innerHTML = generateReference(historyNodeId);
		//tab.appendChild(btn);
		//btn.addEventListener('click', function(event) {
		//	console.log('btn is clicked ', btn.innerHTML);
		//	var nodeId = this.id.substr(3);
		//	document.body.dispatchEvent(new CustomEvent(BIBLE.TOC_FIND, { detail: { id: nodeId }}));
		//	that.hideView();
		//});
	}
	return(root);
};