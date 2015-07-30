/**
* This class provides the user interface to display history as tabs,
* and to respond to user interaction with those tabs.
*/

function HistoryView(historyAdapter, tableContents) {
	this.historyAdapter = historyAdapter;
	this.tableContents = tableContents;
	this.viewRoot = null;
	this.rootNode = document.getElementById('historyRoot');
	Object.seal(this);
}
HistoryView.prototype.showView = function(callback) {
	if (this.viewRoot) {
	 	if (this.historyAdapter.lastSelectCurrent) {
	 		TweenMax.to(this.rootNode, 0.7, { left: "0px", onComplete: callback });
	 	} else {
			this.rootNode.removeChild(this.viewRoot);
			this.buildHistoryView(function(result) {
				installView(result);
			});
		}
	} else {
		this.buildHistoryView(function(result) {
			installView(result);
		});
	}
	var that = this;
	function installView(root) {
		that.viewRoot = root;
		that.rootNode.appendChild(that.viewRoot);
		TweenMax.to(that.rootNode, 0.7, { left: "0px", onComplete: callback });
	}
};
HistoryView.prototype.hideView = function(callback) {
	var rect = this.rootNode.getBoundingClientRect();
	if (rect.left > -150) {
		TweenMax.to(this.rootNode, 0.7, { left: "-150px", onComplete: callback });
	} else {
		callback();
	}
};
HistoryView.prototype.buildHistoryView = function(callback) {
	var that = this;
	var root = document.createElement('ul');
	root.setAttribute('id', 'historyTabBar');
	this.historyAdapter.selectAll(function(results) {
		if (results instanceof IOError) {
			callback(root);
		} else {
			for (var i=0; i<results.length; i++) {
				var historyNodeId = results[i];
				var tab = document.createElement('li');
				tab.setAttribute('class', 'historyTab');
				root.appendChild(tab);

				var btn = document.createElement('button');
				btn.setAttribute('id', 'his' + historyNodeId);
				btn.setAttribute('class', 'historyTabBtn');
				btn.textContent = generateReference(historyNodeId);
				tab.appendChild(btn);
				btn.addEventListener('click', function(event) {
					console.log('btn is clicked ', btn.innerHTML);
					var nodeId = this.id.substr(3);
					document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId }}));
					that.hideView();
				});
			}
			callback(root);
		}
	});

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

