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
	 	if (! this.history.isViewCurrent) {
			this.rootNode.removeChild(this.viewRoot);
			this.viewRoot = this.buildHistoryView();
		}
	} else {
		this.viewRoot = this.buildHistoryView();
	}
	this.history.isViewCurrent = true;
	this.rootNode.appendChild(this.viewRoot);
	TweenLite.to(this.rootNode, 0.7, { left: "0px" });
};
HistoryView.prototype.hideView = function() {
	var rect = this.rootNode.getBoundingClientRect();
	if (rect.left > -150) {
		TweenLite.to(this.rootNode, 0.7, { left: "-150px" });
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
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId }}));
			that.hideView();
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

