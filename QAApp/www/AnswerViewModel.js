/**
* This class is the model supportting AnswerView.html
*/

function AnswerViewModel(httpClient) {
	this.httpClient = httpClient;
	this.discourseId = null;
	this.displayReference = null;
	this.submittedDt = null;
	this.expires = null;
	this.question = null;
	this.answer = null;
	this.teacherId = 'ABCDE';
	this.versionId = 'KJV';
	Object.seal(this);
}
AnswerViewModel.prototype.display = function() {
	setNodeValue('displayReference', 'value', this.displayReference);
	setNodeValue('submittedDt', 'value', this.submittedDt);
	setNodeValue('expiresDesc', 'value', this.expired);
	setNodeValue('question', 'textContent', this.question);
	setNodeValue('answer', 'textContent', this.answer);
	
	function setNodeValue(nodeId, type, property) {
		var node = document.getElementById(nodeId);
		if (node) {
			node[type] = property;
		}
	}
};
AnswerViewModel.prototype.assignQuestion = function() {
	var that = this;
	this.httpClient.get('/assign/' + this.teacherId + '/' + this.versionId, function(status, results) {
		console.log('assign results', status, results);
		if (status === 200) {
			that.discourseId = results.discourseId;
			that.displayReference = results.reference;
			var timestamp = new Date(results.timestamp);
			that.submittedDt = timestamp.toLocaleString();
			that.question = results.message;

			that.display();
		} 
	});	
};
AnswerViewModel.prototype.getDraft = function() {
	
};

AnswerViewModel.prototype.assignAnother = function() {
	// first call return assigned
	// then call assign inside return
};

