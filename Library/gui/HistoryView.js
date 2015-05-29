/**
* This class provides the user interface to display history as tabs,
* and to respond to user interaction with those tabs.
*/

function HistoryView(history, tableContents) {
	this.history = history;
	this.tableContents = tableContents;
	this.viewRoot = null;
	this.rootNode = document.getElementById('historyRoot');
	Object.seal(this);
}
HistoryView.prototype.showView = function() {
	if (this.viewRoot) {
		this.updateHistoryView();
		if (this.rootNode.children.length < 1) {
			this.rootNode.appendChild(this.viewRoot);
		}
	} else {
		this.viewRoot = this.buildHistoryView();
	}
	this.rootNode.appendChild(this.viewRoot);
};
HistoryView.prototype.hideView = function() {
	for (var i=this.rootNode.children.length -1; i>=0; i--) {
		this.rootNode.removeChild(this.rootNode.children[i]);
	}
};
HistoryView.prototype.buildHistoryView = function() {
	var root = document.createElement('div');
	root.setAttribute('class', 'tabs');
	var numHistory = this.history.size();
	for (var i=numHistory -1; i>=0; i--) {
		var tab = document.createElement('div');
		tab.setAttribute('class', 'tab');
		root.appendChild(tab);

		var historyNodeId = this.history.items[i].nodeId;
		var btn = document.createElement('input');
		btn.setAttribute('type', 'radio');
		btn.setAttribute('id', 'his' + historyNodeId);
		btn.setAttribute('name', 'history-group');
		tab.appendChild(btn);

		var that = this;
		var label = document.createElement('label');
		label.setAttribute('for', 'his' + historyNodeId);
		label.innerHTML = generateReference(historyNodeId);
		tab.appendChild(label);
	}
	return(root);

	function generateReference(nodeId) {
		console.log('nodeId', nodeId);
		var ref = new Reference(nodeId);
		console.log('ref', ref.book);
		var book = that.tableContents.find(ref.book);
		console.log(book);
		if (ref.verse) {
			return(book.abbrev + ' ' + ref.chapter + ':' + ref.verse);
		} else {
			return(book.abbrev + ' ' + ref.chapter);
		}
	}
};
HistoryView.prototype.updateHistoryView = function() {

};
