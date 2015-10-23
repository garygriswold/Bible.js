/**
* This class is the model supportting QueueView.html
*/
"use strict";
function QueueViewModel(viewNavigator) {
	this.viewNavigator = viewNavigator;
	this.httpClient = viewNavigator.httpClient;
	this.state = viewNavigator.currentState;
	this.queueCounts = null;
	Object.seal(this);
}
QueueViewModel.prototype.display = function() {
	var that = this;
	var root = document.getElementById('queueTables');
	if (! this.state.canManageRoles()) {
		removeManageRoles();
	}
	if (this.queueCounts && this.queueCounts.length) {
		for (var i=0; i<this.queueCounts.length; i++) {
			var row = this.queueCounts[i];
			if (this.state.canSeeAllVersions() || this.state.canSeeVersion(row.versionId)) {
				displayOneQueueCount(root, row);
			}
		}
	}
	
	function removeManageRoles() {
		var btn = document.getElementById('manageBtn');
		if (btn && btn.parentNode) {
			btn.parentNode.removeChild(btn);
		}	
	}
	function displayOneQueueCount(parent, queue) {
		var table = addNode(parent, 'table');
		
		var row1 = addNode(table, 'tr');
		var vers = addNode(row1, 'th', queue.versionId);
		vers.setAttribute('colspan', 3);
		
		var row2 = addNode(table, 'tr');
		var head1 = addNode(row2, 'th', 'Unanswered Questions');
		head1.setAttribute('style', 'width:25%');
		var head2 = addNode(row2, 'th', 'Oldest Question');
		head2.setAttribute('style', 'width:50%');
		var head3 = addNode(row2, 'th', 'Minutes Waiting');
		head3.setAttribute('style', 'width:25%');
		
		var row3 = addNode(table, 'tr');
		addNode(row3, 'td', queue.count);
		var timestamp = new Date(queue.timestamp);
		addNode(row3, 'td', timestamp.toLocaleString());
		var lapsed = new Date().getTime() - timestamp.getTime();
		var waiting = Math.round(lapsed / (1000 * 60));
		addNode(row3, 'td', waiting);
		
		if (that.state.canAnswer(queue.versionId)) {
			var row4 = addNode(table, 'tr');
			var rtd4 = addNode(row4, 'td');
			rtd4.setAttribute('colspan', 3);
			var bttn = addNode(rtd4, 'button', 'Assign Me A Question');
			bttn.setAttribute('id', 'assign' + queue.versionId);
			bttn.setAttribute('class', 'button bigrounded blue');
			bttn.addEventListener('click', function(event) {
				assignQuestion(this.id.substr(6));
			});
		}
	}
	function addNode(parent, elementType, content) {
		var element = document.createElement(elementType);
		element.setAttribute('class', 'queue');
		if (content) {
			element.textContent = content;
		}
		parent.appendChild(element);
		return(element);
	}
};
QueueViewModel.prototype.setProperties = function(status, results) {
	if (status === 200) {
		this.queueCounts = results;
		this.display();
	}
};
QueueViewModel.prototype.openQuestionCount = function() {
	var that = this;
	this.httpClient.get('/open', function(status, results) {
		if (status !== 200) {
			if (results.message) window.alert(results.message);
			else window.alert('unknown error');
		}
		if (results.positions) that.state.setRoles(results.positions);
		if (results.queue) that.setProperties(status, results.queue);
		else if (results.assigned) {
			TweenMax.killAll();
			that.viewNavigator.transition('queueView', 'answerView', 'setProperties', TRANSITION.SLIDE_LEFT, status, results.assigned);
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


