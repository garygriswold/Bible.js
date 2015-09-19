/**
* This class is the model supportting QueueView.html
*/

function QueueViewModel(viewNavigator) {
	this.viewNavigator = viewNavigator;
	this.httpClient = viewNavigator.httpClient;
	this.state = viewNavigator.currentState;
	this.numQuestions = 0;
	this.oldestQuestion = null;
	this.waitTime = 0;
	Object.seal(this);
}
QueueViewModel.prototype.numQuestionsMsg = function() {
	switch(this.numQuestions) {
		case 0:
			return('There are no unanswered questions.');
		case 1:
			return('There is one unassigned question.' );
		default:
			return('There are ' + this.numQuestions + ' unassigned questions.');
	}
};
QueueViewModel.prototype.oldestQuestionMsg = function() {
	return((this.oldestQuestion && this.numQuestions > 0) ? "The oldest question was submitted at " + this.oldestQuestion + "." : '');
};
QueueViewModel.prototype.waitTimeMsg = function() {
	return((this.waitTime && this.numQuestions > 0) ? "The oldest question has been waiting " + this.waitTime + " minutes." : '');
};

QueueViewModel.prototype.display = function() {
	setNodeValue('numQuestions', this.numQuestionsMsg());
	setNodeValue('oldestQuestion', this.oldestQuestionMsg());
	setNodeValue('waitTime', this.waitTimeMsg());
	
	var assignedBtn = document.getElementById('assign');
	if (this.numQuestions > 0) {
		assignedBtn.removeAttribute('disabled');
	} else {
		assignedBtn.setAttribute('disabled');
	}
	
	function setNodeValue(nodeId, property) {
		var node = document.getElementById(nodeId);
		if (node) {
			node.textContent = property;
		}
	}
};
QueueViewModel.prototype.setProperties = function(status, results) {
	console.log('open results', status, results);
	if (status === 200) {
		this.numQuestions = results.count;
		var timestamp = new Date(results.timestamp);
		this.oldestQuestion = timestamp.toLocaleString();
		var lapsed = new Date().getTime() - timestamp.getTime();
		this.waitTime = Math.round(lapsed / (1000 * 60));
		
		this.display();
	}
};
QueueViewModel.prototype.openQuestionCount = function() {
	var that = this;
	this.httpClient.get('/open/' + this.state.teacherId + '/' + this.state.versionId, function(status, results) {
		if (status === 200 && results.count) {
			that.setProperties(status, results);
		} else {
			TweenMax.killAll();
			that.viewNavigator.transition('queueView', 'answerView', 'setProperties', TRANSITION.SLIDE_LEFT, status, results);
		}
	});
};
QueueViewModel.prototype.returnQuestion = function() {
	var that = this;
	var postData = {versionId:this.state.versionId, discourseId:this.state.discourseId};
	this.httpClient.post('/return', postData, function(status, results) {
		that.setProperties(status, results);
	});
};
QueueViewModel.prototype.sendAnswer = function() {
	var that = this;
	var answer = getNodeValue('answer', 'value');
	var postData = {discourseId:this.state.discourseId, versionId:this.state.versionId, timestamp:this.state.answerTimestamp, reference:null, message:answer};
	this.httpClient.post('/answer', postData, function(status, results) {
		that.setProperties(status, results);
	});
	
	function getNodeValue(nodeId, type) {
		var node = document.getElementById(nodeId);
		return((node) ? node[type] : null);
	}
};


