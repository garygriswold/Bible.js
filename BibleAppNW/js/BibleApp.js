/**
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
"use strict";

var BIBLE = { SHOW_TOC: 'bible-show-toc', // present toc page, create if needed
		SHOW_SEARCH: 'bible-show-search', // present search page, create if needed
		SHOW_SETTINGS: 'TBD-bible-show-settings', // present settings page, create if needed
		TOC_FIND: 'bible-toc-find', // lookup a passage as result of user selection in toc
		LOOK: 'TBD-bible-look', // TBD
		SEARCH_START: 'bible-search-start', // process user entered search string
		SEARCH_FIND: 'bible-search-find', // lookup a pages as a result of user clicking on a search result
		CHG_HEADING: 'bible-chg-heading', // change title at top of page as result of user scrolling
		BACK: 'bible-back', // TBD
		FORWARD: 'bible-forward', // TBD
		LAST: 'bible-last', // TBD
		SHOW_NOTE: 'bible-show-note', // Show footnote as a result of user action
		HIDE_NOTE: 'bible-hide-note' // Hide footnote as a result of user action
	};

function AppViewController(versionCode) {
	this.versionCode = versionCode;
	this.statusBar = new StatusBar(88);
	this.statusBar.showView();
}
AppViewController.prototype.begin = function() {
	var types = new AssetType('document', this.versionCode);
	types.tableContents = true;
	types.chapterFiles = true;
	types.history = true;
	types.concordance = true;
	types.styleIndex = true;
	this.bibleCache = new BibleCache(types);
	var that = this;
	var assets = new AssetController(types);
	assets.checkBuildLoad(function(typesLoaded) {
		that.tableContents = assets.tableContents();
		console.log('loaded toc', that.tableContents.size());
		that.history = assets.history();
		console.log('loaded history', that.history.size());
		that.concordance = assets.concordance();
		console.log('loaded concordance', that.concordance.size());

		that.tableContentsView = new TableContentsView(that.tableContents);
		that.searchView = new SearchView(that.tableContents, that.concordance, that.bibleCache, that.history);
		that.codexView = new CodexView(that.tableContents, that.bibleCache, that.statusBar.hite + 7);
		Object.freeze(that);

		var lastItem = that.history.last();
		console.log(lastItem);
		console.log('size', that.history.size());
		if (lastItem && lastItem.key) {
			that.codexView.showView(lastItem.key);
		} else {
			that.codexView.showView('JHN:1');
		}
		//that.tableContentsView.showView();
		//that.searchView.showView("risen have");

		document.body.addEventListener(BIBLE.SHOW_TOC, function(event) {
			that.tableContentsView.showView();
			that.searchView.hideView();
			that.codexView.hideView();
		});
		document.body.addEventListener(BIBLE.SHOW_SEARCH, function(event) {
			that.searchView.showView();
			that.statusBar.showSearchField();
			that.tableContentsView.hideView();
			that.codexView.hideView();
		});
		document.body.addEventListener(BIBLE.TOC_FIND, function(event) {
			console.log(JSON.stringify(event.detail));
			that.codexView.showView(event.detail.id);
			that.tableContentsView.hideView();
			that.searchView.hideView();
			that.history.addEvent(event);
		});
		document.body.addEventListener(BIBLE.SEARCH_START, function(event) {
			console.log('SEARCH_START', event.detail);
			that.searchView.showView(event.detail.search);
			that.statusBar.showSearchField(event.detail.search);
		});
		document.body.addEventListener(BIBLE.SEARCH_FIND, function(event) {
			console.log(JSON.stringify(event.detail));
			that.codexView.showView(event.detail.id);
			that.statusBar.showTitleField();
			that.tableContentsView.hideView();
			that.searchView.hideView();
			that.history.addEvent(event);
		});
		document.body.addEventListener(BIBLE.CHG_HEADING, function(event) {
			var ref = event.detail.reference;
			var book = that.tableContents.find(ref.book);
			that.statusBar.setTitle(book.name + ' ' + ((ref.chapter > 0) ? ref.chapter : 1));
		});
		document.body.addEventListener(BIBLE.SHOW_NOTE, function(event) {
			that.codexView.showFootnote(event.detail.id);
		});
		document.body.addEventListener(BIBLE.HIDE_NOTE, function(event) {
			that.codexView.hideFootnote(event.detail.id);
		});
	});
};
/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
"use strict";

function StatusBar(hite) {
	this.hite = hite;
	this.titleWidth = window.outerWidth - hite * 3.5;
	this.titleCanvas = null;
	this.titleGraphics = null;
	this.searchField = null;
	this.rootNode = document.getElementById('statusRoot');
	this.labelCell = document.getElementById('labelCell');
	Object.seal(this);
}
StatusBar.prototype.showView = function() {
	var that = this;

	setupBackground(this.hite);
	setupTocButton(this.hite, '#F7F7BB');
	setupHeading(this.hite);
	setupSearchButton(this.hite, '#F7F7BB');
	setupSettingsButton(this.hite, '#F7F7BB');

	function setupBackground(hite) {
    	var canvas = document.createElement('canvas');
    	canvas.setAttribute('height', hite + 7);
    	var maxSize = (window.outHeight > window.outerWidth) ? window.outerHeight : window.outerWidth;
    	canvas.setAttribute('width', maxSize);
    	canvas.setAttribute('style', 'position: absolute; top: 0; z-index: -1');
      	var graphics = canvas.getContext('2d');
      	graphics.rect(0, 0, canvas.width, canvas.height);

      	// create radial gradient
      	var vMidpoint = hite / 2;

      	var gradient = graphics.createRadialGradient(238, vMidpoint, 10, 238, vMidpoint, window.outerHeight - hite);
      	// light blue
      	gradient.addColorStop(0, '#8ED6FF');
      	// dark blue
      	gradient.addColorStop(1, '#004CB3');

      	graphics.fillStyle = gradient;
      	graphics.fill();
      	that.rootNode.appendChild(canvas);
	}
	function setupTocButton(hite, color) {
		var lineThick = hite/7.0;
		var line1Y = lineThick * 1.5;
		var lineXSrt = line1Y;
		var lineXEnd = hite - lineThick;
		var line2Y = lineThick * 2 + line1Y;
		var line3Y = lineThick * 2 + line2Y;

		var canvas = document.createElement('canvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', hite + lineXSrt * 0.5);
		canvas.setAttribute('style', 'position: fixed; top: 0; left: 0');
		var graphics = canvas.getContext('2d');
	
		graphics.beginPath();
		graphics.moveTo(lineXSrt, line1Y);
		graphics.lineTo(lineXEnd, line1Y);
		graphics.moveTo(lineXSrt, line2Y);
		graphics.lineTo(lineXEnd, line2Y);
		graphics.moveTo(lineXSrt, line3Y);
		graphics.lineTo(lineXEnd, line3Y);

		graphics.lineWidth = lineThick;
		graphics.lineCap = 'square';
		graphics.strokeStyle = color;
		graphics.stroke();

		document.getElementById('tocCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('toc button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_TOC));
		});
	}
	function setupHeading(hite) {
		that.titleCanvas = document.createElement('canvas');
		that.titleCanvas.setAttribute('id', 'titleCanvas');
		that.titleCanvas.setAttribute('height', hite);
		that.titleCanvas.setAttribute('width', that.titleWidth);
		that.titleCanvas.setAttribute('style', 'position: fixed; top: 0; left:' + hite * 1.1);

		that.titleGraphics = that.titleCanvas.getContext('2d');
		that.titleGraphics.fillStyle = '#000000';
		that.titleGraphics.font = '24pt sans-serif';
		that.titleGraphics.textAlign = 'center';
		that.titleGraphics.textBaseline = 'middle';
		that.titleGraphics.borderStyle = 'solid';

		that.labelCell.appendChild(that.titleCanvas);
	}
	function setupSearchButton(hite, color) {
		var lineThick = hite/7.0;
		var radius = (hite / 2) - (lineThick * 1.5);
		var coordX = radius + (lineThick * 1.5);
		var coordY = radius + lineThick * 1.25;
		var edgeX = coordX + radius / 2 + 2;
		var edgeY = coordY + radius / 2 + 2;

		var canvas = document.createElement('canvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', hite + lineThick);
		canvas.setAttribute('style', 'position: fixed; top: 0; right: ' + hite);
		var graphics = canvas.getContext('2d');

		graphics.beginPath();
		graphics.arc(coordX, coordY, radius, 0, Math.PI*2, true);
		graphics.moveTo(edgeX, edgeY);
		graphics.lineTo(edgeX + radius, edgeY + radius);
		graphics.closePath();

		graphics.lineWidth = lineThick;
		graphics.strokeStyle = color;
		graphics.stroke();

		document.getElementById('searchCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('search button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_SEARCH));
		});
	}
	function setupSettingsButton(hite, color) {
		var lineThick = hite/7.0;
		var radius = (hite / 2) - (lineThick * 1.75);
		var coord = hite / 2;
		var circle = Math.PI * 2;
		var increment = Math.PI / 4;
		var first = increment / 2;

		var canvas = document.createElement('canvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', hite);
		canvas.setAttribute('style', 'position: fixed; top: 0; right: 0');
		var graphics = canvas.getContext('2d');

		graphics.beginPath();
		graphics.arc(coord, coord, radius, 0, Math.PI*2, true);
		for (var angle=first; angle<circle; angle+=increment) {
			graphics.moveTo(Math.cos(angle) * radius + coord, Math.sin(angle) * radius + coord);
			graphics.lineTo(Math.cos(angle) * radius * 1.6 + coord, Math.sin(angle) * radius * 1.6 + coord);
		}
		graphics.closePath();

		graphics.lineWidth = lineThick;
		graphics.strokeStyle = color;
		graphics.stroke();

		document.getElementById('settingsCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('settings button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_SETTINGS));
		});
	}
};
StatusBar.prototype.setTitle = function(text) {
	this.titleGraphics.clearRect(0, 0, this.titleWidth, this.hite);
	this.titleGraphics.fillText(text, this.titleWidth / 2, this.hite / 2, this.titleWidth);
};
StatusBar.prototype.showSearchField = function(query) {
	if (! this.searchField) {
		this.searchField = document.createElement('input');
		this.searchField.setAttribute('type', 'text');
		this.searchField.setAttribute('class', 'searchField');
		this.searchField.setAttribute('value', query);
		var yPos = (this.hite - 40) / 2; // The 40 in this calculation is a hack.
		var xPos = (this.hite * 1.2);
		this.searchField.setAttribute('style', 'position: fixed; top: ' + yPos + '; left: ' + xPos);
		var that = this;
		this.searchField.addEventListener('keyup', function(event) {
			if (event.keyCode === 13) {
				document.body.dispatchEvent(new CustomEvent(BIBLE.SEARCH_START, { detail: { search: that.searchField.value }}));

			}
		});
	}
	this.changeLabelCell(this.searchField);
};
StatusBar.prototype.showTitleField = function() {
	this.changeLabelCell(this.titleCanvas);
};
StatusBar.prototype.changeLabelCell = function(node) {
	for (var i=this.labelCell.children.length -1; i>=0; i--) {
		this.labelCell.removeChild(this.labelCell.children[i]);
	}
	this.labelCell.appendChild(node);
};
/**
* This class presents the table of contents, and responds to user actions.
*/
"use strict";

