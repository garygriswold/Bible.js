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
	var that = this;
	var root = document.createElement('ul');
	root.setAttribute('id', 'historyTabBar');
	var numHistory = this.history.size();
	for (var i=numHistory -1; i>=0; i--) {
		var historyNodeId = this.history.items[i].nodeId;
		var tab = document.createElement('li');
		tab.setAttribute('class', 'historyTab');
		root.appendChild(tab);

		var btn = document.createElement('button');
		btn.setAttribute('id', 'his' + historyNodeId);
		btn.setAttribute('class', 'historyTabBtn');
		btn.innerHTML = generateReference(historyNodeId);
		tab.appendChild(btn);
		btn.addEventListener('click', function(event) {
			console.log('btn is clicked ', btn.innerHTML);
			var nodeId = this.id.substr(3);
			document.body.dispatchEvent(new CustomEvent(BIBLE.TOC_FIND, { detail: { id: nodeId }}));
		});
	}
	return(root);

	function generateReference(nodeId) {
		var ref = new Reference(nodeId);
		var book = that.tableContents.find(ref.book);
		if (ref.verse) {
			return(book.abbrev + ' ' + ref.chapter + ':' + ref.verse);
		} else {
			return(book.abbrev + ' ' + ref.chapter);
		}
	}
};
HistoryView.prototype.updateHistoryView = function() {

};
