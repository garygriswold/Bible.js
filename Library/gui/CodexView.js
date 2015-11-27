/**
* This class contains user interface features for the display of the Bible text
*/
var CODEX_VIEW = { MAX: 10, SCROLL_TIMEOUT: 100, USE_DRAGGABLE: false };

function CodexView(chaptersAdapter, tableContents, headerHeight) {
	this.chaptersAdapter = chaptersAdapter;
	this.tableContents = tableContents;
	this.headerHeight = headerHeight;
	this.rootNode = document.getElementById('codexRoot');
	this.viewport = this.rootNode;
	if (CODEX_VIEW.USE_DRAGGABLE) {
		Draggable.create(this.rootNode, {type:'scrollTop', throwProps: true});
		this.viewport = this.rootNode.firstChild; // Draggable adds a div wrapper		
	}
	this.currentNodeId = null;
	this.checkScrollID = null;
	Object.seal(this);
}
CodexView.prototype.hideView = function() {
	window.clearTimeout(this.checkScrollID);
	if (this.viewport.children.length > 0) {
		///this.scrollPosition = window.scrollY; // ISN'T THIS NEEDED?
		for (var i=this.viewport.children.length -1; i>=0; i--) {
			this.viewport.removeChild(this.viewport.children[i]);
		}
	}
};
CodexView.prototype.showView = function(nodeId) {
	document.body.style.backgroundColor = '#FFF';
	var firstChapter = new Reference(nodeId);
	var rowId = this.tableContents.rowId(firstChapter);
	var that = this;
	this.showChapters([rowId - 1, rowId + 1], true, function(err) {
		that.scrollTo(firstChapter);
		that.currentNodeId = firstChapter.nodeId;
		that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT);
		document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: firstChapter }}));
	});
	function onScrollHandler(event) {
		//console.log('windowHeight=', window.innerHeight, '  scrollHeight=', document.body.scrollHeight, '  scrollY=', window.scrollY);
		//console.log('left', (document.body.scrollHeight - window.scrollY));
		if (document.body.scrollHeight - window.scrollY <= 2 * window.innerHeight) {
			var lastNode = that.viewport.lastChild;
			var lastChapter = new Reference(lastNode.id.substr(3));
			var nextChapter = that.tableContents.rowId(lastChapter) + 1;
			if (nextChapter) {
				that.showChapters([nextChapter], true, function() {
					that.checkChapterQueueSize('top');
					that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT);
				});
			} else {
				that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT);
			}
		}
		else if (window.scrollY <= window.innerHeight) {
			var firstNode = that.viewport.firstChild;
			var firstChapter = new Reference(firstNode.id.substr(3));
			var beforeChapter = that.tableContents.rowId(firstChapter) - 1;
			if (beforeChapter) {
				that.showChapters([beforeChapter], false, function() {
					that.checkChapterQueueSize('bottom');
					that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT);
				});
			} else {
				that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT);
			}
		} else {
			that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT);
		}
		var ref = identifyCurrentChapter();//expensive solution
		if (ref && ref.nodeId !== that.currentNodeId) {
			that.currentNodeId = ref.nodeId;
			document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: ref }}));
		}
	}
	function identifyCurrentChapter() {
		var half = window.innerHeight / 2;
		for (var i=that.viewport.children.length -1; i>=0; i--) {
			var node = that.viewport.children[i];
			var top = node.getBoundingClientRect().top;
			if (top < half) {
				return(new Reference(node.id.substr(3)));
			}
		}
		return(null);
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
				reference.rootNode.innerHTML = row.html;
				if (append) {
					that.viewport.appendChild(reference.rootNode);
				} else {
					that.viewport.insertBefore(reference.rootNode, that.viewport.firstChild);
					// Scroll by the offset of the element added at the top to stay in the same place
					window.scrollBy(0, reference.rootNode.offsetHeight);
				}
				console.log('added chapter', reference.nodeId);
			}
			callback();
		}
	});
};
CodexView.prototype.checkChapterQueueSize = function(whichEnd) {
	if (this.viewport.children.length > CODEX_VIEW.MAX) {
		switch(whichEnd) {
			case 'top':
				var discard = this.viewport.firstChild;
				var offsetHeight = discard.offsetHeight;
				this.viewport.removeChild(discard);
				// Scroll the offset of the removed element to stay in the same place.
				window.scrollBy(0, - offsetHeight);
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
CodexView.prototype.scrollTo = function(reference) {
	console.log('scrollTo', reference.nodeId);
	var verse = document.getElementById(reference.nodeId);
	if (verse === null) {
		// when null it is probably because verse num was out of range.
		var nextChap = this.tableContents.nextChapter(reference);
		verse = document.getElementById(nextChap.nodeId);
	}
	if (verse) {
		var rect = verse.getBoundingClientRect();
		window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY - this.headerHeight);
	}
};
CodexView.prototype.showFootnote = function(noteId) {
	var note = document.getElementById(noteId);
	for (var i=0; i<note.children.length; i++) {
		var child = note.children[i];
		if (child.nodeName === 'SPAN') {
			child.innerHTML = child.getAttribute('note') + ' ';
		}
	} 
};
CodexView.prototype.hideFootnote = function(noteId) {
	var note = document.getElementById(noteId);
	for (var i=0; i<note.children.length; i++) {
		var child = note.children[i];
		if (child.nodeName === 'SPAN') {
			child.innerHTML = '';
		}
	}
};