function TableContentsView(toc) {
	this.toc = toc;
	this.root = null;
	this.rootNode = document.getElementById('tocRoot');
	this.scrollPosition = 0;
	var that = this;
	Object.seal(this);
}
TableContentsView.prototype.showView = function() {
	if (! this.root) {
		this.root = this.buildTocBookList();
	}
	if (this.rootNode.children.length < 1) {
		this.rootNode.appendChild(this.root);
		window.scrollTo(10, this.scrollPosition);
	}
};
TableContentsView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.scrollPosition = window.scrollY; // save scroll position till next use.
		this.rootNode.removeChild(this.root);
	}
};
TableContentsView.prototype.buildTocBookList = function() {
	var div = document.createElement('div');
	div.setAttribute('id', 'toc');
	div.setAttribute('class', 'tocPage');
	for (var i=0; i<this.toc.bookList.length; i++) {
		var book = this.toc.bookList[i];
		var bookNode = document.createElement('p');
		bookNode.setAttribute('id', 'toc' + book.code);
		bookNode.setAttribute('class', 'tocBook');
		bookNode.textContent = book.name;
		div.appendChild(bookNode);
		var that = this;
		bookNode.addEventListener('click', function(event) {
			var bookCode = this.id.substring(3);
			that.showTocChapterList(bookCode);
		});
	}
	return(div);
};
TableContentsView.prototype.showTocChapterList = function(bookCode) {
	var book = this.toc.find(bookCode);
	if (book) {
		var root = document.createDocumentFragment();
		var table = document.createElement('table');
		table.setAttribute('class', 'tocChap');
		root.appendChild(table);
		var numCellPerRow = this.cellsPerRow();
		var numRows = Math.ceil(book.lastChapter / numCellPerRow);
		var chaptNum = 1;
		for (var r=0; r<numRows; r++) {
			var row = document.createElement('tr');
			table.appendChild(row);
			for (var c=0; c<numCellPerRow && chaptNum <= book.lastChapter; c++) {
				var cell = document.createElement('td');
				cell.setAttribute('id', 'toc' + bookCode + ':' + chaptNum);
				cell.setAttribute('class', 'tocChap');
				cell.textContent = chaptNum;
				row.appendChild(cell);
				chaptNum++;
				var that = this;
				cell.addEventListener('click', function(event) {
					var nodeId = this.id.substring(3);
					that.openChapter(nodeId);
				});
			}
		}
		var bookNode = document.getElementById('toc' + book.code);
		if (bookNode) {
			var saveYPosition = bookNode.getBoundingClientRect().top;
			this.removeAllChapters();
			bookNode.appendChild(root);
			window.scrollBy(0, bookNode.getBoundingClientRect().top - saveYPosition); // keeps toc from scrolling
		}
	}
};
TableContentsView.prototype.cellsPerRow = function() {
	return(5); // some calculation based upon the width of the screen
};
TableContentsView.prototype.removeAllChapters = function() {
	var div = document.getElementById('toc');
	if (div) {
		for (var i=div.children.length -1; i>=0; i--) {
			var bookNode = div.children[i];
			for (var j=bookNode.children.length -1; j>=0; j--) {
				var chaptTable = bookNode.children[j];
				bookNode.removeChild(chaptTable);
			}
		}
	}
};
TableContentsView.prototype.openChapter = function(nodeId) {
	console.log('open chapter', nodeId);
	this.hideView();
	document.body.dispatchEvent(new CustomEvent(BIBLE.TOC_FIND, { detail: { id: nodeId }}));
};


/**
* This class contains user interface features for the display of the Bible text
*/
"use strict";

var CODEX_VIEW = { MAX: 10 };

function CodexView(tableContents, bibleCache, statusBarHeight) {
	this.tableContents = tableContents;
	this.bibleCache = bibleCache;
	this.statusBarHeight = statusBarHeight;
	this.chapterQueue = [];
	this.rootNode = document.getElementById('codexRoot');
	this.currentNodeId = null;
	var that = this;
	this.addChapterInProgress = false;
	Object.seal(this);
}
CodexView.prototype.hideView = function() {
	this.chapterQueue.splice(0);
	for (var i=this.rootNode.children.length -1; i>=0; i--) {
		this.rootNode.removeChild(this.rootNode.children[i]);
	}
};
CodexView.prototype.showView = function(nodeId) {
	this.chapterQueue.splice(0);
	var chapter = new Reference(nodeId);
	for (var i=0; i<3 && chapter; i++) {
		chapter = this.tableContents.priorChapter(chapter);
		if (chapter) {
			this.chapterQueue.unshift(chapter);
		}
	}
	chapter = new Reference(nodeId);
	this.chapterQueue.push(chapter);
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
			that.scrollTo(nodeId);
			that.addChapterInProgress = false;
			document.addEventListener('scroll', onScrollHandler);
		}
	}
	function onScrollHandler(event) {
		if (! that.addChapterInProgress && that.chapterQueue.length > 1) {
			var ref = identifyCurrentChapter();
			if (ref.nodeId !== that.currentNodeId) {
				that.currentNodeId = ref.nodeId;
				document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: ref }}));//expensive solution
			}
			if (document.body.scrollHeight - (window.scrollY + window.innerHeight) <= window.outerHeight) {
				that.addChapterInProgress = true;
				var lastChapter = that.chapterQueue[that.chapterQueue.length -1];
				var nextChapter = that.tableContents.nextChapter(lastChapter);
				if (nextChapter) {
					that.rootNode.appendChild(nextChapter.rootNode);
					that.chapterQueue.push(nextChapter);
					that.showChapter(nextChapter, function() {
						that.checkChapterQueueSize('top');
						that.addChapterInProgress = false;
					});
				} else {
					that.addChapterInProgress = false;
				}
			}
			else if (window.scrollY <= window.outerHeight) {
				that.addChapterInProgress = true;
				var saveY = window.scrollY;
				var firstChapter = that.chapterQueue[0];
				var beforeChapter = that.tableContents.priorChapter(firstChapter);
				if (beforeChapter) {
					that.rootNode.insertBefore(beforeChapter.rootNode, firstChapter.rootNode);
					that.chapterQueue.unshift(beforeChapter);
					that.showChapter(beforeChapter, function() {
						window.scrollTo(10, saveY + beforeChapter.rootNode.scrollHeight);
						that.checkChapterQueueSize('bottom');
						that.addChapterInProgress = false;
					});
				} else {
					that.addChapterInProgress = false;
				}
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
CodexView.prototype.showChapter = function(chapter, callout) {
	var that = this;
	this.bibleCache.getChapter(chapter, function(usxNode) {
		if (usxNode.errno) {
			// what to do here?
			console.log((JSON.stringify(usxNode)));
			callout();
		} else {
			var dom = new DOMBuilder();
			dom.bookCode = chapter.book;
			var fragment = dom.toDOM(usxNode);
			chapter.rootNode.appendChild(fragment);
			console.log('added chapter', chapter.nodeId);
			callout();
		}
	});
};
CodexView.prototype.checkChapterQueueSize = function(whichEnd) {
	if (this.chapterQueue.length > CODEX_VIEW.MAX) {
		var discard = null;
		switch(whichEnd) {
			case 'top':
				discard = this.chapterQueue.shift();
				break;
			case 'bottom':
				discard = this.chapterQueue.pop();
				break;
			default:
				console.log('unknown end ' + whichEnd + ' in CodexView.checkChapterQueueSize.');
		}
		console.log('discarded chapter ', discard.nodeId, 'at', whichEnd);
	}
};
CodexView.prototype.scrollTo = function(nodeId) {
	var verse = document.getElementById(nodeId);
	var rect = verse.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY - this.statusBarHeight);
};
CodexView.prototype.scrollToNode = function(node) {
	var rect = node.getBoundingClientRect();
	window.scrollTo(rect.left + window.scrollX, rect.top + window.scrollY - this.statusBarHeight);
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
/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
"use strict";

function SearchView(toc, concordance, bibleCache, history) {
	this.toc = toc;
	this.concordance = concordance;
	this.bibleCache = bibleCache;
	this.history = history;
	this.query = '';
	this.words = [];
	this.bookList = [];
	this.viewRoot = null;
	this.rootNode = document.getElementById('searchRoot');
	this.scrollPosition = 0;
	var that = this;
	Object.seal(this);
}
SearchView.prototype.showView = function(query) {
	this.hideView();
	if (query) {
		this.showSearch(query);
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, 0);
	} else if (this.viewRoot) {
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, this.scrollPosition);
	} else {
		var lastSearch = this.history.lastConcordanceSearch();
		if (lastSearch && lastSearch.length > 0) { // check trim also
			document.body.dispatchEvent(new CustomEvent(BIBLE.SEARCH_START, { detail: { search: lastSearch }}));
		} else {
			console.log('IN THE EMPTY CASE of SearchView.showView');
			this.showSearch('');
			this.rootNode.appendChild(this.viewRoot);
			window.scrollTo(10, 0);			
		}
	}
};
SearchView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.scrollPosition = window.scrollY;
		this.rootNode.removeChild(this.viewRoot);
	}
};
SearchView.prototype.showSearch = function(query) {
	this.viewRoot = document.createElement('div');
	this.query = query;
	this.words = query.split(' ');
	var refList = this.concordance.search(this.words);
	this.bookList = this.refListsByBook(refList);
	for (var i=0; i<this.bookList.length; i++) {
		var bookRef = this.bookList[i];
		var bookNode = this.appendBook(bookRef.bookCode);
		for (var j=0; j<bookRef.refList.length && j < 3; j++) {
			var ref = new Reference(bookRef.refList[j]);
			this.appendReference(bookNode, ref);
		}
		if (bookRef.refList.length > 3) {
			this.appendSeeMore(bookNode, bookRef);
		}
	}
};
SearchView.prototype.refListsByBook = function(refList) {
	var bookList = [];
	var priorBook = '';
	for (var i=0; i<refList.length; i++) {
		var bookCode = refList[i].substr(0, 3);
		if (bookCode !== priorBook) {
			var bookRef = { bookCode: bookCode, refList: [ refList[i] ] };
			Object.freeze(bookRef);
			bookList.push(bookRef);
			priorBook = bookCode;
		}
		else {
			bookRef.refList.push(refList[i]);
		}
	}
	Object.freeze(bookList);
	return(bookList);
};
SearchView.prototype.appendBook = function(bookCode) {
	var book = this.toc.find(bookCode);
	var bookNode = document.createElement('p');
	bookNode.setAttribute('id', 'con' + bookCode);
	this.viewRoot.appendChild(bookNode);
	var titleNode = document.createElement('span');
	titleNode.setAttribute('class', 'conBook');
	var tocBook = this.toc.find(bookCode);
	titleNode.textContent = tocBook.name;
	bookNode.appendChild(titleNode);
	bookNode.appendChild(document.createElement('hr'));
	return(bookNode);
};
SearchView.prototype.appendReference = function(bookNode, reference) {
	var that = this;
	var entryNode = document.createElement('p');
	bookNode.appendChild(entryNode);
	var refNode = document.createElement('span');
	refNode.setAttribute('class', 'conRef');
	refNode.textContent = reference.chapterVerse();
	entryNode.appendChild(refNode);
	entryNode.appendChild(document.createElement('br'));
	var accessor = new VerseAccessor(this.bibleCache, reference);
	accessor.getVerse(function(verseText) {
		if (verseText.errno) {
			console.log('Error in get verse', JSON.stringify(verseText));
		} else {
			var verseNode = document.createElement('span');
			verseNode.setAttribute('id', 'con' + reference.nodeId);
			verseNode.setAttribute('class', 'conVerse');
			verseNode.innerHTML = styleSearchWords(verseText);
			entryNode.appendChild(verseNode);
			verseNode.addEventListener('click', function(event) {
				var nodeId = this.id.substr(3);
				console.log('open chapter', nodeId);
				that.hideView();
				document.body.dispatchEvent(new CustomEvent(BIBLE.SEARCH_FIND, { detail: { id: nodeId, source: that.query }}));
			});
		}	
	});

	function styleSearchWords(verseText) {
		var verseWords = verseText.split(/\b/); // Non-destructive, preserves all characters
		for (var i=0; i<that.words.length; i++) {
			var word = that.words[i];
			var wordNum = verseWords.indexOf(word);
			if (wordNum >= 0) {
				verseWords[wordNum] = '<span class="conWord">' + word + '</span>';
			}
		}
		return(verseWords.join(''));
	}
};
SearchView.prototype.appendSeeMore = function(bookNode, bookRef) {
	var that = this;
	var entryNode = document.createElement('p');
	entryNode.setAttribute('id', 'mor' + bookRef.bookCode);
	entryNode.setAttribute('class', 'conMore');
	entryNode.textContent = '...';
	bookNode.appendChild(entryNode);
	entryNode.addEventListener('click', function(event) {
		var moreNode = document.getElementById(this.id);
		var parentNode = moreNode.parentNode;
		parentNode.removeChild(moreNode);

		var bookCode = this.id.substr(3);
		var bookNode = document.getElementById('con' + bookCode);
		var refList = findBookInBookList(bookCode);
		for (var i=3; i<refList.length; i++) {
			var ref = new Reference(refList[i]);
			that.appendReference(bookNode, ref);
		}
	});

	function findBookInBookList(bookCode) {
		for (var i=0; i<that.bookList.length; i++) {
			if (that.bookList[i].bookCode === bookCode) {
				return(that.bookList[i].refList);
			}
		}
		return(null);
	}
};

