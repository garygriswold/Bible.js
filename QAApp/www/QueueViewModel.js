/**
* This class is the model supportting QueueView.html
*/

function QueueViewModel(httpClient) {
	this.httpClient = httpClient;
	this.numQuestions = 25;
	this.oldestQuestion = 'Aug 24, 2016, 8:23 AM';
	this.waitTime = 10;
	Object.seal(this);
	console.log('INSIDE QUEUE VIEW MODEL CONSTRICTOR' )
}
QueueViewModel.prototype.numQuestionsMsg = function() {
	return("There are " + this.numQuestions + " unassigned questions.");
};
QueueViewModel.prototype.oldestQuestionMsg = function() {
	return((this.oldestQuestion && this.numQuestions > 0) ? "The oldest question was submitted at " + this.oldestQuestion + "." : '');
};
QueueViewModel.prototype.waitTimeMsg = function() {
	return((this.waitTime && this.numQuestions > 0) ? "The oldest question has been waiting " + this.waitTime + " hours." : '');
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
QueueViewModel.prototype.queueCount = function() {
	// Get current data from the server, and call display() when finished.	
};


