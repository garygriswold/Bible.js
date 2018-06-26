/**
* This class provides the user interface to display history as tabs,
* and to respond to user interaction with those tabs.
*/
var TAB_STATE = { HIDDEN:0, SHOW:1, VISIBLE:2, HIDE:3 };

function HistoryView(historyAdapter, tableContents, localizeNumber) {
	this.historyAdapter = historyAdapter;
	this.tableContents = tableContents;
	this.localizeNumber = localizeNumber;
	this.tabState = TAB_STATE.HIDDEN;
	this.viewRoot = null;
	this.rootNode = document.createElement('div');
	this.rootNode.id = 'historyRoot';
	document.body.appendChild(this.rootNode);
	this.historyTabStart = '';
	Object.seal(this);
}
HistoryView.prototype.showView = function(callback) {
	if (this.tabState === TAB_STATE.HIDE) {
		TweenMax.killTweensOf(this.rootNode);
	}
	if (this.tabState === TAB_STATE.HIDDEN || this.tabState === TAB_STATE.HIDE) {
		this.tabState = TAB_STATE.SHOW;
		var that = this;
		if (this.viewRoot) {
		 	if (this.historyAdapter.lastSelectCurrent) {
		 		animateShow();
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
	}

	function installView(root) {
		that.viewRoot = root;
		that.rootNode.appendChild(that.viewRoot);
		that.historyTabStart = '-' + String(Math.ceil(root.getBoundingClientRect().width)) + 'px';
		animateShow();
	}
	function animateShow() {
		TweenMax.set(that.rootNode, { left: that.historyTabStart });
		TweenMax.to(that.rootNode, 0.7, { left: "0px", onComplete: animateComplete });		
	}
	function animateComplete() {
		that.tabState = TAB_STATE.VISIBLE;
	}
};
HistoryView.prototype.hideView = function() {
	if (this.tabState === TAB_STATE.SHOW) {
		TweenMax.killTweensOf(this.rootNode);
	}
	if (this.tabState === TAB_STATE.VISIBLE || this.tabState === TAB_STATE.SHOW) {
		this.tabState = TAB_STATE.HIDE;
		var that = this;
		TweenMax.to(this.rootNode, 0.7, { left: this.historyTabStart, onComplete: animateComplete });
	}
	
	function animateComplete() {
		TweenMax.set(that.rootNode, { left: '-1000px' });
		that.tabState = TAB_STATE.HIDDEN;
	}
};
HistoryView.prototype.buildHistoryView = function(callback) {
	var that = this;
	var root = document.createElement('ul');
	root.setAttribute('id', 'historyTabBar');
	this.historyAdapter.selectPassages(function(results) {
		if (results instanceof IOError) {
			callback(root);
		} else {
			for (var i=0; i<results.length; i++) {
				var historyNodeId = results[i];
				var content = generateReference(historyNodeId);
				if (content) {
					var tab = document.createElement('li');
					tab.setAttribute('class', 'historyTab');
					root.appendChild(tab);
	
					var btn = document.createElement('button');
					btn.setAttribute('id', 'his' + historyNodeId);
					btn.setAttribute('class', 'historyTabBtn');
					btn.textContent = content;
					tab.appendChild(btn);
					btn.addEventListener('click', function(event) {
						console.log('btn clicked', this.id);
						var nodeId = this.id.substr(3);
						document.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId }}));
						that.hideView();
					});
				}
			}
			callback(root);
		}
	});

	function generateReference(nodeId) {
		var ref = new Reference(nodeId);
		var book = that.tableContents.find(ref.book);
		return((book) ? book.abbrev + ' ' + that.localizeNumber.toHistLocal(ref.chapterVerse()) : null);
	}
};