/**
* This class contains the Canon of Scripture as 66 books.  It is used to control
* which books are published using this App.  The codes are used to identify the
* books of the Bible, while the names, which are in English are only used to document
* the meaning of each code.  These names are not used for display in the App.
*/
"use strict";

function Canon() {
	this.books = [
    	{ code: 'GEN', name: 'Genesis' },
    	{ code: 'EXO', name: 'Exodus' },
    	{ code: 'LEV', name: 'Leviticus' },
    	{ code: 'NUM', name: 'Numbers' },
    	{ code: 'DEU', name: 'Deuteronomy' },
    	{ code: 'JOS', name: 'Joshua' },
    	{ code: 'JDG', name: 'Judges' },
    	{ code: 'RUT', name: 'Ruth' },
    	{ code: '1SA', name: '1 Samuel' },
    	{ code: '2SA', name: '2 Samuel' },
    	{ code: '1KI', name: '1 Kings' },
    	{ code: '2KI', name: '2 Kings' },
    	{ code: '1CH', name: '1 Chronicles' },
    	{ code: '2CH', name: '2 Chronicles' },
    	{ code: 'EZR', name: 'Ezra' },
    	{ code: 'NEH', name: 'Nehemiah' },
    	{ code: 'EST', name: 'Esther' },
    	{ code: 'JOB', name: 'Job' },
    	{ code: 'PSA', name: 'Psalms' },
    	{ code: 'PRO', name: 'Proverbs' },
    	{ code: 'ECC', name: 'Ecclesiastes' },
    	{ code: 'SNG', name: 'Song of Solomon' },
    	{ code: 'ISA', name: 'Isaiah' },
    	{ code: 'JER', name: 'Jeremiah' },
    	{ code: 'LAM', name: 'Lamentations' },
    	{ code: 'EZK', name: 'Ezekiel' },
    	{ code: 'DAN', name: 'Daniel' },
    	{ code: 'HOS', name: 'Hosea' },
    	{ code: 'JOL', name: 'Joel' },
    	{ code: 'AMO', name: 'Amos' },
    	{ code: 'OBA', name: 'Obadiah' },
    	{ code: 'JON', name: 'Jonah' },
    	{ code: 'MIC', name: 'Micah' },
    	{ code: 'NAM', name: 'Nahum' },
    	{ code: 'HAB', name: 'Habakkuk' },
    	{ code: 'ZEP', name: 'Zephaniah' },
    	{ code: 'HAG', name: 'Haggai' },
    	{ code: 'ZEC', name: 'Zechariah' },
    	{ code: 'MAL', name: 'Malachi' },
    	{ code: 'MAT', name: 'Matthew' },
    	{ code: 'MRK', name: 'Mark' },
    	{ code: 'LUK', name: 'Luke' },
    	{ code: 'JHN', name: 'John' },
    	{ code: 'ACT', name: 'Acts' },
    	{ code: 'ROM', name: 'Romans' },
    	{ code: '1CO', name: '1 Corinthians' },
    	{ code: '2CO', name: '2 Corinthians' },
    	{ code: 'GAL', name: 'Galatians' },
    	{ code: 'EPH', name: 'Ephesians' },
    	{ code: 'PHP', name: 'Philippians' },
    	{ code: 'COL', name: 'Colossians' },
    	{ code: '1TH', name: '1 Thessalonians' },
    	{ code: '2TH', name: '2 Thessalonians' },
    	{ code: '1TI', name: '1 Timothy' },
    	{ code: '2TI', name: '2 Timothy' },
    	{ code: 'TIT', name: 'Titus' },
    	{ code: 'PHM', name: 'Philemon' },
    	{ code: 'HEB', name: 'Hebrews' },
    	{ code: 'JAS', name: 'James' },
    	{ code: '1PE', name: '1 Peter' },
    	{ code: '2PE', name: '2 Peter' },
    	{ code: '1JN', name: '1 John' },
    	{ code: '2JN', name: '2 John' },
    	{ code: '3JN', name: '3 John' },
    	{ code: 'JUD', name: 'Jude' },
    	{ code: 'REV', name: 'Revelation' } ];
}
/**
* This class contains a reference to a chapter or verse.  It is used to
* simplify the transition from the "GEN:1:1" format to the format
* of distinct parts { book: GEN, chapter: 1, verse: 1 }
* This class leaves unset members as undefined.
*/
"use strict";

function Reference(book, chapter, verse) {
	if (arguments.length > 1) {
		this.book = book;
		this.chapter = +chapter;
		this.verse = +verse;
		if (verse) {
			this.nodeId = book + ':' + chapter + ':' + verse;
		} else {
			this.nodeId = book + ':' + chapter;
		}
	} else {
		var parts = book.split(':');
		this.book = parts[0];
		this.chapter = (parts.length > 0) ? +parts[1] : NaN;
		this.verse = (parts.length > 1) ? +parts[2] : NaN;
		this.nodeId = book;
	}
	this.rootNode = document.createElement('div');
	Object.freeze(this);
}
Reference.prototype.path = function() {
	return(this.book + '/' + this.chapter + '.usx');
};
Reference.prototype.chapterVerse = function() {
	return((this.verse) ? this.chapter + ':' + this.verse : this.chapter);
};
/**
* This class handles all request to deliver scripture.  It handles all passage display requests to display passages of text,
* and it also handles all requests from concordance search requests to display individual verses.
* It will deliver the content from cache if it is present.  Or, it will find the content in persistent storage if it is
* not present in cache.  All content retrieved from persistent storage is added to the cache.
*
* On May 3, 2015 some performance checks were done.  The time measurements where from a sample of 4, the memory from a sample of 1.
* 1) Read Chapter 11.2ms, 49K heap increase
* 2) Parse USX 6.0ms, 306K heap increase
* 3) Generate Dom 2.16ms, 85K heap increase
*/
"use strict";

