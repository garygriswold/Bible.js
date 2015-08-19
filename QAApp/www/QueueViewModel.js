/**
* This class is the model supportting QueueView.html
*/

function QueueViewModel() {
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
	var numQuestionsNode = document.getElementById("numQuestions");
	console.log('numQuestionsNode', numQuestionsNode);
	if (numQuestionsNode) {
		numQuestionsNode.textContent = this.numQuestionsMsg();
	}
	
	var oldestQuestionNode = document.getElementById("oldestQuestion");
	if (oldestQuestionNode) {
		oldestQuestionNode.textContent = this.oldestQuestionMsg();
	}
	
	var waitTimeNode = document.getElementById("waitTime");
	if (waitTimeNode) {
		waitTimeNode.textContent = this.waitTimeMsg();
	}
};
QueueViewModel.prototype.update = function() {
	// Get current data from the server, and call display() when finished.	
};

