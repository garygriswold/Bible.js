/**
* This class contains user interface features for the display of the Bible text
*/
var CODEX_VIEW = { MAX: 10 };

function CodexView(tableContents, bibleCache, statusBarHeight) {
	this.tableContents = tableContents;
	this.bibleCache = bibleCache;
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
	processQueue(0);

	function processQueue(index) {
		if (index < that.chapterQueue.length) {
			var chapt = that.chapterQueue[index];
			that.rootNode.appendChild(chapt.rootNode);
			that.showChapter(chapt, function() {
				processQueue(index +1);
			});
		} else {
			that.scrollTo(firstChapter);
			that.currentNodeId = firstChapter.nodeId;
			document.addEventListener('scroll', onScrollHandler);
			that.visible = true;
		}
	}
	function onScrollHandler(event) {
		console.log('inside Codex onScrollHandler');
		if (that.visible) {
			document.removeEventListener('scroll', onScrollHandler);
			var ref = identifyCurrentChapter();
			if (ref && ref.nodeId !== that.currentNodeId) {
				that.currentNodeId = ref.nodeId;
				document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: ref }}));//expensive solution
			}
			if (document.body.scrollHeight - (window.scrollY + window.innerHeight) <= window.innerHeight) {
				var lastChapter = that.chapterQueue[that.chapterQueue.length -1];
				var nextChapter = that.tableContents.nextChapter(lastChapter);
				if (nextChapter) {
					that.rootNode.appendChild(nextChapter.rootNode);
					that.chapterQueue.push(nextChapter);
					that.showChapter(nextChapter, function() {
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
					that.rootNode.insertBefore(beforeChapter.rootNode, that.rootNode.firstChild);
					that.chapterQueue.unshift(beforeChapter);
					that.showChapter(beforeChapter, function() {
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
CodexView.prototype.showChapter = function(chapter, callback) {
	var that = this;
	this.bibleCache.getChapterHTML(chapter, function(html) {
		if (html instanceof IOError) {
			console.log((JSON.stringify(html)));
			callback(html);
		} else {
			chapter.rootNode.innerHTML = html;
			console.log('added chapter', chapter.nodeId);
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
				this.rootNode.removeChild(discard.rootNode);
				break;
			case 'bottom':
				discard = this.chapterQueue.pop();
				this.rootNode.removeChild(discard.rootNode);
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