function BibleCache(types) {
	this.types = types;
	this.chapterMap = {};
	this.reader = new NodeFileReader(types.location);
	this.parser = new USXParser();
	Object.freeze(this);
}
BibleCache.prototype.getChapter = function(reference, callback) {
	var that = this;
	var chapter = this.chapterMap[reference.nodeId];
	
	if (chapter !== undefined) {
		callback(chapter);
	} else {
		var filepath = this.types.getAppPath(reference.path());
		this.reader.readTextFile(filepath, function(data) {
			if (data.errno) {
				console.log('BibleCache.getChapter ', JSON.stringify(data));
				callback(data);
			} else {
				chapter = that.parser.readBook(data);
				that.chapterMap[reference.nodeId] = chapter;
				callback(chapter);				
			}
		});
	}
};
/**
* This class holds the concordance of the entire Bible, or whatever part of the Bible was available.
*/
"use strict";

function Concordance() {
	this.index = {};
	this.filename = 'concordance.json';
	this.isFilled = false;
	Object.seal(this);
}
Concordance.prototype.fill = function(words) {
	this.index = words;
	this.isFilled = true;
	Object.freeze(this);
};
Concordance.prototype.addEntry = function(word, reference) {
	if (this.index[word] === undefined) {
		this.index[word] = [];
		this.index[word].push(reference);
	}
	else {
		var refList = this.index[word];
		if (reference !== refList[refList.length -1]) { /* ignore duplicate reference */
			refList.push(reference);
		}
	}
};
Concordance.prototype.size = function() {
	return(Object.keys(this.index).length);
};
Concordance.prototype.search = function(words) {
	var refList = [];
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		refList.push(this.index[word]);
	}
	return(this.intersection(refList));
};
Concordance.prototype.intersection = function(refLists) {
	if (refLists.length === 0) {
		return([]);
	}
	if (refLists.length === 1) {
		return(refLists[0]);
	}
	var mapList = [];
	for (var i=1; i<refLists.length; i++) {
		var map = arrayToMap(refLists[i]);
		mapList.push(map);
	}
	var result = [];
	var firstList = refLists[0];
	for (var j=0; j<firstList.length; j++) {
		var reference = firstList[j];
		if (presentInAllMaps(mapList, reference)) {
			result.push(reference);
		}
	}
	return(result);

	function arrayToMap(array) {
		var map = {};
		for (var i=0; i<array.length; i++) {
			map[array[i]] = true;
		}
		return(map);
	}
	function presentInAllMaps(mapList, reference) {
		for (var i=0; i<mapList.length; i++) {
			if (mapList[i][reference] === undefined) {
				return(false);
			}
		}
		return(true);
	}
};
Concordance.prototype.toJSON = function() {
	return(JSON.stringify(this.index, null, ' '));
};/**
* This class holds data for the table of contents of the entire Bible, or whatever part of the Bible was loaded.
*/
"use strict";

function TOC() {
	this.bookList = [];
	this.bookMap = {};
	this.filename = 'toc.json';
	this.isFilled = false;
	Object.seal(this);
}
TOC.prototype.fill = function(books) {
	for (var i=0; i<books.length; i++) {
		this.addBook(books[i]);
	}
	this.isFilled = true;
	Object.freeze(this);	
};
TOC.prototype.addBook = function(book) {
	this.bookList.push(book);
	this.bookMap[book.code] = book;
};
TOC.prototype.find = function(code) {
	return(this.bookMap[code]);
};
TOC.prototype.nextChapter = function(reference) {
	var current = this.bookMap[reference.book];
	if (reference.chapter < current.lastChapter) {
		return(new Reference(reference.book, reference.chapter + 1));
	} else {
		return((current.nextBook) ? new Reference(current.nextBook, 0) : null);
	}
};
TOC.prototype.priorChapter = function(reference) {
	var current = this.bookMap[reference.book];
	if (reference.chapter > 0) {
		return(new Reference(reference.book, reference.chapter -1));
	} else {
		var priorBook = this.bookMap[current.priorBook];
		return((priorBook) ? new Reference(current.priorBook, priorBook.lastChapter) : null);
	}
};
TOC.prototype.size = function() {
	return(this.bookList.length);
};
TOC.prototype.toJSON = function() {
	return(JSON.stringify(this.bookList, null, ' '));
};/**
* This class holds the table of contents data each book of the Bible, or whatever books were loaded.
*/
"use strict";

function TOCBook(code) {
	this.code = code;
	this.heading = '';
	this.title = '';
	this.name = '';
	this.abbrev = '';
	this.lastChapter = 0;
	this.priorBook = null;
	this.nextBook = null;
	Object.seal(this);
}/**
* This class holds an index of styles of the entire Bible, or whatever part of the Bible was loaded into it.
*/
"use strict";

function StyleIndex() {
	this.index = {};
	this.filename = 'styleIndex.json';
	this.isFilled = false;
	this.completed = [ 'book.id', 'para.ide', 'para.h', 'para.toc1', 'para.toc2', 'para.toc3', 'para.cl', 'para.rem',
		'para.mt', 'para.mt1', 'para.mt2', 'para.mt3', 'para.ms', 'para.ms1', 'para.d',
		'chapter.c', 'verse.v',
		'para.p', 'para.m', 'para.b', 'para.mi', 'para.pi', 'para.li', 'para.li1', 'para.nb',
		'para.sp', 'para.q', 'para.q1', 'para.q2',
		'note.f', 'note.x', 'char.fr', 'char.ft', 'char.fqa', 'char.xo',
		'char.wj', 'char.qs'];
	Object.seal(this);
}
StyleIndex.prototype.fill = function(entries) {
	this.index = entries;
	this.isFilled = true;
	Object.freeze(this);
};
StyleIndex.prototype.addEntry = function(word, reference) {
	if (this.completed.indexOf(word) < 0) {
		if (this.index[word] === undefined) {
			this.index[word] = [];
		}
		if (this.index[word].length < 100) {
			this.index[word].push(reference);
		}
	}
};
StyleIndex.prototype.find = function(word) {
	return(this.index[word]);
};
StyleIndex.prototype.size = function() {
	return(Object.keys(this.index).length);
};
StyleIndex.prototype.dumpAlphaSort = function() {
	var words = Object.keys(this.index);
	var alphaWords = words.sort();
	this.dump(alphaWords);
};
StyleIndex.prototype.dump = function(words) {
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		console.log(word, this.index[word]);
	}	
};
StyleIndex.prototype.toJSON = function() {
	return(JSON.stringify(this.index, null, ' '));
};/**
* This class manages a queue of history items up to some maximum number of items.
* It adds items when there is an event, such as a toc click, a search lookup,
* or a concordance search.  It also responds to function requests to go back 
* in history, forward in history, or return to the last event.
*/
"use strict";

function History(types) {
	this.types = types;
	this.items = [];
	this.currentItem = null;
	this.writer = new NodeFileWriter(types.location);
	this.isFilled = false;
	Object.seal(this);
}
History.prototype.fill = function(itemList) {
	this.items = itemList;
	this.isFilled = true;
};
History.prototype.addEvent = function(event) {
	var item = new HistoryItem(event.detail.id, event.type, event.detail.source);
	this.items.push(item);
	this.currentItem = this.items.length -1;
	if (this.items.length > 1000) {
		var discard = this.items.shift();
		this.currentItem--;
	}
	setTimeout(this.persist(), 3000);
};
History.prototype.size = function() {
	return(this.items.length);
};
History.prototype.back = function() {
	return(this.item(--this.currentItem));
};
History.prototype.forward = function() {
	return(this.item(++this.currentItem));
};
History.prototype.last = function() {
	this.currentItem = this.items.length -1;
	return(this.item(this.currentItem));
};
History.prototype.current = function() {
	return(this.item(this.currentItem));
};
History.prototype.item = function(index) {
	return((index > -1 && index < this.items.length) ? this.items[index] : 'JHN:1');
};
History.prototype.lastConcordanceSearch = function() {
	for (var i=this.items.length -1; i>=0; i--) {
		var item = this.items[i];
		if (item.search && item.search.length > 0) { // also trim it
			return(item.search);
		}
	}
	return('');
};
History.prototype.persist = function() {
	var filepath = this.types.getAppPath('history.json');
	this.writer.writeTextFile(filepath, this.toJSON(), function(filename) {
		if (filename.errno) {
			console.log('error writing history.json', filename);
		} else {
			console.log('History saved', filename);
		}
	});
};
History.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};

/**
* This class contains the details of a single history event, such as
* clicking on the toc to get a chapter, doing a lookup of a specific passage
* or clicking on a verse during a concordance search.
*/
"use strict";

function HistoryItem(key, source, search) {
	this.key = key;
	this.source = source;
	this.search = search;
	this.timestamp = new Date();
	Object.freeze(this);
}/**
* This class extracts single verses from Chapters and returns the text of those
* verses for use in Concordance Search and possibly other uses.  This is written
* as a class, because BibleCache and SearchView both have only one instance, but
* SearchView could be accessing the text of many verses concurrently.
*/
"use strict";
function VerseAccessor(bibleCache, reference) {
	this.bibleCache = bibleCache;
	this.reference = reference;
	this.insideVerse = false;
	this.result = [];
	Object.seal(this);
}
VerseAccessor.prototype.getVerse = function(callback) {
	var that = this;
	this.bibleCache.getChapter(this.reference, function(chapter) {
		if (chapter.errno) {
			callback(chapter);
		} else {
			var verseNum = String(that.reference.verse);
			scanRecursively(chapter, verseNum);
			callback(that.result.join(' '));
		}
	});
	function scanRecursively(node, verseNum) {
		if (that.insideVerse) {
			if (node.tagName === 'verse') {
				that.insideVerse = false;
			}
			else if (node.tagName === 'text') {
				that.result.push(node.text);
			}
		} else {
			if (node.tagName === 'verse' && node.number === verseNum) {
				that.insideVerse = true;
			}
		}
		if (node.tagName !== 'note' && 'children' in node) {
			for (var i=0; i<node.children.length; i++) {
				scanRecursively(node.children[i], verseNum);
			}
		}
	}
};/**
* This file contains IO constants and functions which are common to all file methods, which might include node.js, cordova, javascript, etc.
*/
var FILE_ROOTS = { 'application': '?', 'document': '../../dbl/current/', 'temporary': '?', 'test2dbl': '../../../dbl/current/' };
/**
* This class is a file reader for Node.  It can be used with node.js and node-webkit.
* cordova requires using another class, but the interface should be the same.
*/
"use strict";

