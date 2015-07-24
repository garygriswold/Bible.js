/**
* This class contains user interface features for the display of the Bible text
*/
var CODEX_VIEW = { MAX: 10 };

function CodexView(chaptersAdapter, tableContents, statusBarHeight) {
	this.chaptersAdapter = chaptersAdapter;
	this.tableContents = tableContents;
	this.statusBarHeight = statusBarHeight;
	this.chapterQueue = [];
	this.rootNode = document.getElementById('codexRoot');
	this.currentNodeId = null;
	this.visible = false; // HACK because I have not been able to remove onscroll listener.
	Object.seal(this);
}
CodexView.prototype.hideView = function() {
	this.visible = false;
	this.chapterQueue.splice(0);
	for (var i=this.rootNode.children.length -1; i>=0; i--) {
		this.rootNode.removeChild(this.rootNode.children[i]);
	}
};
CodexView.prototype.showView = function(nodeId) {
	this.chapterQueue.splice(0);
	var firstChapter = new Reference(nodeId);
	firstChapter = this.tableContents.ensureChapter(firstChapter);
	document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: firstChapter }}));
	var chapter = firstChapter;
	for (var i=0; i<3 && chapter; i++) {
		chapter = this.tableContents.priorChapter(chapter);
		if (chapter) {
			this.chapterQueue.unshift(chapter);
		}
	}
	this.chapterQueue.push(firstChapter);
	chapter = firstChapter;
	for (i=0; i<3 && chapter; i++) {
		chapter = this.tableContents.nextChapter(chapter);
		if (chapter) {
			this.chapterQueue.push(chapter);
		}
	}
	var that = this;
	this.showChapters(this.chapterQueue, true, function(results) {
		document.removeEventListener('scroll', onScrollHandler);
		that.scrollTo(firstChapter);
		that.currentNodeId = firstChapter.nodeId;
		document.addEventListener('scroll', onScrollHandler);
		that.visible = true;
	});

	function onScrollHandler(event) {
		document.removeEventListener('scroll', onScrollHandler);
		if (that.visible) {
			var ref = identifyCurrentChapter();
			if (ref && ref.nodeId !== that.currentNodeId) {
				that.currentNodeId = ref.nodeId;
				document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: ref }}));//expensive solution
			}
			if (document.body.scrollHeight - (window.scrollY + window.innerHeight) <= window.innerHeight) {
				var lastChapter = that.chapterQueue[that.chapterQueue.length -1];
				var nextChapter = that.tableContents.nextChapter(lastChapter);
				if (nextChapter) {
					that.chapterQueue.push(nextChapter);
					that.showChapters([nextChapter], true, function() {
						that.checkChapterQueueSize('top');
						document.addEventListener('scroll', onScrollHandler);
					});
				} else {
					document.addEventListener('scroll', onScrollHandler);
				}
			}
			else if (window.scrollY <= window.innerHeight) {
				var saveY = window.scrollY;
				var firstChapter = that.chapterQueue[0];
				var beforeChapter = that.tableContents.priorChapter(firstChapter);
				if (beforeChapter) {
					that.chapterQueue.unshift(beforeChapter);
					that.showChapters([beforeChapter], false, function() {
						window.scrollTo(10, saveY + beforeChapter.rootNode.scrollHeight);
						that.checkChapterQueueSize('bottom');
						document.addEventListener('scroll', onScrollHandler);
					});
				} else {
					document.addEventListener('scroll', onScrollHandler);
				}
			} else {
				document.addEventListener('scroll', onScrollHandler);
			}
		}
	}
	function identifyCurrentChapter() {
		var half = window.innerHeight / 2;
		for (var i=that.chapterQueue.length -1; i>=0; i--) {
			var ref = that.chapterQueue[i];
			var top = ref.rootNode.getBoundingClientRect().top;
			if (top < half) {
				return(ref);
			}
		}
	}
};
CodexView.prototype.showChapters = function(chapters, append, callback) {
	var that = this;
	var selectList = [];
	for (var i=0; i<chapters.length; i++) {
		selectList.push(chapters[i].nodeId);
	}
	this.chaptersAdapter.getChapters(selectList, function(results) {
		if (results instanceof IOError) {
			console.log((JSON.stringify(results)));
			callback(results);
		} else {
			for (i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				var reference = new Reference(row.reference);
				reference.rootNode.innerHTML = row.html;
				if (append) {
					that.rootNode.appendChild(reference.rootNode);
				} else {
					that.rootNode.insertBefore(reference.rootNode, that.rootNode.firstChild);
				}
				console.log('added chapter', reference.nodeId);
			}
			callback();
		}
	});
};
CodexView.prototype.checkChapterQueueSize = function(whichEnd) {
	if (this.chapterQueue.length > CODEX_VIEW.MAX) {
		var discard = null;
		switch(whichEnd) {
			case 'top':
				discard = this.chapterQueue.shift();
				this.rootNode.removeChild(this.rootNode.firstChild);
				break;
			case 'bottom':
				discard = this.chapterQueue.pop();
				this.rootNode.removeChild(this.rootNode.lastChild);
				break;
			default:
				console.log('unknown end ' + whichEnd + ' in CodexView.checkChapterQueueSize.');
		}
		console.log('discarded chapter ', discard.nodeId, 'at', whichEnd);
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
		window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY - this.statusBarHeight);
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
