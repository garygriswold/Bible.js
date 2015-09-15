/**
* This class is the model supportting AnswerView.html
*/

function AnswerViewModel(viewNavigator) {
	this.viewNavigator = viewNavigator;
	this.httpClient = viewNavigator.httpClient;
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
/** It seems like this function might not be correctly distinquishing between questions and answers */
AnswerViewModel.prototype.setProperties = function(status, results) {
	var that = this;
	if (status === 200) {
		if (results.length) {
			firstRow(results[0]);
			if (results.length > 1) secondRow(results[1]);
		} else {
			firstRow(results);
		}
		this.display();
	}
	
	function firstRow(row) {
		that.discourseId = row.discourseId;
		that.displayReference = row.reference;
		var timestamp = new Date(row.timestamp);
		that.submittedDt = timestamp.toLocaleString();
		that.question = row.message;		
	}
	function secondRow(row) {
		that.answer = row.message;
	}
};
AnswerViewModel.prototype.assignQuestion = function() {
	var that = this;
	this.httpClient.get('/assign/' + this.teacherId + '/' + this.versionId, function(status, results) {
		that.setProperties(status, results);
	});	
};
AnswerViewModel.prototype.getDraft = function() {
	
};

AnswerViewModel.prototype.assignAnother = function() {
	// first call return assigned
	// then call assign inside return
};