function NodeFileReader(location) {
	this.fs = require('fs');
	this.location = location;
	Object.freeze(this);
}
NodeFileReader.prototype.fileExists = function(filepath, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	//console.log('checking fullpath', fullPath);
	this.fs.stat(fullPath, function(err, stat) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(stat);
		}
	});
};
NodeFileReader.prototype.readDirectory = function(filepath, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	//console.log('read directory ', fullPath);
	this.fs.readdir(fullPath, function(err, data) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(data);
		}
	});
};
NodeFileReader.prototype.readTextFile = function(filepath, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	//console.log('read file ', fullPath);
	this.fs.readFile(fullPath, { encoding: 'utf-8'}, function(err, data) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(data);
		}
	});
};/**
* This class is a file writer for Node.  It can be used with node.js and node-webkit.
* cordova requires using another class, but the interface should be the same.
*/
"use strict";

function NodeFileWriter(location) {
	this.fs = require('fs');
	this.location = location;
	Object.freeze(this);
}
NodeFileWriter.prototype.createDirectory = function(filepath, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	this.fs.mkdir(fullPath, function(err) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(filepath);
		}
	});
};
NodeFileWriter.prototype.writeTextFile = function(filepath, data, callback) {
	var fullPath = FILE_ROOTS[this.location] + filepath;
	var options = { encoding: 'utf-8'};
	this.fs.writeFile(fullPath, data, options, function(err) {
		if (err) {
			err.filepath = filepath;
			callback(err);
		} else {
			callback(filepath);
		}
	});
};/**
* This class reads USX files and creates an equivalent object tree
* elements = [usx, book, chapter, para, verse, note, char];
* paraStyle = [b, d, cl, cp, h, li, p, pc, q, q2, mt, mt2, mt3, mte, toc1, toc2, toc3, ide, ip, ili, ili2, is, m, mi, ms, nb, pi, s, sp];
* charStyle = [add, bk, it, k, fr, fq, fqa, ft, wj, qs, xo, xt];
*/
"use strict";

function USXParser() {
}
USXParser.prototype.readBook = function(data) {
	var reader = new XMLTokenizer(data);
	var nodeStack = [];
	var node;
	var tempNode = {};
	var count = 0;
	while (tokenType !== XMLNodeType.END && count < 300000) {

		var tokenType = reader.nextToken();

		var tokenValue = reader.tokenValue();
		//console.log('type=|' + type + '|  value=|' + value + '|');
		count++;

		switch(tokenType) {
			case XMLNodeType.ELE_OPEN:
				tempNode = { tagName: tokenValue };
				tempNode.whiteSpace = (priorType === XMLNodeType.WHITESP) ? priorValue : '';
				//console.log(tokenValue, priorType, '|' + priorValue + '|');
				break;
			case XMLNodeType.ATTR_NAME:
				tempNode[tokenValue] = '';
				break;
			case XMLNodeType.ATTR_VALUE:
				tempNode[priorValue] = tokenValue;
				break;
			case XMLNodeType.ELE_END:
				tempNode.emptyElement = false;
				node = this.createUSXObject(tempNode);
				//console.log(node.openElement());
				if (nodeStack.length > 0) {
					nodeStack[nodeStack.length -1].addChild(node);
				}
				nodeStack.push(node);
				break;
			case XMLNodeType.TEXT:
				node = new Text(tokenValue);
				//console.log(node.text);
				nodeStack[nodeStack.length -1].addChild(node);
				break;
			case XMLNodeType.ELE_EMPTY:
				tempNode.emptyElement = true;
				node = this.createUSXObject(tempNode);
				//console.log(node.openElement());
				nodeStack[nodeStack.length -1].addChild(node);
				break;
			case XMLNodeType.ELE_CLOSE:
				node = nodeStack.pop();
				//console.log(node.closeElement());
				if (node.tagName !== tokenValue) {
					throw new Error('closing element mismatch ' + node.openElement() + ' and ' + tokenValue);
				}
				break;
			case XMLNodeType.WHITESP:
				// do nothing
				break;
			case XMLNodeType.PROG_INST:
				// do nothing
				break;
			case XMLNodeType.END:
				// do nothing
				break;
			default:
				throw new Error('The XMLNodeType ' + tokenType + ' is unknown in USXParser.');
		}
		var priorType = tokenType;
		var priorValue = tokenValue;
	}
	return(node);
};
USXParser.prototype.createUSXObject = function(tempNode) {
	switch(tempNode.tagName) {
		case 'char':
			return(new Char(tempNode));
		case 'note':
			return(new Note(tempNode));
		case 'verse':
			return(new Verse(tempNode));
		case 'para':
			return(new Para(tempNode));
		case 'chapter':
			return(new Chapter(tempNode));
		case 'book':
			return(new Book(tempNode));
		case 'usx':
			return(new USX(tempNode));
		default:
			throw new Error('USX element name ' + tempNode.tagName + ' is not known to USXParser.');
	}
};
/**
* This class does a stream read of an XML string to return XML tokens and their token type.
*/
"use strict";

var XMLNodeType = Object.freeze({ELE_OPEN:'ele-open', ATTR_NAME:'attr-name', ATTR_VALUE:'attr-value', ELE_END:'ele-end', 
			WHITESP:'whitesp', TEXT:'text', ELE_EMPTY:'ele-empty', ELE_CLOSE:'ele-close', PROG_INST:'prog-inst', END:'end'});

function XMLTokenizer(data) {
	this.data = data;
	this.position = 0;

	this.tokenStart = 0;
	this.tokenEnd = 0;

	this.state = Object.freeze({ BEGIN:'begin', START:'start', WHITESP:'whitesp', TEXT:'text', ELE_START:'ele-start', ELE_OPEN:'ele-open', 
		EXPECT_EMPTY_ELE:'expect-empty-ele', ELE_CLOSE:'ele-close', 
		EXPECT_ATTR_NAME:'expect-attr-name', ATTR_NAME:'attr-name', EXPECT_ATTR_VALUE:'expect-attr-value1', ATTR_VALUE:'attr-value', 
		PROG_INST:'prog-inst', END:'end' });
	this.current = this.state.BEGIN;

	Object.seal(this);
}
XMLTokenizer.prototype.tokenValue = function() {
	return(this.data.substring(this.tokenStart, this.tokenEnd));
};
XMLTokenizer.prototype.nextToken = function() {
	this.tokenStart = this.position;
	while(this.position < this.data.length) {
		var chr = this.data[this.position++];
		//console.log(this.current, chr, chr.charCodeAt(0));
		switch(this.current) {
			case this.state.BEGIN:
				if (chr === '<') {
					this.current = this.state.ELE_START;
					this.tokenStart = this.position;
				}
				break;
			case this.state.START:
				if (chr === '<') {
					this.current = this.state.ELE_START;
					this.tokenStart = this.position;
				}
				else if (chr === ' ' || chr === '\t' || chr === '\n' || chr === '\r') {
					this.current = this.state.WHITESP;
					this.tokenStart = this.position -1;
				}
				else {
					this.current = this.state.TEXT;
					this.tokenStart = this.position -1;
				}
				break;
			case this.state.WHITESP:
				if (chr === '<') {
					this.current = this.state.START;
					this.position--;
					this.tokenEnd = this.position;
					return(XMLNodeType.WHITESP);
				}
				else if (chr !== ' ' && chr !== '\t' && chr !== '\n' && chr !== '\r') {
					this.current = this.state.TEXT;
				}
				break;
			case this.state.TEXT:
				if (chr === '<') {
					this.current = this.state.START;
					this.position--;
					this.tokenEnd = this.position;
					return(XMLNodeType.TEXT);
				}
				break;
			case this.state.ELE_START:
				if (chr === '/') {
					this.current = this.state.ELE_CLOSE;
					this.tokenStart = this.position;
				} 
				else if (chr === '?') {
					this.current = this.state.PROG_INST;
					this.tokenStart = this.position;
				} 
				else {
					this.current = this.state.ELE_OPEN;
				}
				break;
			case this.state.ELE_OPEN:
				if (chr === ' ') {
					this.current = this.state.EXPECT_ATTR_NAME;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ELE_OPEN);
				} 
				else if (chr === '>') {
					this.current = this.state.START;
					return(XMLNodeType.ELE_END);
				}
				else if (chr === '/') {
					this.current = this.state.EXPECT_EMPTY_ELE;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ELE_OPEN);
				}
				break;
			case this.state.ELE_CLOSE:
				if (chr === '>') {
					this.current = this.state.START;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ELE_CLOSE);
				}
				break;
			case this.state.EXPECT_ATTR_NAME:
				if (chr === '>') {
					this.current = this.state.START;
					this.tokenEnd = this.tokenStart;
					return(XMLNodeType.ELE_END);
				}
				else if (chr === '/') {
					this.current = this.state.EXPECT_EMPTY_ELE;
				}
				else if (chr !== ' ') {
					this.current = this.state.ATTR_NAME;
					this.tokenStart = this.position -1;		
				}
				break;
			case this.state.EXPECT_EMPTY_ELE:
				if (chr === '>') {
					this.current = this.state.START;
					this.tokenEnd = this.tokenStart;
					return(XMLNodeType.ELE_EMPTY);
				}
				break;
			case this.state.ATTR_NAME:
				if (chr === '=') {
					this.current = this.state.EXPECT_ATTR_VALUE;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ATTR_NAME);
				}
				break;
			case this.state.EXPECT_ATTR_VALUE:
				if (chr === '"') {
					this.current = this.state.ATTR_VALUE;
					this.tokenStart = this.position;
				} else if (chr !== ' ') {
					throw new Error();
				}
				break;
			case this.state.ATTR_VALUE:
				if (chr === '"') {
					this.current = this.state.EXPECT_ATTR_NAME;
					this.tokenEnd = this.position -1;
					return(XMLNodeType.ATTR_VALUE);
				}
				break;
			case this.state.PROG_INST:
				if (chr === '>') {
					this.current = this.state.START;
					this.tokenStart -= 2;
					this.tokenEnd = this.position;
					return(XMLNodeType.PROG_INST);
				}
				break;
			default:
				throw new Error('Unknown state ' + this.current);
		}
	}
	return(XMLNodeType.END);
};
/**
* This object of the Director pattern, it contains a boolean member for each type of asset.
* Setting a member to true will be used by the Builder classes to control which assets are built.
*/
"use strict";

