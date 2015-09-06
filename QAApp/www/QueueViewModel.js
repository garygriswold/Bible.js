/**
* This class is the model supportting QueueView.html
*/

function QueueViewModel(httpClient) {
	this.httpClient = httpClient;
	this.numQuestions = 0;
	this.oldestQuestion = null;
	this.waitTime = 0;
	Object.seal(this);
}
QueueViewModel.prototype.numQuestionsMsg = function() {
	return("There are " + this.numQuestions + " unassigned questions.");
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
	
	function setNodeValue(nodeId, property) {
		var node = document.getElementById(nodeId);
		if (node) {
			node.textContent = property;
		}
	}
};
QueueViewModel.prototype.openQuestionCount = function(versionId) {
	var that = this;
	this.httpClient.get('/open/' + versionId, function(status, results) {
		console.log('open results', status, results);
		if (status === 200) {
			that.numQuestions = results.count;
			var timestamp = new Date(results.timestamp);
			that.oldestQuestion = timestamp.toLocaleString();
			var lapsed = new Date().getTime() - timestamp.getTime();
			that.waitTime = Math.round(lapsed / (1000 * 60));
			that.display();
		} 
	});
};


