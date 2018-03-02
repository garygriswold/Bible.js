/**
* This class contains user interface features for the display of the Bible text
*/
var CODEX_VIEW = {BEFORE: 0, AFTER: 1, MAX: 100000, SCROLL_TIMEOUT: 250};

function CodexView(chaptersAdapter, tableContents, headerHeight, copyrightView) {
	this.chaptersAdapter = chaptersAdapter;
	this.tableContents = tableContents;
	this.headerHeight = headerHeight;
	this.copyrightView = copyrightView;
	this.rootNode = document.createElement('div');
	this.rootNode.id = 'codexRoot';
	document.body.appendChild(this.rootNode);
	this.viewport = this.rootNode;
	this.viewport.style.top = headerHeight + 'px'; // Start view at bottom of header.
	this.currentNodeId = null;
	this.checkScrollID = null;
	this.userIsScrolling = false;
	Object.seal(this);
	var that = this;
	if (deviceSettings.platform() == 'ios') {
		window.addEventListener('scroll', function(event) {
			that.userIsScrolling = true;
		});
	}
}
CodexView.prototype.hideView = function() {
	window.clearTimeout(this.checkScrollID);
	while (this.viewport.firstChild) {
		this.viewport.removeChild(this.viewport.firstChild);
	}
};
CodexView.prototype.showView = function(nodeId) {
	window.clearTimeout(this.checkScrollID);
	document.body.style.backgroundColor = '#FFF';
	var firstChapter = new Reference(nodeId);
	var rowId = this.tableContents.rowId(firstChapter);
	var that = this;
	this.showChapters([rowId, rowId + CODEX_VIEW.AFTER], true, function(err) {
		if (firstChapter.verse) {
			that.scrollTo(firstChapter.nodeId);
		}
		that.currentNodeId = "top" + firstChapter.nodeId;
		document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: firstChapter }}));
		that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT);	// should be last thing to do
		
		document.body.addEventListener(BIBLE.SCROLL_TEXT, function(event) {
			var nodeId = event.detail.id;
			console.log('animateScrollTo', nodeId);
			var verse = document.getElementById(nodeId);
			if (verse) {
				var rect = verse.getBoundingClientRect();
				TweenMax.killTweensOf(window);
				TweenMax.to(window, 0.7, {scrollTo: { y: rect.top + window.scrollY - that.headerHeight, autoKill: false }});
			}
		});
	});
	function onScrollHandler(event) {
		var currNode = identifyCurrentChapter();//expensive solution
		//console.log("currNode top: " + currNode.top + "  mid: " + currNode.middle + "  bot: " + currNode.bottom);
		if (currNode) {
			if (currNode.middle !== that.currentNodeId) {
				that.currentNodeId = currNode.middle;
				var currRef = new Reference(currNode.middle.substr(3));
				document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: currRef }}));
			}
			var firstChildId = that.viewport.firstChild.id;
			var lastChildId = that.viewport.lastChild.id;
			if (currNode.bottom === lastChildId || lastChildId.substr(7,1) === "0") {
				var lastChapter = new Reference(lastChildId.substr(3));
				var rowId = that.tableContents.rowId(lastChapter);
				if (rowId) {
					that.showChapters([rowId + 1], true, function() {
						onScrollLastStep();
					});					
				} else onScrollLastStep();
			}
			else if (currNode.top === firstChildId || firstChildId.substr(7,1) === "0") {
				var firstChapter = new Reference(firstChildId.substr(3));
				var rowId = that.tableContents.rowId(firstChapter);
				if (rowId) {
					that.showChapters([rowId - 1], false, function() {
						onScrollLastStep();
					});
				} else onScrollLastStep();
			} else onScrollLastStep();
		} else onScrollLastStep();
	}
	function onScrollLastStep() {
		that.userIsScrolling = false;
		that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT); // should be last thing to do
	}
	function identifyCurrentChapter() {
		var result = {top: null, middle: null, bottom: null};
		var windowTop = that.headerHeight;
		var windowMid = window.innerHeight / 2;
		var windowBot = window.innerHeight;
		var searchLimit = 0;
		var index = that.viewport.children.length -1;
		var searchLimit = 0;
		while(index >= searchLimit) {
			var node = that.viewport.children[index];
			var rect = node.getBoundingClientRect();
			if (result.bottom === null && rect.top < windowBot) {
				result.bottom = node.id;
			}
			if (result.middle === null && rect.top < windowMid) {
				result.middle = node.id;
			}
			if (rect.bottom > windowTop) {
				result.top = node.id;
			}
			if (result.top && result.middle && searchLimit === 0) {
				// search only three more chapters once top and middle are known
				searchLimit = Math.max(index - 3, 0);
			}
			index--;
		}
		return(result);
	}
};
CodexView.prototype.showChapters = function(chapters, append, callback) {
	var that = this;
	this.chaptersAdapter.getChapters(chapters, function(results) {
		if (results instanceof IOError) {
			console.log((JSON.stringify(results)));
			callback(results);
		} else {
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				var reference = new Reference(row.reference);
				var html = (reference.chapter > 0) ? row.html + that.copyrightView.copyrightNotice : row.html;
				if (append) {
					reference.append(that.viewport, html);
				} else {
					var scrollHeight1 = that.viewport.scrollHeight;
					var scrollY1 = window.scrollY;
					reference.prepend(that.viewport, html);
					//window.scrollTo(0, scrollY1 + that.viewport.scrollHeight - scrollHeight1);
					TweenMax.set(window, {scrollTo: { y: scrollY1 + that.viewport.scrollHeight - scrollHeight1}});
				}
				console.log('added chapter', reference.nodeId);
			}
			callback();
		}
	});
};
/**
* This was written to incrementally eliminate chapters as chapters were added,
* but tests showed that it is possible to have the entire Bible in one scroll
* without a problem.  GNG 12/29/2015, ergo deprecated by setting MAX at 100000.
*/
/*
CodexView.prototype.checkChapterQueueSize = function(whichEnd) {
	if (this.viewport.children.length > CODEX_VIEW.MAX) {
		switch(whichEnd) {
			case 'top':
				var scrollHeight = this.viewport.scrollHeight;
				var discard = this.viewport.firstChild;
				this.viewport.removeChild(discard);
				window.scrollBy(0, this.viewport.scrollHeight - scrollHeight);
				break;
			case 'bottom':
				discard = this.viewport.lastChild;
				this.viewport.removeChild(discard);
				break;
			default:
				console.log('unknown end ' + whichEnd + ' in CodexView.checkChapterQueueSize.');
		}
		console.log('discarded chapter ', discard.id.substr(3), 'at', whichEnd);
	}
};
*/
CodexView.prototype.scrollTo = function(nodeId) {
	console.log('scrollTo', nodeId);
	var verse = document.getElementById(nodeId);
	if (verse) {
		var rect = verse.getBoundingClientRect();
		//window.scrollTo(0, rect.top + window.scrollY - this.headerHeight);
		TweenMax.set(window, {scrollTo: { y: rect.top + window.scrollY - this.headerHeight}});
	}
};
/**
* This method displays the footnote by taking text contained in the 'note' attribute
* and adding it as a text node.
*/
CodexView.prototype.showFootnote = function(node) {
	var handChar = node.innerText.trim();
	if (handChar === '\u261C' || handChar === '\u261E') {
		node.setAttribute('style', 'color: #555555; background-color: #FFFFB4;');
	} else {
		node.setAttribute('style', 'color: #555555; background-color: #CEE7FF;');
	}
	for (var i=0; i<node.children.length; i++) {
		node.children[i].setAttribute('style', 'display:inline');
	}
};
/**
* This method removes the footnote by removing all of the text nodes under a note
* except the one that displays the link.
*/
CodexView.prototype.hideFootnote = function(node) {
	node.setAttribute('style', 'color: ##FFB4B5; background-color: #FFFFFF;');
	for (var i=0; i<node.children.length; i++) {
		node.children[i].setAttribute('style', 'display:none');
	}
};