function AssetType(location, versionCode) {
	this.location = location;
	this.versionCode = versionCode;
	this.chapterFiles = false;
	this.tableContents = false;
	this.concordance = false;
	this.history = false;
	this.styleIndex = false;
	this.html = false;// this one is not ready
	Object.seal(this);
}
AssetType.prototype.mustDoQueue = function(filename) {
	switch(filename) {
		case 'chapterMetaData.json':
			this.chapterFiles = true;
			break;
		case 'toc.json':
			this.tableContents = true;
			break;
		case 'concordance.json':
			this.concordance = true;
			break;
		case 'history.json':
			this.history = true;
			break;
		case 'styleIndex.json':
			this.styleIndex = true;
			break;
		default:
			throw new Error('File ' + filename + ' is not known in AssetType.mustDo.');
	}
};
AssetType.prototype.toBeDoneQueue = function() {
	var toDo = [];
	if (this.chapterFiles) {
		toDo.push('chapterMetaData.json');
	}
	if (this.tableContents) {
		toDo.push('toc.json');
	}
	if (this.concordance) {
		toDo.push('concordance.json');
	}
	if (this.history) {
		toDo.push('history.json');
	}
	if (this.styleIndex) {
		toDo.push('styleIndex.json');
	}
	return(toDo);
};
AssetType.prototype.getUSXPath = function(filename) {
	return(this.versionCode + '/USX/' + filename);
};
AssetType.prototype.getAppPath = function(filename) {
	return(this.versionCode + '/app/' + filename);
};
/**
* The class controls the construction and loading of asset objects.  It is designed to be used
* one both the client and the server.  It is a "builder" controller that uses the AssetType
* as a "director" to control which assets are built.
*/
"use strict";

function AssetController(types) {
	this.types = types;
	this.checker = new AssetChecker(types);
	this.loader = new AssetLoader(types);
}
AssetController.prototype.tableContents = function() {
	return(this.loader.toc);
};
AssetController.prototype.concordance = function() {
	return(this.loader.concordance);
};
AssetController.prototype.history = function() {
	return(this.loader.history);
};
AssetController.prototype.styleIndex = function() {
	return(this.loader.styleIndex);
};
AssetController.prototype.checkBuildLoad = function(callback) {
	var that = this;
	this.checker.check(function(absentTypes) {
		var builder = new AssetBuilder(absentTypes);
		builder.build(function() {
			that.loader.load(function(loadedTypes) {
				callback(loadedTypes);
			});
		});
	});
};
AssetController.prototype.check = function(callback) {
	this.checker.check(function(absentTypes) {
		console.log('finished to be built types', absentTypes);
		callback(absentTypes);
	});
};
AssetController.prototype.build = function(callback) {
	var builder = new AssetBuilder(this.types);
	builder.build(function() {
		console.log('finished asset build');
		callback();
	});
};
AssetController.prototype.load = function(callback) {
	this.loader.load(function(loadedTypes) {
		console.log('finished assetcontroller load');
		callback(loadedTypes);
	});
};
/**
* This class checks for the presence of each assets that is required.
* It should be expanded to check for the correct version of each asset as well, 
* once assets are versioned.
*/
"use strict";

function AssetChecker(types) {
	this.types = types;
}
AssetChecker.prototype.check = function(callback) {
	var that = this;
	var result = new AssetType(this.types.location, this.types.versionCode);
	var reader = new NodeFileReader(that.types.location);
	var toDo = this.types.toBeDoneQueue();
	checkExists(toDo.shift());

	function checkExists(filename) {
		if (filename) {
			var fullPath = that.types.getAppPath(filename);
			console.log('checking for ', fullPath);
			reader.fileExists(fullPath, function(stat) {
				if (stat.errno) {
					if (stat.code === 'ENOENT') {
						console.log('check exists ' + filename + ' is not found');
						result.mustDoQueue(filename);
					} else {
						console.log('check exists for ' + filename + ' failure ' + JSON.stringify(stat));
					}
				} else {
					// Someday I should check version when check succeeeds.  When version is known.
					console.log('check succeeds for ', filename);
				}
				checkExists(toDo.shift());
			});
		} else {
			callback(result);
		}
	}
};
/**
* The Table of Contents and Concordance must be created by processing the entire text.  Since the parsing of the XML
* is a significant amount of the time to do this, this class reads over the entire Bible text and creates
* all of the required assets.
*/
"use strict";

function AssetBuilder(types) {
	this.types = types;
	this.builders = [];
	if (types.chapterFiles) {
		this.builders.push(new ChapterBuilder(types));
	}
	if (types.tableContents) {
		this.builders.push(new TOCBuilder());
	}
	if (types.concordance) {
		var concordanceBuilder = new ConcordanceBuilder();
		this.builders.push(concordanceBuilder);
		this.builders.push(new WordCountBuilder(concordanceBuilder.concordance));
	}
	if (types.history) { 
		// do nothing 
	}
	if (types.styleIndex) {
		this.builders.push(new StyleIndexBuilder());
	}
	if (types.html) {
		this.builders.push(new HTMLBuilder()); // HTMLBuilder does NOT yet have the correct interface for this.
	}
	this.reader = new NodeFileReader(types.location);
	this.parser = new USXParser();
	this.writer = new NodeFileWriter(types.location);
	this.filesToProcess = [];
	Object.freeze(this);
}
AssetBuilder.prototype.build = function(callback) {
	if (this.builders.length > 0) {
		var that = this;
		this.filesToProcess.splice(0);
		var canon = new Canon();
		for (var i=0; i<canon.books.length; i++) {
			this.filesToProcess.push(canon.books[i].code + '.usx');
		}
		processReadFile(this.filesToProcess.shift());
	} else {
		callback();
	}
	function processReadFile(file) {
		if (file) {
			that.reader.readTextFile(that.types.getUSXPath(file), function(data) {
				if (data.errno) {
					console.log('file read err ', JSON.stringify(data));
					callback(data);
				} else {
					var rootNode = that.parser.readBook(data);
					for (var i=0; i<that.builders.length; i++) {
						that.builders[i].readBook(rootNode);
					}
					processReadFile(that.filesToProcess.shift());
				}
			});
		} else {
			processWriteResult(that.builders.shift());
		}
	}
	function processWriteResult(builder) {
		if (builder) {
			var json = builder.toJSON();
			var filepath = that.types.getAppPath(builder.filename);
			that.writer.writeTextFile(filepath, json, function(filename) {
				if (filename.errno) {
					console.log('file write failure ', filename);
					callback(filename);
				} else {
					console.log('file write success ', filename);
					processWriteResult(that.builders.shift());
				}
			});
		} else {
			callback();
		}
	}
};
/**
* This class traverses the USX data model in order to find each book, and chapter
* in order to create a table of contents that is localized to the language of the text.
*/
"use strict";

function TOCBuilder() {
	this.toc = new TOC();
	this.tocBook = null;
	this.filename = this.toc.filename;
	Object.seal(this);
}
TOCBuilder.prototype.readBook = function(usxRoot) {
	this.readRecursively(usxRoot);
};
TOCBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			var priorBook = null;
			if (this.tocBook) {
				this.tocBook.nextBook = node.code;
				priorBook = this.tocBook.code;
			}
			this.tocBook = new TOCBook(node.code);
			this.tocBook.priorBook = priorBook;
			this.toc.addBook(this.tocBook);
			break;
		case 'chapter':
			this.tocBook.lastChapter = node.number;
			break;
		case 'para':
			switch(node.style) {
				case 'h':
					this.tocBook.heading = node.children[0].text;
					break;
				case 'toc1':
					this.tocBook.title = node.children[0].text;
					break;
				case 'toc2':
					this.tocBook.name = node.children[0].text;
					break;
				case 'toc3':
					this.tocBook.abbrev = node.children[0].text;
					break;
			}
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};
TOCBuilder.prototype.toJSON = function() {
	return(this.toc.toJSON());
};/**
* This class traverses the USX data model in order to find each word, and 
* reference to that word.
*
* This solution might not be unicode safe. GNG Apr 2, 2015
*/
"use strict";

function ConcordanceBuilder() {
	this.concordance = new Concordance();
	this.filename = this.concordance.filename;
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	Object.seal(this);
}
ConcordanceBuilder.prototype.readBook = function(usxRoot) {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.readRecursively(usxRoot);
};
ConcordanceBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			this.bookCode = node.code;
			break;
		case 'chapter':
			this.chapter = node.number;
			break;
		case 'verse':
			this.verse = node.number;
			break;
		case 'text':
			var words = node.text.split(/\b/);
			for (var i=0; i<words.length; i++) {
				var word = words[i].replace(/[\u2000-\u206F\u2E00-\u2E7F\\'!"#\$%&\(\)\*\+,\-\.\/:;<=>\?@\[\]\^_`\{\|\}~\s0-9]/g, '');
				if (word.length > 0 && this.chapter > 0 && this.verse > 0) {
					var reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
					this.concordance.addEntry(word.toLowerCase(), reference);
				}
			}
			break;
		default:
			if ('children' in node) {
				for (i=0; i<node.children.length; i++) {
					this.readRecursively(node.children[i]);
				}
			}

	}
};
ConcordanceBuilder.prototype.toJSON = function() {
	return(this.concordance.toJSON());
};/**
* This class gets information from the concordance that was built, and produces 
* a word list with frequency counts for each word.
*/
"use strict";

function WordCountBuilder(concordance) {
	this.concordance = concordance;
	this.filename = 'wordCount.json';
}
WordCountBuilder.prototype.readBook = function(usxRoot) {
};
WordCountBuilder.prototype.toJSON = function() {
	var countMap = {};
	var freqMap = {};
	var index = this.concordance.index;
	var words = Object.keys(index);
	for (var i=0; i<words.length; i++) {
		var key = words[i];
		var len = index[key].length;
		countMap[key] = len;
		if (freqMap[len] === undefined) {
			freqMap[len] = [];
		}
		freqMap[len].push(key);
	}
	var wordSort = Object.keys(countMap).sort();
	var freqSort = Object.keys(freqMap).sort(function(a, b) {
		return(a - b);
	});
	var result = [];
	result.push('Num Words:  ' + wordSort.length);
	for (i=0; i<wordSort.length; i++) {
		var word = wordSort[i];
		result.push(word + ':\t\t' + countMap[word]);
	}
	for (i=0; i<freqSort.length; i++) {
		var freq = freqSort[i];
		var words = freqMap[freq];
		for (var j=0; j<words.length; j++) {
			result.push(freq + ':\t\t' + words[j]);
		}
	}
	return(result.join('\n'));
};
/**
* This class traverses the USX data model in order to find each style, and 
* reference to that style.  It builds an index to each style showing
* all of the references where each style is used.
*/
"use strict";

