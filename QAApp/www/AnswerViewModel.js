/**
* This class is the model supportting AnswerView.html
*/

function AnswerViewModel() {
	this.studentName = 'Bob';
	this.displayReference = 'John 3:16';
	this.submittedDt = 'Jan 3, 2015 10:43 am';
	this.expires = '2 hrs';
	this.question = 'How can I understand unless someone show me.';
	this.answer = 'Here is Isahiah';
	Object.seal(this);
}
AnswerViewModel.prototype.display = function() {
	setNodeValue('studentName', 'value', this.studentName);
	setNodeValue('displayReference', 'value', this.displayReference);
	setNodeValue('submittedDt', 'value', this.submittedDt);
	setNodeValue('expiresDesc', 'value', this.expired);
	setNodeValue('question', 'textContent', this.question);
	setNodeValue('answer', 'textContent', this.answer);
	
	function setNodeValue(nodeId, type, property) {
		var node = document.getElementById(nodeId);
		if (node) {
			switch(type) {
				case 'value':
					node.value = property;
					break;
				case 'textContent':
					node.textContent = property;
					break;
			}
		}
	}
};
AnswerViewModel.prototype.update = function() {
	// Get current data from the server, and call display() when finished.	
};