function StyleIndexBuilder() {
	this.styleIndex = new StyleIndex();
	this.filename = this.styleIndex.filename;
}
StyleIndexBuilder.prototype.readBook = function(usxRoot) {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.readRecursively(usxRoot);
};
StyleIndexBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			this.bookCode = node.code;
			var style = 'book.' + node.style;
			var reference = this.bookCode;
			this.styleIndex.addEntry(style, reference);
			break;
		case 'chapter':
			this.chapter = node.number;
			style = 'chapter.' + node.style;
			reference = this.bookCode + ':' + this.chapter;
			this.styleIndex.addEntry(style, reference);
			break;
		case 'verse':
			this.verse = node.number;
			style = 'verse.' + node.style;
			reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
			this.styleIndex.addEntry(style, reference);
			break;
		case 'usx':
		case 'text':
			// do nothing
			break;
		default:
			style = node.tagName + '.' + node.style;
			reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
			this.styleIndex.addEntry(style, reference);
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};
StyleIndexBuilder.prototype.toJSON = function() {
	return(this.styleIndex.toJSON());
};
/**
* This class iterates over the USX data model, and breaks it into files one for each chapter.
*
*/
function ChapterBuilder(types) {
	this.types = types;
	this.filename = 'chapterMetaData.json';
	Object.seal(this);
}
ChapterBuilder.prototype.readBook = function(usxRoot) {
	var that = this;
	var bookCode = ''; // set by side effect of breakBookIntoChapters
	var chapters = breakBookIntoChapters(usxRoot);

	var reader = new NodeFileReader(this.types.location);
	var writer = new NodeFileWriter(this.types.location);

	var oneChapter = chapters.shift();
	var chapterNum = findChapterNum(oneChapter);
	createDirectory(bookCode);

	function breakBookIntoChapters(usxRoot) {
		var chapters = [];
		var chapterNum = 0;
		var oneChapter = new USX({ version: 2.0 });
		for (var i=0; i<usxRoot.children.length; i++) {
			var childNode = usxRoot.children[i];
			switch(childNode.tagName) {
				case 'book':
					bookCode = childNode.code;
					break;
				case 'chapter':
					chapters.push(oneChapter);
					oneChapter = new USX({ version: 2.0 });
					chapterNum = childNode.number;
					break;
			}
			oneChapter.addChild(childNode);
		}
		chapters.push(oneChapter);
		return(chapters);
	}
	function findChapterNum(oneChapter) {
		for (var i=0; i<oneChapter.children.length; i++) {
			var child = oneChapter.children[i];
			if (child.tagName === 'chapter') {
				return(child.number);
			}
		}
		return(0);
	}
	function createDirectory(bookCode) {
		var filepath = that.types.getAppPath(bookCode);
		writer.createDirectory(filepath, function(dirName) {
			if (dirName.errno) {
				writeChapter(bookCode, chapterNum, oneChapter);				
			} else {
				writeChapter(bookCode, chapterNum, oneChapter);	
			}
		});
	}
	function writeChapter(bookCode, chapterNum, oneChapter) {
		var filepath = that.types.getAppPath(bookCode) + '/' + chapterNum + '.usx';
		var data = oneChapter.toUSX();
		writer.writeTextFile(filepath, data, function(filename) {	
			if (filename.errno) {
				console.log('ChapterBuilder.writeChapterFailure ', JSON.stringify(filename));
			} else {
				oneChapter = chapters.shift();
				if (oneChapter) {
					chapterNum = findChapterNum(oneChapter);
					writeChapter(bookCode, chapterNum, oneChapter);
				} else {
					// done
				}
			}
		});
	}
};
ChapterBuilder.prototype.toJSON = function() {
	//return(JSON.stringify(this.usxRoot));
};

/**
* This class traverses a DOM tree in order to create an equivalent HTML document.
*/
"use strict";

function HTMLBuilder() {
	this.result = [];
	this.filename = 'bible.html';
	Object.freeze(this);
}
HTMLBuilder.prototype.toHTML = function(fragment) {
	this.readRecursively(fragment);
	return(this.result.join(''));
};
HTMLBuilder.prototype.readRecursively = function(node) {
	switch(node.nodeType) {
		case 11: // fragment
			break;
		case 1: // element
			this.result.push('\n<', node.tagName.toLowerCase());
			for (var i=0; i<node.attributes.length; i++) {
				this.result.push(' ', node.attributes[i].nodeName, '="', node.attributes[i].value, '"');
			}
			this.result.push('>');
			break;
		case 3: // text
			this.result.push(node.wholeText);
			break;
		default:
			throw new Error('Unexpected nodeType ' + node.nodeType + ' in HTMLBuilder.toHTML().');
	}
	if ('childNodes' in node) {
		for (i=0; i<node.childNodes.length; i++) {
			this.readRecursively(node.childNodes[i]);
		}
	}
	if (node.nodeType === 1) {
		this.result.push('</', node.tagName.toLowerCase(), '>\n');
	}
};
HTMLBuilder.prototype.toJSON = function() {
	return(this.result.join(''));
};


/**
* This class loads each of the assets that is specified in the types file.
*
* On May 3, 2015 some performance checks were done
* 1) Toc Read 10.52ms  85.8KB heap increase
* 2) Toc Loaded 1.22ms  322KB heap increase
* 3) Concordance Read 20.99ms  7.695MB heap increase
* 4) Concordance Loaded 96.49ms  27.971MB heap increase
*/
"use strict";

function AssetLoader(types) {
	this.types = types;
	this.toc = new TOC();
	this.concordance = new Concordance();
	this.history = new History(types);
	this.styleIndex = new StyleIndex();
}
AssetLoader.prototype.load = function(callback) {
	var that = this;
	this.types.chapterFiles = false; // do not load this
	var result = new AssetType(that.types.location, that.types.versionCode);
	var reader = new NodeFileReader(that.types.location);
	var toDo = this.types.toBeDoneQueue();
	readTextFile(toDo.shift());

	function readTextFile(filename) {
		if (filename) {
			var fullPath = that.types.getAppPath(filename);
			reader.readTextFile(fullPath, function(data) {
				if (data.errno) {
					console.log('read concordance.json failure ' + JSON.stringify(data));
				} else {
					switch(filename) {
						case 'chapterMetaData.json':
							result.chapterFiles = true;
							break;
						case 'toc.json':
							result.tableContents = true;
							var bookList = JSON.parse(data);
							that.toc.fill(bookList);
							break;
						case 'concordance.json':
							result.concordance = true;
							var wordList = JSON.parse(data);
							that.concordance.fill(wordList);
							break;
						case 'history.json':
							result.history = true;
							var historyList = JSON.parse(data);
							that.history.fill(historyList);
							break;
						case 'styleIndex.json':
							result.styleIndex = true;
							var styleList = JSON.parse(data);
							that.styleIndex.fill(styleList);
							break;
						default:
							throw new Error('File ' + filename + ' is not known in AssetLoader.load.');

					}
				}
				readTextFile(toDo.shift());
			});
		} else {
			callback(result);
		}
	}
};
/**
* This class iterates over the USX data model, and translates the contents to DOM.
*
* This method generates a DOM tree that has exactly the same parentage as the USX model.
* This is probably a problem.  The easy insertion and deletion of nodes probably requires
* having a hierarchy of books and chapters. GNG April 13, 2015
*/
function DOMBuilder() {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.noteNum = 0;

	this.treeRoot = null;
	Object.seal(this);
}
DOMBuilder.prototype.toDOM = function(usxRoot) {
	//this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.noteNum = 0;
	this.treeRoot = document.createDocumentFragment();
	this.readRecursively(this.treeRoot, usxRoot);
	return(this.treeRoot);
};
DOMBuilder.prototype.readRecursively = function(domParent, node) {
	var domNode;
	//console.log('dom-parent: ', domParent.nodeName, domParent.nodeType, '  node: ', node.tagName);
	switch(node.tagName) {
		case 'usx':
			domNode = domParent;
			break;
		case 'book':
			this.bookCode = node.code;
			domNode = node.toDOM(domParent);
			break;
		case 'chapter':
			this.chapter = node.number;
			this.noteNum = 0;
			domNode = node.toDOM(domParent, this.bookCode);
			break;
		case 'para':
			domNode = node.toDOM(domParent);
			break;
		case 'verse':
			this.verse = node.number;
			domNode = node.toDOM(domParent, this.bookCode, this.chapter);
			break;
		case 'text':
			node.toDOM(domParent, this.bookCode, this.chapter, this.noteNum);
			domNode = domParent;
			break;
		case 'char':
			domNode = node.toDOM(domParent);
			break;
		case 'note':
			domNode = node.toDOM(domParent, this.bookCode, this.chapter, ++this.noteNum);
			break;
		default:
			throw new Error('Unknown tagname ' + node.tagName + ' in DOMBuilder.readBook');
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(domNode, node.children[i]);
		}
	}
};
/**
* This class is the root object of a parsed USX document
*/
"use strict";

function USX(node) {
	this.version = node.version;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // includes books, chapters, and paragraphs
	Object.freeze(this);
}
USX.prototype.tagName = 'usx';
USX.prototype.addChild = function(node) {
	this.children.push(node);
};
USX.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<usx version="' + this.version + elementEnd);
};
USX.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '\n</usx>');
};
USX.prototype.toUSX = function() {
	var result = [];
	this.buildUSX(result);
	return(result.join(''));
};
USX.prototype.toDOM = function() {
};
USX.prototype.buildUSX = function(result) {
	result.push('\uFEFF<?xml version="1.0" encoding="utf-8"?>');
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
/** deprecated, might redo when writing tests */
USX.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
USX.prototype.buildHTML = function(result) {
	result.push('\uFEFF<?xml version="1.0" encoding="utf-8"?>\n');
	result.push('<html><head>\n');
	result.push('\t<meta charset="utf-8" />\n');
	result.push('\t<meta name="format-detection" content="telephone=no" />\n');
	result.push('\t<meta name="msapplication-tap-highlight" content="no" />\n');
    result.push('\t<meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi" />\n');
	result.push('\t<link rel="stylesheet" href="../css/prototype.css"/>\n');
	result.push('\t<script type="text/javascript" src="cordova.js"></script>\n');
	result.push('\t<script type="text/javascript">\n');
	result.push('\t\tfunction onBodyLoad() {\n');
	result.push('\t\t\tdocument.addEventListener("deviceready", onDeviceReady, false);\n');
	result.push('\t\t}\n');
	result.push('\t\tfunction onDeviceReady() {\n');
	result.push('\t\t\t// app = new BibleApp();\n');
	result.push('\t\t\t// app.something();\n');
	result.push('\t\t}\n');
	result.push('\t</script>\n');
	result.push('</head><body onload="onBodyLoad()">');
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildHTML(result);
	}
	result.push('\n</body></html>');
};
/**
* This class contains a book of the Bible
*/
"use strict";

function Book(node) {
	this.code = node.code;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // contains text
	Object.freeze(this);
}
Book.prototype.tagName = 'book';
Book.prototype.addChild = function(node) {
	this.children.push(node);
};
Book.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<book code="' + this.code + '" style="' + this.style + elementEnd);
};
Book.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</book>');
};
Book.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Book.prototype.toDOM = function(parentNode) {
	var article = document.createElement('article');
	article.setAttribute('id', this.code);
	article.setAttribute('class', this.style);
	parentNode.appendChild(article);
	return(article);
};
/** deprecated, might redo when writing tests */
Book.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Book.prototype.buildHTML = function(result) {
};/**
* This object contains information about a chapter of the Bible from a parsed USX Bible document.
*/
"use strict";

function Chapter(node) {
	this.number = node.number;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	Object.freeze(this);
}
Chapter.prototype.tagName = 'chapter';
Chapter.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<chapter number="' + this.number + '" style="' + this.style + elementEnd);
};
Chapter.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</chapter>');
};
Chapter.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	result.push(this.closeElement());
};
Chapter.prototype.toDOM = function(parentNode, bookCode) {
	var reference = bookCode + ':' + this.number;
	var section = document.createElement('section');
	section.setAttribute('id', reference);
	parentNode.appendChild(section);

	var child = document.createElement('p');
	child.setAttribute('class', this.style);
	child.textContent = this.number;
	section.appendChild(child);
	return(section);
};
/** deprecated, might redo when writing tests */
Chapter.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Chapter.prototype.buildHTML = function(result) {
	result.push('\n<p id="' + this.number + '" class="' + this.style + '">', this.number, '</p>');
};/**
* This object contains a paragraph of the Bible text as parsed from a USX version of the Bible.
*/
"use strict";

function Para(node) {
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = []; // contains verse | note | char | text
	Object.freeze(this);
}
Para.prototype.tagName = 'para';
Para.prototype.addChild = function(node) {
	this.children.push(node);
};
Para.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<para style="' + this.style + elementEnd);
};
Para.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</para>');
};
Para.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Para.prototype.toDOM = function(parentNode) {
	var identStyles = [ 'ide', 'sts', 'rem', 'h', 'toc1', 'toc2', 'toc3', 'cl' ];
	var child = document.createElement('p');
	child.setAttribute('class', this.style);
	if (identStyles.indexOf(this.style) === -1) {
		parentNode.appendChild(child);
	}
	return(child);
};
/** deprecated, might redo when writing tests */
Para.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Para.prototype.buildHTML = function(result) {
	var identStyles = [ 'ide', 'sts', 'rem', 'h', 'toc1', 'toc2', 'toc3', 'cl' ];
	if (identStyles.indexOf(this.style) === -1) {
		result.push('\n<p class="' + this.style + '">');
		for (var i=0; i<this.children.length; i++) {
			this.children[i].buildHTML(result);
		}
		result.push('</p>');
	}
};
/**
* This chapter contains the verse of a Bible text as parsed from a USX Bible file.
*/
"use strict";

function Verse(node) {
	this.number = node.number;
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	Object.freeze(this);
}
Verse.prototype.tagName = 'verse';
Verse.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	return('<verse number="' + this.number + '" style="' + this.style + elementEnd);
};
Verse.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</verse>');
};
Verse.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	result.push(this.closeElement());
};
Verse.prototype.toDOM = function(parentNode, bookCode, chapterNum) {
	var reference = bookCode + ':' + chapterNum + ':' + this.number;
	var child = document.createElement('span');
	child.setAttribute('id', reference);
	child.setAttribute('class', this.style);
	child.textContent = ' ' + this.number + ' ';
	parentNode.appendChild(child);
	return(child);
};
/** deprecated, might redo when writing tests */
Verse.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Verse.prototype.buildHTML = function(result) {
	result.push('<span id="' + this.number + '" class="' + this.style + '">', this.number, ' </span>');
};/**
* This class contains a Note from a USX parsed Bible
*/
"use strict";

function Note(node) {
	this.caller = node.caller.charAt(0);
	if (this.caller !== '+') {
		console.log(JSON.stringify(node));
		throw new Error('Note caller with no +');
	}
	this.style = node.style;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = [];
	Object.freeze(this);
}
Note.prototype.tagName = 'note';
Note.prototype.addChild = function(node) {
	this.children.push(node);
};
Note.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	if (this.style === 'x') {
		return('<note caller="' + this.caller + ' ' + this.note + '" style="' + this.style + elementEnd);
	} else {
		return('<note style="' + this.style + '" caller="' + this.caller + ' ' + this.note + elementEnd);
	}
};
Note.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</note>');
};
Note.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Note.prototype.toDOM = function(parentNode, bookCode, chapterNum, noteNum) {
	var nodeId = bookCode + chapterNum + '-' + noteNum;
	var refChild = document.createElement('span');
	refChild.setAttribute('id', nodeId);
	refChild.setAttribute('class', 'top' + this.style);
	switch(this.style) {
		case 'f':
			refChild.textContent = '\u261E ';
			break;
		case 'x':
			refChild.textContent = '\u261B ';
			break;
		default:
			refChild.textContent = '* ';
	}
	parentNode.appendChild(refChild);
	refChild.addEventListener('click', function() {
		event.stopImmediatePropagation();
		document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_NOTE, { detail: { id: this.id }}));
	});
	return(refChild);
};
/** deprecated, might redo when writing tests */
Note.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Note.prototype.buildHTML = function(result) {
	result.push('<span class="' + this.style + '">');
	result.push(this.caller);
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildHTML(result);
	}
	result.push('</span>');
};/**
* This class contains a character style as parsed from a USX Bible file.
*/
"use strict";

function Char(node) {
	this.style = node.style;
	this.closed = node.closed;
	this.whiteSpace = node.whiteSpace;
	this.emptyElement = node.emptyElement;
	this.children = [];
	Object.freeze(this);
}
Char.prototype.tagName = 'char';
Char.prototype.addChild = function(node) {
	this.children.push(node);
};
Char.prototype.openElement = function() {
	var elementEnd = (this.emptyElement) ? '" />' : '">';
	if (this.closed) {
		return('<char style="' + this.style + '" closed="' + this.closed + elementEnd);
	} else {
		return('<char style="' + this.style + elementEnd);
	}
};
Char.prototype.closeElement = function() {
	return(this.emptyElement ? '' : '</char>');
};
Char.prototype.buildUSX = function(result) {
	result.push(this.whiteSpace, this.openElement());
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildUSX(result);
	}
	result.push(this.closeElement());
};
Char.prototype.toDOM = function(parentNode) {
	if (this.style === 'fr' || this.style === 'xo') {
		return(null);// this drop these styles from presentation
	}
	else {
		var child = document.createElement('span');
		child.setAttribute('class', this.style);
		parentNode.appendChild(child);
		return(child);
	}
};
/** deprecated, might redo when writing tests */
Char.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Char.prototype.buildHTML = function(result) {
	result.push('<span class="' + this.style + '">');
	for (var i=0; i<this.children.length; i++) {
		this.children[i].buildHTML(result);
	}
	result.push('</span>');
};/**
* This class contains a text string as parsed from a USX Bible file.
*/
"use strict";

function Text(text) {
	this.text = text;
	Object.freeze(this);
}
Text.prototype.tagName = 'text';
Text.prototype.buildUSX = function(result) {
	result.push(this.text);
};
Text.prototype.toDOM = function(parentNode, bookCode, chapterNum, noteNum) {
	if (parentNode === null || parentNode.tagName === 'ARTICLE') {
		// discard text node
	} else {
		var nodeId = bookCode + chapterNum + '-' + noteNum;
		var parentClass = parentNode.getAttribute('class');
		if (parentClass.substr(0, 3) === 'top') {
			var textNode = document.createElement('span');
			textNode.setAttribute('class', parentClass.substr(3));
			textNode.setAttribute('note', this.text);
			parentNode.appendChild(textNode);
			textNode.addEventListener('click', function() {
				event.stopImmediatePropagation();
				document.body.dispatchEvent(new CustomEvent(BIBLE.HIDE_NOTE, { detail: { id: nodeId }}));
			});
		} else if (parentClass[0] === 'f' || parentClass[0] === 'x') {
			parentNode.setAttribute('note', this.text); // hide footnote text in note attribute of parent.
			parentNode.addEventListener('click', function() {
				event.stopImmediatePropagation();
				document.body.dispatchEvent(new CustomEvent(BIBLE.HIDE_NOTE, { detail: { id: nodeId }}));
			});
		}
		else {
			var child = document.createTextNode(this.text);
			parentNode.appendChild(child);
		}
	}
};
/** deprecated, might redo when writing tests */
Text.prototype.toHTML = function() {
	var result = [];
	this.buildHTML(result);
	return(result.join(''));
};
/** deprecated */
Text.prototype.buildHTML = function(result) {
	result.push(this.text);
};
/**
* This simple class is used to measure performance of the App.
* It is not part of the production system, but is used during development
* to instrument the code.
*/
"use strict";

function Performance(message) {
	this.startTime = performance.now();
	var memory = process.memoryUsage();
	this.heapUsed = memory.heapUsed;
	console.log(message, 'heapUsed:', this.heapUsed, 'heapTotal:', memory.heapTotal);
}
Performance.prototype.duration = function(message) {
	var now = performance.now();
	var duration = now - this.startTime;
	var heap = process.memoryUsage().heapUsed;
	var memChanged = heap - this.heapUsed;
	console.log(message, duration + 'ms', memChanged/1024 + 'KB');
	this.startTime = now;
	this.heapUsed = heap;
};
