"use strict";
/**
* This class initializes the App with the correct Bible versions
* and starts.
*/
function AppInitializer() {
	this.appViewController = null;
	Object.seal(this);
}
AppInitializer.prototype.begin = function() {
	var that = this;
    var settingStorage = new SettingStorage();
    settingStorage.create(function() {
    	var fileMover = new FileMover(settingStorage);
    	console.log('START MOVE FILES');
		fileMover.copyFiles(function() {
			console.log('DONE WITH MOVE FILES');
			settingStorage.initSettings();   
		    settingStorage.getCurrentVersion(function(versionFilename) {
				if (versionFilename == null) {
					deviceSettings.prefLanguage(function(locale) {
						var parts = locale.split('-');
						versionFilename = settingStorage.defaultVersion(parts[0]);
						settingStorage.setCurrentVersion(versionFilename);
						changeVersionHandler(versionFilename);
					});
				} else {
					changeVersionHandler(versionFilename);
				}
			});
    	});
    });
    
    document.body.addEventListener(BIBLE.CHG_VERSION, function(event) {
		settingStorage.setCurrentVersion(event.detail.version);
		changeVersionHandler(event.detail.version);
	});
		
	function changeVersionHandler(versionFilename) {
		console.log('CHANGE VERSION TO', versionFilename);
		var bibleVersion = new BibleVersion();
		bibleVersion.fill(versionFilename, function() {
			if (that.appViewController) {
				that.appViewController.close();
			}
			that.appViewController = new AppViewController(bibleVersion, settingStorage);
			that.appViewController.begin();			
		});
	}
};/**
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
var BIBLE = { CHG_VERSION: 'bible-chg-version', 
		SHOW_TOC: 'bible-show-toc', // present toc page, create if needed
		SHOW_SEARCH: 'bible-show-search', // present search page, create if needed
		SHOW_QUESTIONS: 'bible-show-questions', // present questions page, create first
		SHOW_HISTORY: 'bible-show-history', // present history tabs
		HIDE_HISTORY: 'bible-hide-history', // hide history tabs
		SHOW_PASSAGE: 'bible-show-passage', // show passage in codex view
		SHOW_SETTINGS: 'bible-show-settings', // show settings view
		CHG_HEADING: 'bible-chg-heading', // change title at top of page as result of user scrolling
		SHOW_NOTE: 'bible-show-note', // Show footnote as a result of user action
		HIDE_NOTE: 'bible-hide-note', // Hide footnote as a result of user action
	};
var SERVER_HOST = 'cloud.shortsands.com';//'10.0.1.18';
var SERVER_PORT = '8080';

function bibleShowNoteClick(nodeId) {
	console.log('show note clicked', nodeId);
	event.stopImmediatePropagation();
	var node = document.getElementById(nodeId);
	if (node) {
		document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_NOTE, { detail: { id: node }}));
		node.setAttribute('onclick', "bibleHideNoteClick('" + nodeId + "');");
	}
}
function bibleHideNoteClick(nodeId) {
	console.log('hide note clicked', nodeId);
	event.stopImmediatePropagation();
	var node = document.getElementById(nodeId);
	if (node) {
		document.body.dispatchEvent(new CustomEvent(BIBLE.HIDE_NOTE, { detail: { id: node }}));
		node.setAttribute('onclick', "bibleShowNoteClick('" + nodeId + "');");
	}
}

function AppViewController(version, settingStorage) {
	this.version = version;
	document.body.setAttribute('style', 'direction: ' + this.version.direction);
	this.settingStorage = settingStorage;
	
	this.database = new DatabaseHelper(version.filename, true);
	this.chapters = new ChaptersAdapter(this.database);
    this.verses = new VersesAdapter(this.database);
	this.tableAdapter = new TableContentsAdapter(this.database);
	this.concordance = new ConcordanceAdapter(this.database);
	this.styleIndex = new StyleIndexAdapter(this.database);
	this.styleUse = new StyleUseAdapter(this.database);

	this.userDatabase = new DatabaseHelper(version.userFilename, false);
	this.history = new HistoryAdapter(this.userDatabase);
	this.history.create(function(){});
	this.questions = new QuestionsAdapter(this.userDatabase);
	this.questions.create(function(){});
}
AppViewController.prototype.begin = function(develop) {
	this.tableContents = new TOC(this.tableAdapter);
	this.concordance = new Concordance(this.concordance);
	var that = this;
	this.tableContents.fill(function() {

		console.log('loaded toc', that.tableContents.size());
		that.copyrightView = new CopyrightView(that.version);
		that.header = new HeaderView(that.tableContents, that.version);
		that.header.showView();
		that.tableContentsView = new TableContentsView(that.tableContents, that.copyrightView);
		that.tableContentsView.rootNode.style.top = that.header.barHite + 'px';  // Start view at bottom of header.
		that.searchView = new SearchView(that.tableContents, that.concordance, that.verses, that.history, that.version);
		that.searchView.rootNode.style.top = that.header.barHite + 'px';  // Start view at bottom of header.
		that.codexView = new CodexView(that.chapters, that.tableContents, that.header.barHite, that.copyrightView);
		that.historyView = new HistoryView(that.history, that.tableContents);
		that.historyView.rootNode.style.top = that.header.barHite + 'px';
		that.questionsView = new QuestionsView(that.questions, that.verses, that.tableContents, that.version);
		that.questionsView.rootNode.style.top = that.header.barHite + 'px'; // Start view at bottom of header.
		that.settingsView = new SettingsView(that.settingStorage, that.verses);
		that.settingsView.rootNode.style.top = that.header.barHite + 'px';  // Start view at bottom of header.
		that.touch = new Hammer(document.getElementById('codexRoot'));
		setInitialFontSize();
		Object.seal(that);

		switch(develop) {
		case 'TableContentsView':
			that.tableContentsView.showView();
			break;
		case 'SearchView':
			that.searchView.showView('risen');
			break;
		case 'HistoryView':
			that.historyView.showView();
			break;
		case 'QuestionsView':
			that.questionsView.showView();
			break;
		case 'SettingsView':
			that.settingsView.showView();
			break;
		case 'VersionsView':
			that.versionsView.showView();
			break;
		default:
			that.history.lastItem(function(lastItem) {
				if (lastItem instanceof IOError || lastItem === null || lastItem === undefined) {
					that.codexView.showView('JHN:1');
				} else {
					console.log('LastItem' + JSON.stringify(lastItem));
					that.codexView.showView(lastItem);
				}
			});
		}
		/* Turn off user selection, and selection popup */
		document.documentElement.style.webkitTouchCallout = 'none';
        document.documentElement.style.webkitUserSelect = 'none';
        
		enableHandlersExcept('NONE');

		document.body.addEventListener(BIBLE.SHOW_NOTE, function(event) {
			that.codexView.showFootnote(event.detail.id);
		});
		document.body.addEventListener(BIBLE.HIDE_NOTE, function(event) {
			that.codexView.hideFootnote(event.detail.id);
		});
		that.touch.on("panright", function(event) {
			if (event.deltaX > 4 * Math.abs(event.deltaY)) {
				that.historyView.showView();
			}
		});
		that.touch.on("panleft", function(event) {
			if (-event.deltaX > 4 * Math.abs(event.deltaY)) {
				that.historyView.hideView();
			}
		});
	});
	function setInitialFontSize() {
		that.settingStorage.getFontSize(function(fontSize) {
			if (fontSize == null) {
				var minDim = (window.innerWidth < window.innerHeight) ? window.innerWidth : window.innerHeight;
				var minDimIn = minDim * window.devicePixelRatio / 320;
				var fontSize = Math.sqrt(minDimIn) * 10;
			}
			document.documentElement.style.fontSize = fontSize + 'pt';			
		});
	}
	function showTocHandler(event) {
		disableHandlers();
		clearViews();		
		that.tableContentsView.showView();
		enableHandlersExcept(BIBLE.SHOW_TOC);
	}
	function showSearchHandler(event) {
		disableHandlers();
		clearViews();	
		that.searchView.showView();
		enableHandlersExcept(BIBLE.SHOW_SEARCH);
	}		
	function showPassageHandler(event) {
		disableHandlers();
		clearViews();
		that.codexView.showView(event.detail.id);
		enableHandlersExcept('NONE');
		var historyItem = { timestamp: new Date(), reference: event.detail.id, 
			source: 'P', search: event.detail.source };
		that.history.replace(historyItem, function(count) {});
	}
	function showQuestionsHandler(event) {
		disableHandlers();
		clearViews();	
		that.questionsView.showView();
		enableHandlersExcept(BIBLE.SHOW_QUESTIONS);
	}	
	function showSettingsHandler(event) {
		disableHandlers();
		clearViews();
		that.settingsView.showView();
		enableHandlersExcept(BIBLE.SHOW_SETTINGS);
	}	
	function clearViews() {
		// There is some redundancy here, I could just delete all grandchildren of body in one step
		that.tableContentsView.hideView();
		that.searchView.hideView();
		that.codexView.hideView();
		that.questionsView.hideView();
		that.settingsView.hideView();
		that.historyView.hideView();
	}
	function disableHandlers() {
		document.body.removeEventListener(BIBLE.SHOW_TOC, showTocHandler);
		document.body.removeEventListener(BIBLE.SHOW_SEARCH, showSearchHandler);
		document.body.removeEventListener(BIBLE.SHOW_PASSAGE, showPassageHandler);
		document.body.removeEventListener(BIBLE.SHOW_QUESTIONS, showQuestionsHandler);
		document.body.removeEventListener(BIBLE.SHOW_SETTINGS, showSettingsHandler);
	}
	function enableHandlersExcept(name) {
		if (name !== BIBLE.SHOW_TOC) document.body.addEventListener(BIBLE.SHOW_TOC, showTocHandler);
		if (name !== BIBLE.SHOW_SEARCH) document.body.addEventListener(BIBLE.SHOW_SEARCH, showSearchHandler);
		if (name !== BIBLE.SHOW_PASSAGE) document.body.addEventListener(BIBLE.SHOW_PASSAGE, showPassageHandler);
		if (name !== BIBLE.SHOW_QUESTIONS) document.body.addEventListener(BIBLE.SHOW_QUESTIONS, showQuestionsHandler);
		if (name !== BIBLE.SHOW_SETTINGS) document.body.addEventListener(BIBLE.SHOW_SETTINGS, showSettingsHandler);
	}
};
AppViewController.prototype.close = function() {
	console.log('CLOSE ', this.version);
	this.touch = null;
	// remove dom
	for (var i=document.body.children.length -1; i>=0; i--) {
		document.body.removeChild(document.body.children[i]);
	}
	// close database
	if (this.database) {
		this.database.close();
		this.database = null;
	}
	if (this.userDatabase) {
		this.userDatabase.close();
		this.userDatabase = null;
	}
	// views
	this.header = null;
	this.tableContentsView = null;
	this.searchView = null;
	this.codexView = null;
	this.historyView = null;
	this.questionsView = null;
	this.settingsView = null;
	this.copyrightView = null;
	// model
	this.tableContents = null;
	this.concordance = null;
};
/**
* This class contains user interface features for the display of the Bible text
*/
var CODEX_VIEW = {BEFORE: 0, AFTER: 1, MAX: 100000, SCROLL_TIMEOUT: 200};

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
	if (this.viewport.children.length > 0) {
		for (var i=this.viewport.children.length -1; i>=0; i--) {
			this.viewport.removeChild(this.viewport.children[i]);
		}
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
		that.currentNodeId = firstChapter.nodeId;
		document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: firstChapter }}));
		that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT);	// should be last thing to do		
	});
	function onScrollHandler(event) {
		//console.log('windowHeight=', window.innerHeight, '  scrollHeight=', document.body.scrollHeight, '  scrollY=', window.scrollY);
		//console.log('left', (document.body.scrollHeight - window.scrollY));
		if (window.scrollY <= window.innerHeight && ! that.userIsScrolling) {
			var firstNode = that.viewport.firstChild;
			var firstChapter = new Reference(firstNode.id.substr(3));
			var beforeChapter = that.tableContents.rowId(firstChapter) - 1;
			if (beforeChapter) {
				that.showChapters([beforeChapter], false, function() {
					that.checkChapterQueueSize('bottom');
					onScrollLastStep();
				});
			} else {
				onScrollLastStep();
			}
		} else if (document.body.scrollHeight - window.scrollY <= 2 * window.innerHeight) {
			var lastNode = that.viewport.lastChild;
			var lastChapter = new Reference(lastNode.id.substr(3));
			var nextChapter = that.tableContents.rowId(lastChapter) + 1;
			if (nextChapter) {
				that.showChapters([nextChapter], true, function() {
					that.checkChapterQueueSize('top');
					onScrollLastStep();
				});
			} else {
				onScrollLastStep();
			}
		} else {
			onScrollLastStep();
		}
	}
	function onScrollLastStep() {
		var ref = identifyCurrentChapter();//expensive solution
		if (ref && ref.nodeId !== that.currentNodeId) {
			that.currentNodeId = ref.nodeId;
			document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: ref }}));
		}
		that.userIsScrolling = false;
		that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT); // should be last thing to do
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
CodexView.prototype.showFootnote = function(note) {
	recurseChildren(note);
	
	function recurseChildren(node) {
		for (var i=0; i<node.children.length; i++) {
			var child = node.children[i];
			//console.log('show child', node.children.length, i, child.nodeName, child.getAttribute('class'));
			if ('children' in child) {
				recurseChildren(child);
			}
			if (child.nodeName === 'SPAN' && child.hasAttribute('note')) {
				child.appendChild(document.createTextNode(child.getAttribute('note')));
			}
		}
	}
};
/**
* This method removes the footnote by removing all of the text nodes under a note
* except the one that displays the link.
*/
CodexView.prototype.hideFootnote = function(note) {
	recurseChildren(note);
	
	function recurseChildren(node) {
		var nodeClass = (node.nodeType === 1) ? node.getAttribute('class') : null;
		for (var i=node.childNodes.length -1; i>=0; i--) {
			var child = node.childNodes[i];
			//console.log('FOUND ', node.childNodes.length, i, child.nodeName);
			if ('childNodes' in child) {
				recurseChildren(child);
			}
			if (child.nodeName === '#text' && nodeClass !== 'topf' && nodeClass !== 'topx') {
				node.removeChild(child);	
			}
		}
	}
};

/**
* NOTE: This is a global method, not a class method, because it
* is called by the event handler created in createCopyrightNotice.
*/
var COPYRIGHT_VIEW = null;

function addCopyrightViewNotice(event) {
	event.stopImmediatePropagation();
	var target = event.target.parentNode;
	target.appendChild(COPYRIGHT_VIEW);
	
	var rect = target.getBoundingClientRect();
	if (window.innerHeight < rect.top + rect.height) {
		// Scrolls notice up when text is not in view.
		// limits scroll to rect.top so that top remains in view.
		window.scrollBy(0, Math.min(rect.top, rect.top + rect.height - window.innerHeight));	
	}
}
/**
* This class is used to create the copyright notice that is put 
* at the bottom of each chapter, and the learn more page that appears
* when that is clicked.
*/
function CopyrightView(version) {
	this.version = version;
	this.copyrightNotice = this.createCopyrightNotice();
	COPYRIGHT_VIEW = this.createAttributionView();
	Object.seal(this);
}
CopyrightView.prototype.createCopyrightNotice = function() {
	var html = [];
	html.push('<p><span class="copyright">');
	html.push(this.version.copyright, '</span>');
	html.push('<span class="copylink" onclick="addCopyrightViewNotice(event)"> \u261E </span>', '</p>');
	return(html.join(''));
};
CopyrightView.prototype.createCopyrightNoticeDOM = function() {
	var root = document.createElement('p');
	var dom = new DOMBuilder();
	dom.addNode(root, 'span', 'copyright', this.version.copyright);
	var link = dom.addNode(root, 'span', 'copylink', ' \u261E ');
	link.addEventListener('click',  addCopyrightViewNotice);	
	return(root);
};
CopyrightView.prototype.createTOCTitleDOM = function() {
	if (this.version.ownerCode === 'WBT') {
		var title = this.version.localLanguageName + ' (' + this.version.silCode + ')';
	} else {
		title = this.version.localVersionName + ' (' + this.version.versionAbbr + ')';
	}
	var root = document.createElement('p');
	var dom = new DOMBuilder();
	dom.addNode(root, 'span', 'copyTitle', title);
	return(root);
};
/**
* Language (lang code), Translation Name (trans code),
* Copyright C year, Organization,
* Organization URL, link image
*/
CopyrightView.prototype.createAttributionView = function() {
	var dom = new DOMBuilder();
	var root = document.createElement('div');
	root.setAttribute('id', 'attribution');
	
	var closeIcon = drawCloseIcon(24, '#777777');
	closeIcon.setAttribute('id', 'closeIcon');
	root.appendChild(closeIcon);
	closeIcon.addEventListener('click', function(event) {
		if (root && root.parentNode) {
			root.parentNode.removeChild(root);
		}
	});
	
	var copyNode = dom.addNode(root, 'p', 'attribVers');
	dom.addNode(copyNode, 'span', null, this.version.copyright);
	
	if (this.version.introduction) {
		var intro = dom.addNode(root, 'div', 'introduction');
		intro.innerHTML = this.version.introduction;
	}
	
	var webAddress = 'http://' + this.version.ownerURL + '/';
	var link = dom.addNode(root, 'p', 'attribLink', webAddress);
	link.addEventListener('click', function(event) {
		cordova.InAppBrowser.open(webAddress, '_blank', 'location=yes');
	});
	return(root);
};

/**
* This class provides the user interface to display history as tabs,
* and to respond to user interaction with those tabs.
*/
var TAB_STATE = { HIDDEN:0, SHOW:1, VISIBLE:2, HIDE:3 };

function HistoryView(historyAdapter, tableContents) {
	this.historyAdapter = historyAdapter;
	this.tableContents = tableContents;
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
				var tab = document.createElement('li');
				tab.setAttribute('class', 'historyTab');
				root.appendChild(tab);

				var btn = document.createElement('button');
				btn.setAttribute('id', 'his' + historyNodeId);
				btn.setAttribute('class', 'historyTabBtn');
				btn.textContent = generateReference(historyNodeId);
				tab.appendChild(btn);
				btn.addEventListener('click', function(event) {
					console.log('btn clicked', this.id);
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

/**
* This class provides the user interface to the question and answer feature.
* This view class differs from some of the others in that it does not try
* to keep the data in memory, but simply reads the data from a file when
* needed.  Because the question.json file could become large, this approach
* is essential.
*/
function QuestionsView(questionsAdapter, versesAdapter, tableContents, version) {
	this.tableContents = tableContents;
	this.versesAdapter = versesAdapter;
	this.questions = new Questions(questionsAdapter, versesAdapter, tableContents, version);
	this.formatter = new DateTimeFormatter();
	this.dom = new DOMBuilder();
	this.viewRoot = null;
	this.rootNode = document.createElement('div');
	this.rootNode.id = 'questionsRoot';
	document.body.appendChild(this.rootNode);
	this.referenceInput = null;
	this.questionInput = null;
	Object.seal(this);
}
QuestionsView.prototype.showView = function() {
	var that = this;
	document.body.style.backgroundColor = '#FFF';
	this.questions.fill(function(results) {
		if (results instanceof IOError) {
			console.log('Error: QuestionView.showView.fill');
		} else {
			presentView();
		}
	});
	function presentView() {
		that.viewRoot = that.buildQuestionsView();
		that.rootNode.appendChild(that.viewRoot);

		that.questions.checkServer(function(results) {
			for (var i=0; i<results.length; i++) {
				var itemId = results[i];
				var questionNode = document.getElementById('que' + itemId);
				that.displayAnswer(questionNode);
			}
		});		
	}
};
QuestionsView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		// why not save scroll position
		for (var i=this.rootNode.children.length -1; i>=0; i--) {
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
		this.viewRoot = null;
	}
};
QuestionsView.prototype.buildQuestionsView = function() {
	var that = this;
	var root = document.createElement('div');
	root.setAttribute('id', 'questionsView');
	var numQuestions = this.questions.size();
	for (var i=0; i<numQuestions; i++) {
		var item = this.questions.find(i);
		buildOneQuestion(root, item);
	}
	includeInputBlock(root);
	return(root);

	function buildOneQuestion(parent, item) {
		var questionBorder = that.dom.addNode(parent, 'div', 'questionBorder');
		var wid = window.innerWidth * 0.74;
		questionBorder.setAttribute('style', 'width:' + wid + 'px');
		questionBorder.setAttribute('style', 'padding: 3px 3px');
		
		var aQuestion = that.dom.addNode(questionBorder, 'div', 'oneQuestion', null, 'que' + i);
		aQuestion.setAttribute('style', 'width:' + (wid - 6) + 'px');
		
		var line1 = that.dom.addNode(aQuestion, 'div', 'queTop');
		that.dom.addNode(line1, 'p', 'queRef', item.reference);
		that.dom.addNode(line1, 'p', 'queDate', that.formatter.localDatetime(item.askedDateTime));
		that.dom.addNode(aQuestion, 'p', 'queText', item.question);

		if (i === numQuestions -1) {
			that.displayAnswer(aQuestion);
		} else {
			aQuestion.addEventListener('click', displayAnswerOnRequest);	
		}
	}
	function displayAnswerOnRequest(event) {
		var selected = document.getElementById(this.id);
		selected.removeEventListener('click', displayAnswerOnRequest);
		that.displayAnswer(selected);
	}
	function includeInputBlock(parentNode) {
		var wid = window.innerWidth * 0.74;

		var inputTop = that.dom.addNode(parentNode, 'div', 'questionBorder');
		inputTop.setAttribute('style', 'width:' + wid + 'px');
		inputTop.setAttribute('style', 'padding: 5px 5px');		
		
		that.questionInput = that.dom.addNode(inputTop, 'textarea', 'questionField', null, 'inputText');
		that.questionInput.setAttribute('style', 'width:' + (wid - 10) + 'px');
		that.questionInput.setAttribute('rows', 10);
		that.versesAdapter.getVerses(['MAT:7:7'], function(results) {
			if (results instanceof IOError) {
				console.log('Error while getting MAT:7:7');
			} else {
				if (results.rows.length > 0) {
					var row = results.rows.item(0);
					that.questionInput.setAttribute('placeholder', row.html);
					// Hack to force display of placeholder when loaded.
					that.questionInput.style.display = 'none';
					that.questionInput.style.display = 'block';
				}	
			}
		});
		var quesBtn = that.dom.addNode(parentNode, 'button', null, null, 'inputBtn');
		quesBtn.appendChild(drawSendIcon(50, '#F7F7BB'));

		quesBtn.addEventListener('click', function(event) {
			console.log('submit button clicked');

			var item = new QuestionItem();
			item.reference = ''; // should be set by program based on user's position.
			item.question = that.questionInput.value;
			if (item.question && item.question.length > 5) {

				that.questions.addQuestion(item, function(error) {
					if (error) {
						console.error('error at server', error);
					} else {
						console.log('file is written to disk and server');
						parentNode.removeChild(inputTop);
						parentNode.removeChild(quesBtn);
						buildOneQuestion(parentNode, item);
					}
				});
			}
		});
	}
};
QuestionsView.prototype.displayAnswer = function(parent) {
	var idNum = parent.id.substr(3);
	var item = this.questions.find(idNum);

	this.dom.addNode(parent, 'hr', 'ansLine');
	var answerTop = this.dom.addNode(parent, 'div', 'ansTop');
	this.dom.addNode(answerTop, 'p', 'ansInstructor', item.instructor);
	this.dom.addNode(answerTop, 'p', 'ansDate', this.formatter.localDatetime(item.answerDateTime));
	this.dom.addNode(parent, 'p', 'ansText', item.answer);
};
/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
function SearchView(toc, concordance, versesAdapter, historyAdapter, version) {
	this.toc = toc;
	this.concordance = concordance;
	this.versesAdapter = versesAdapter;
	this.historyAdapter = historyAdapter;
	this.version = version;
	this.query = null;
	this.lookup = new Lookup(toc);
	this.words = [];
	this.bookList = {};
	this.viewRoot = null;
	this.rootNode = document.createElement('div');
	this.rootNode.id = 'searchRoot';
	document.body.appendChild(this.rootNode);
	this.stopIcon = new StopIcon('#FF0000');
	this.scrollPosition = 0;
	this.searchField = null;
	Object.seal(this);
}
SearchView.prototype.showView = function() {
	document.body.style.backgroundColor = '#FFF';
	if (this.searchField === null) {
		this.searchField = this.showSearchField();
	}
	this.rootNode.appendChild(this.searchField);
	 
	if (this.viewRoot) {
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, this.scrollPosition);
	} else {
		var that = this;
		this.historyAdapter.lastConcordanceSearch(function(lastSearch) {
			if (lastSearch instanceof IOError || lastSearch === null) {
				console.log('Nothing to search for, display blank page');
			} else {
				that.searchField.children[0].value = lastSearch;
				that.startSearch(lastSearch);
			}
		});
	}
};
SearchView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.scrollPosition = window.scrollY;
		for (var i=this.rootNode.children.length -1; i>=0; i--) {
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
	}
	this.stopIcon.hideIcon();
};
SearchView.prototype.startSearch = function(query) {
	this.query = query;
	console.log('Create new search page');
	if (! this.lookup.find(query)) {
		this.showSearch(query);
		for (var i=this.rootNode.children.length -1; i>=1; i--) { // remove viewRoot if present
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, 0);
	}
};
SearchView.prototype.showSearchField = function() {
	var searchField = document.createElement('div');
	searchField.setAttribute('class', 'searchBorder');
	var wid = window.innerWidth * 0.75;
	searchField.setAttribute('style', 'width:' + wid + 'px');
	searchField.setAttribute('style', 'padding:3px 5px');
	
	var inputField = document.createElement('input');
	inputField.setAttribute('type', 'text');
	inputField.setAttribute('class', 'searchField');
	inputField.setAttribute('style', 'width:' + (wid - 10) + 'px');
	
	searchField.appendChild(inputField);
	var that = this;
	inputField.addEventListener('keyup', function(event) {
		if (event.keyCode === 13) {
			that.startSearch(this.value);
		}
	});
	return(searchField);
};
SearchView.prototype.showSearch = function(query) {
	var that = this;
	this.viewRoot = document.createElement('div');
	if (this.version.silCode === 'cnm') {
		this.words = query.split('');
	} else {
		this.words = query.split(' ');
	}
	this.concordance.search2(this.words, function(refList) {
		if (refList instanceof IOError) {
			console.log('SEARCH RETURNED ERROR', JSON.stringify(refList));
			that.stopIcon.showIcon();
		} else if (refList.length === 0) {
			that.stopIcon.showIcon();
		} else {
			that.stopIcon.hideIcon();
			that.bookList = refListsByBook(refList);
			var selectList = selectListWithLimit(that.bookList);
			var selectMap = that.prepareSelect(selectList);
			that.versesAdapter.getVerses(Object.keys(selectMap), function(results) {
				if (results instanceof IOError) {
					that.stopIcon.showIcon();
				} else {
					var priorBook = null;
					var bookNode = null;
					for (var i=0; i<results.rows.length; i++) {
						var row = results.rows.item(i);
						var nodeId = row.reference;
						var verseText = row.html;
						var reference = new Reference(nodeId);
						var bookCode = reference.book;
						if (bookCode !== priorBook) {
							if (priorBook) {
								var priorList = that.bookList[priorBook];
								if (priorList && priorList.length > 3) {
									that.appendSeeMore(bookNode, priorBook);
								}
							}
							bookNode = that.appendBook(bookCode);
							priorBook = bookCode;
						}
						that.appendReference(bookNode, reference, verseText, selectMap[nodeId]);
					}
				}
			});
		}
	});
	function refListsByBook(refList) {
		var bookList = {};
		for (var i=0; i<refList.length; i++) {
			var bookCode = refList[i][0].substr(0, 3);
			if (bookList[bookCode] === undefined) {
				bookList[bookCode] = [ refList[i] ];
			} else {
				bookList[bookCode].push(refList[i]);
			}
		}
		Object.freeze(bookList);
		return(bookList);
	}
	function selectListWithLimit(bookList) {
		var selectList = [];
		var books = Object.keys(bookList);
		for (var i=0; i<books.length; i++) {
			var refList = bookList[books[i]];
			for (var j=0; j<refList.length && j<3; j++) {
				selectList.push(refList[j]);
			}
		}
		Object.freeze(selectList);
		return(selectList);
	}
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
SearchView.prototype.appendReference = function(bookNode, reference, verseText, refList) {
	var that = this;
	var entryNode = document.createElement('p');
	entryNode.setAttribute('id', 'con' + reference.nodeId);
	bookNode.appendChild(entryNode);
	var refNode = document.createElement('span');
	refNode.setAttribute('class', 'conRef');
	refNode.textContent = reference.chapterVerse();
	entryNode.appendChild(refNode);
	entryNode.appendChild(document.createElement('br'));

	var verseNode = document.createElement('span');
	verseNode.setAttribute('class', 'conVerse');
	verseNode.innerHTML = styleSearchWords(verseText, refList);
	entryNode.appendChild(verseNode);
	entryNode.addEventListener('click', function(event) {
		var nodeId = this.id.substr(3);
		console.log('open chapter', nodeId);
		document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId, source: that.query }}));
	});

	function styleSearchWords(verseText, refList) {
		var parts = refList[0].split(';');
		if (that.version.silCode === 'cnm') {
			var wordPosition = parseInt(parts[1] - 2);
			var verseWords = verseText.split('');
		} else {
			wordPosition = parseInt(parts[1]) * 2 - 3;
			verseWords = verseText.split(/\b/); // Non-destructive, preserves all characters
		}
		if (wordPosition < 0) wordPosition = 0;
		
		var searchWords = verseWords.map(function(wrd) {
			return(wrd.toLocaleLowerCase());
		});
		
		for (var i=0; i<that.words.length; i++) {
			var word = that.words[i];
			var wordNum = searchWords.indexOf(word.toLocaleLowerCase(), wordPosition);
			if (wordNum >= 0) {
				verseWords[wordNum] = '<span class="conWord">' + verseWords[wordNum] + '</span>';
				wordPosition = wordNum;
			}
		}
		return(verseWords.join(''));
	}
};
SearchView.prototype.appendSeeMore = function(bookNode, bookCode) {
	var that = this;
	var entryNode = document.createElement('p');
	entryNode.setAttribute('id', 'mor' + bookCode);
	entryNode.setAttribute('class', 'conMore');
	entryNode.textContent = String.fromCharCode(183) + String.fromCharCode(183) + String.fromCharCode(183);
	bookNode.appendChild(entryNode);
	entryNode.addEventListener('click', function(event) {
		var moreNode = document.getElementById(this.id);
		var parentNode = moreNode.parentNode;
		parentNode.removeChild(moreNode);

		var bookCode = this.id.substr(3);
		var bookNode = document.getElementById('con' + bookCode);
		var refList = that.bookList[bookCode];
		var selectMap = that.prepareSelect(refList);

		that.versesAdapter.getVerses(Object.keys(selectMap), function(results) {
			if (results instanceof IOError) {
				// display some error graphic?
			} else {
				for (var i=3; i<results.rows.length; i++) {
					var row = results.rows.item(i);
					var nodeId = row.reference;
					var verseText = row.html;
					var reference = new Reference(nodeId);
					that.appendReference(bookNode, reference, verseText, selectMap[nodeId]);
				}
			}
		});
	});
};
/**
* This is a private method which takes a list of search results and returns a
* list of verses to be selected.  This method is declare public only because it is
* used by two other methods.
*/
SearchView.prototype.prepareSelect = function(refList) {
	var searchMap = {};
	for (var i=0; i<refList.length; i++) {
		var first = refList[i][0];
		var parts = first.split(';');
		searchMap[parts[0]] = refList[i];
	}
	return(searchMap);
};
/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
var HEADER_BUTTON_HEIGHT = 44;
var HEADER_BAR_HEIGHT = 52;
var STATUS_BAR_HEIGHT = 14;

function HeaderView(tableContents, version) {
	this.statusBarInHeader = (deviceSettings.platform() === 'ios') ? true : false;
	//this.statusBarInHeader = false;

	this.hite = HEADER_BUTTON_HEIGHT;
	this.barHite = (this.statusBarInHeader) ? HEADER_BAR_HEIGHT + STATUS_BAR_HEIGHT : HEADER_BAR_HEIGHT;
	this.cellTopPadding = (this.statusBarInHeader) ? 'padding-top:' + STATUS_BAR_HEIGHT + 'px' : 'padding-top:0px';
	this.tableContents = tableContents;
	this.version = version;
	this.backgroundCanvas = null;
	this.titleCanvas = null;
	this.titleGraphics = null;
	this.titleStartX = null;
	this.titleWidth = null;
	this.currentReference = null;
	this.rootNode = document.createElement('table');
	this.rootNode.id = 'statusRoot';
	document.body.appendChild(this.rootNode);
	this.labelCell = document.createElement('td');
	this.labelCell.id = 'labelCell';
	document.body.addEventListener(BIBLE.CHG_HEADING, drawTitleHandler);
	Object.seal(this);
	var that = this;
	
	function drawTitleHandler(event) {
		document.body.removeEventListener(BIBLE.CHG_HEADING, drawTitleHandler);
		console.log('caught set title event', JSON.stringify(event.detail.reference.nodeId));
		that.currentReference = event.detail.reference;
		
		if (that.currentReference) {
			var book = that.tableContents.find(that.currentReference.book);
			var text = book.name + ' ' + ((that.currentReference.chapter > 0) ? that.currentReference.chapter : 1);
			that.titleGraphics.clearRect(0, 0, that.titleCanvas.width, that.hite);
			that.titleGraphics.fillText(text, that.titleCanvas.width / 2, that.hite / 2, that.titleCanvas.width);
			that.titleWidth = that.titleGraphics.measureText(text).width + 10;
			that.titleStartX = (that.titleCanvas.width - that.titleWidth) / 2;
			roundedRect(that.titleGraphics, that.titleStartX, 0, that.titleWidth, that.hite, 7);
		}
		document.body.addEventListener(BIBLE.CHG_HEADING, drawTitleHandler);
	}
	function roundedRect(ctx, x, y, width, height, radius) {
	  ctx.beginPath();
	  ctx.moveTo(x,y+radius);
	  ctx.lineTo(x,y+height-radius);
	  ctx.arcTo(x,y+height,x+radius,y+height,radius);
	  ctx.lineTo(x+width-radius,y+height);
	  ctx.arcTo(x+width,y+height,x+width,y+height-radius,radius);
	  ctx.lineTo(x+width,y+radius);
	  ctx.arcTo(x+width,y,x+width-radius,y,radius);
	  ctx.lineTo(x+radius,y);
	  ctx.arcTo(x,y,x,y+radius,radius);
	  ctx.stroke();
	}
}
HeaderView.prototype.showView = function() {
	var that = this;
	this.backgroundCanvas = document.createElement('canvas');
	paintBackground(this.backgroundCanvas, this.hite);
	this.rootNode.appendChild(this.backgroundCanvas);

	var menuWidth = setupIconButton('tocCell', drawTOCIcon, this.hite, BIBLE.SHOW_TOC);
	var serhWidth = setupIconButton('searchCell', drawSearchIcon, this.hite, BIBLE.SHOW_SEARCH);
	this.rootNode.appendChild(this.labelCell);
	if (that.version.isQaActive == 'T') {
		var quesWidth = setupIconButton('questionsCell', drawQuestionsIcon, this.hite, BIBLE.SHOW_QUESTIONS);
	} else {
		quesWidth = 0;
	}
	var settWidth = setupIconButton('settingsCell', drawSettingsIcon, this.hite, BIBLE.SHOW_SETTINGS);
	var avalWidth = window.innerWidth - (menuWidth + serhWidth + quesWidth + settWidth + (6 * 4));// six is fudge factor

	this.titleCanvas = document.createElement('canvas');
	drawTitleField(this.titleCanvas, this.hite, avalWidth);
	this.labelCell.appendChild(this.titleCanvas);

	function paintBackground(canvas, hite) {
		console.log('**** repaint background ****');
    	canvas.setAttribute('height', that.barHite);
    	canvas.setAttribute('width', window.innerWidth);// outerWidth is zero on iOS
    	canvas.setAttribute('style', 'position: absolute; top:0; left:0; z-index: -1');
      	var graphics = canvas.getContext('2d');
      	graphics.rect(0, 0, canvas.width, canvas.height);

      	// create radial gradient
      	var vMidpoint = hite / 2;
      	var gradient = graphics.createRadialGradient(238, vMidpoint, 10, 238, vMidpoint, window.innerHeight - hite);
      	// light blue
      	gradient.addColorStop(0, '#2E9EC9');//'#8ED6FF');
      	// dark blue
      	gradient.addColorStop(1, '#2E9EC9');//'#004CB3');

      	graphics.fillStyle = '#2E9EC9';//gradient; THE GRADIENT IS NOT BEING USED.
      	graphics.fill();
	}
	function drawTitleField(canvas, hite, avalWidth) {
		canvas.setAttribute('id', 'titleCanvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', avalWidth);
		canvas.setAttribute('style', that.cellTopPadding);
		that.titleGraphics = canvas.getContext('2d');
		
		that.titleGraphics.fillStyle = '#1b2f76';
		that.titleGraphics.font = '2.0rem sans-serif';
		that.titleGraphics.textAlign = 'center';
		that.titleGraphics.textBaseline = 'middle';
		that.titleGraphics.strokeStyle = '#1b2f76';
		that.titleGraphics.lineWidth = 0.5;

		that.titleCanvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			if (that.currentReference && event.offsetX > that.titleStartX && event.offsetX < (that.titleStartX + that.titleWidth)) {
				document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: that.currentReference.nodeId }}));
			}
		});
	}
	function setupIconButton(parentCell, canvasFunction, hite, eventType) {
		var canvas = canvasFunction(hite, '#F7F7BB');
		canvas.setAttribute('style', that.cellTopPadding);
		var parent = document.createElement('td');
		parent.id = parentCell;
		that.rootNode.appendChild(parent);
		parent.appendChild(canvas);
		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('clicked', parentCell);
			document.body.dispatchEvent(new CustomEvent(eventType));
		});
		return(canvas.width);
	}
};

/**
* This class presents the table of contents, and responds to user actions.
*/
function TableContentsView(toc, copyrightView) {
	this.toc = toc;
	this.copyrightView = copyrightView;
	this.root = null;
	this.dom = new DOMBuilder();
	this.rootNode = this.dom.addNode(document.body, 'div', null, null, 'tocRoot');
	this.scrollPosition = 0;
	this.numberNode = document.createElement('span');
	this.numberNode.textContent = '0123456789';
	this.numberNode.setAttribute('style', "position: absolute; float: left; white-space: nowrap; visibility: hidden; font-family: sans-serif; font-size: 1.0rem");
	document.body.appendChild(this.numberNode);
	Object.seal(this);
}
TableContentsView.prototype.showView = function() {
	document.body.style.backgroundColor = '#FFF';
	if (! this.root) {
		this.root = this.buildTocBookList();
	}
	if (this.rootNode.children.length < 1) {
		this.rootNode.appendChild(this.root);
		window.scrollTo(0, this.scrollPosition);
	}
};
TableContentsView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.scrollPosition = window.scrollY; // save scroll position till next use.
		for (var i=this.rootNode.children.length -1; i>=0; i--) {
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
	}
};
TableContentsView.prototype.buildTocBookList = function() {
	var that = this;
	var div = document.createElement('div');
	div.setAttribute('id', 'toc');
	div.setAttribute('class', 'tocPage');
	div.appendChild(this.copyrightView.createTOCTitleDOM());
	for (var i=0; i<this.toc.bookList.length; i++) {
		var book = this.toc.bookList[i];
		var bookNode = that.dom.addNode(div, 'p', 'tocBook', book.name, 'toc' + book.code);
		
		var that = this;
		bookNode.addEventListener('click', function(event) {
			var bookCode = this.id.substring(3);
			that.showTocChapterList(bookCode);
		});
	}
	div.appendChild(this.copyrightView.createCopyrightNoticeDOM());
	return(div);
};
TableContentsView.prototype.showTocChapterList = function(bookCode) {
	var that = this;
	var book = this.toc.find(bookCode);
	if (book) {
		var root = document.createDocumentFragment();
		var table = that.dom.addNode(root, 'table', 'tocChap');
		var numCellPerRow = cellsPerRow();
		var numRows = Math.ceil(book.lastChapter / numCellPerRow);
		var chaptNum = 1;
		for (var r=0; r<numRows; r++) {
			var row = document.createElement('tr');
			table.appendChild(row);
			for (var c=0; c<numCellPerRow && chaptNum <= book.lastChapter; c++) {
				var cell = that.dom.addNode(row, 'td', 'tocChap', chaptNum, 'toc' + bookCode + ':' + chaptNum);
				chaptNum++;
				cell.addEventListener('click', function(event) {
					var nodeId = this.id.substring(3);
					console.log('open chapter', nodeId);
					document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId }}));
				});
			}
		}
		var bookNode = document.getElementById('toc' + book.code);
		if (bookNode) {
			var saveYPosition = bookNode.getBoundingClientRect().top;
			removeAllChapters();
			bookNode.appendChild(root);
			scrollTOC(bookNode, saveYPosition);
		}
	}
	
	function cellsPerRow() {
		var width = that.numberNode.getBoundingClientRect().width;
		var cellWidth = Math.max(50, width * 0.3); // width of 3 chars or at least 50px
		var numCells = window.innerWidth * 0.8 / cellWidth;
		return(Math.floor(numCells));		
	}
	function removeAllChapters() {
		var div = document.getElementById('toc');
		if (div) {
			for (var i=div.children.length -1; i>=0; i--) {
				var bookNode = div.children[i];
				if (bookNode.className === 'tocBook') {
					for (var j=bookNode.children.length -1; j>=0; j--) {
						var chaptTable = bookNode.children[j];
						bookNode.removeChild(chaptTable);
					}
				}
			}
		}
	}
	function scrollTOC(bookNode, saveYPosition) {
		window.scrollBy(0, bookNode.getBoundingClientRect().top - saveYPosition); // Keeps bookNode in same position when node above is collapsed.
		
		var bookRect = bookNode.getBoundingClientRect();
		if (window.innerHeight < bookRect.top + bookRect.height) {
			// Scrolls booknode up when chapters are not in view.
			// limits scroll to bookRect.top -80 so that book name remains in view.
			window.scrollBy(0, Math.min(bookRect.top - 80, bookRect.top + bookRect.height - window.innerHeight));	
		}
	}
};

/**
* This class is the UI for the controls in the settings page.
* It also uses the VersionsView to display versions on the settings page.
*/
function SettingsView(settingStorage, versesAdapter) {
	this.root = null;
	this.settingStorage = settingStorage;
	this.versesAdapter = versesAdapter;
	this.rootNode = document.createElement('div');
	this.rootNode.id = 'settingRoot';
	document.body.appendChild(this.rootNode);
	this.dom = new DOMBuilder();
	this.versionsView = new VersionsView(this.settingStorage);
	Object.seal(this);
}
SettingsView.prototype.showView = function() {
	document.body.style.backgroundColor = '#FFF';
	if (! this.root) {
		this.root = this.buildSettingsView();
	}
	if (this.rootNode.children.length < 1) {
		this.rootNode.appendChild(this.root);
	}
	this.startControls();
	this.versionsView.showView();
};
SettingsView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		// should I save scroll position here
		for (var i=this.rootNode.children.length -1; i>=0; i--) {
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
	}	
};
SettingsView.prototype.buildSettingsView = function() {
	var that = this;
	var table = document.createElement('table');
	table.id = 'settingsTable';
	
	addRowSpace(table);
	var sizeRow = this.dom.addNode(table, 'tr');
	var sizeCell = this.dom.addNode(sizeRow, 'td', null, null, 'fontSizeControl');
	var sizeSlider = this.dom.addNode(sizeCell, 'div', null, null, 'fontSizeSlider');
	var sizeThumb = this.dom.addNode(sizeCell, 'div', null, null, 'fontSizeThumb');
	
	var textRow = this.dom.addNode(table, 'tr');
	var textCell = this.dom.addNode(textRow, 'td', null, null, 'sampleText');
	
	/**
	* This is not used because it had a negative impact on codex performance, but keep as an
	* example toggle switch.*/
	/* This is kept in as a hack, because the thumb on fontSizeControl does not start in the correct
	* position, unless this code is here. */
	addRowSpace(table);
	var colorRow = this.dom.addNode(table, 'tr');
	var blackCell = this.dom.addNode(colorRow, 'td', 'tableLeftCol', null, 'blackBackground');
	var colorCtrlCell = this.dom.addNode(colorRow, 'td', 'tableCtrlCol');
	var colorSlider = this.dom.addNode(colorCtrlCell, 'div', null, null, 'fontColorSlider');
	var colorThumb = this.dom.addNode(colorSlider, 'div', null, null, 'fontColorThumb');
	var whiteCell = this.dom.addNode(colorRow, 'td', 'tableRightCol', null, 'whiteBackground');
	
	addRowSpace(table);
	addJohn316(textCell);
	return(table);
	
	function addRowSpace(table) {
		var row = table.insertRow();
		var cell = row.insertCell();
		cell.setAttribute('class', 'rowSpace');
	}
	function addJohn316(verseNode) {
		that.versesAdapter.getVerses(['JHN:3:16'], function(results) {
			if (results instanceof IOError) {
				console.log('Error while getting JHN:3:16');
			} else {
				if (results.rows.length > 0) {
					var row = results.rows.item(0);
					verseNode.textContent = row.html;
				}	
			}
		});

	}
};
SettingsView.prototype.startControls = function() {
	var that = this;
	var docFontSize = document.documentElement.style.fontSize;
	findMaxFontSize(function(maxFontSize) {
		startFontSizeControl(docFontSize, 10, maxFontSize);
	});
	
	function startFontSizeControl(fontSizePt, ptMin, ptMax) {
		var fontSize = parseFloat(fontSizePt);
	    var sampleNode = document.getElementById('sampleText');
    	var draggable = Draggable.create('#fontSizeThumb', {bounds:'#fontSizeSlider', minimumMovement:0,
	    	lockAxis:true, 
	    	onDrag:function() { resizeText(this.x); },
	    	onDragEnd:function() { finishResize(this.x); }
	    });
    	var drag0 = draggable[0];
    	var ratio = (ptMax - ptMin) / (drag0.maxX - drag0.minX);
    	var startX = (fontSize - ptMin) / ratio + drag0.minX;
    	TweenMax.set('#fontSizeThumb', {x:startX});
    	resizeText(startX);

		function resizeText(x) {
	    	var size = (x - drag0.minX) * ratio + ptMin;
			sampleNode.style.fontSize = size + 'pt';
    	}
    	function finishResize(x) {
	    	var size = (x - drag0.minX) * ratio + ptMin;
	    	document.documentElement.style.fontSize = size + 'pt';
			that.settingStorage.setFontSize(size);
    	}
    }
    function findMaxFontSize(callback) {
	    that.settingStorage.getMaxFontSize(function(maxFontSize) {
		    if (maxFontSize == null) {
				var node = document.createElement('span');
				node.textContent = 'Thessalonians';
				node.setAttribute('style', "position: absolute; float: left; white-space: nowrap; visibility: hidden; font-family: sans-serif;");
				document.body.appendChild(node);
				var fontSize = 18 * 1.66; // Title is style mt1, which is 1.66rem
				do {
					fontSize++;
					node.style.fontSize = fontSize + 'pt';
					var width = node.getBoundingClientRect().right;
				} while(width < window.innerWidth);
				document.body.removeChild(node);
				maxFontSize = (fontSize - 1.0) / 1.66;
				console.log('computed maxFontSize', maxFontSize);
				that.settingStorage.setMaxFontSize(maxFontSize);
			}
			callback(maxFontSize);
		});
    }
    /* This is not used, changing colors had a negative impact on codexView performance. Keep as a toggle switch example.
	function startFontColorControl(state) {
	    var onOffState = state;
	    var sliderNode = document.getElementById('fontColorSlider');
	    var sampleNode = document.getElementById('sampleText');
    	var draggable = Draggable.create('#fontColorThumb', {type:'x', bounds:sliderNode, throwProps:true, snap:function(v) {
	    		var snap = (v - this.minX < (this.maxX - this.minX) / 2) ? this.minX : this.maxX;
	    		var newState = (snap > this.minX);
	    		if (newState != onOffState) {
		    		onOffState = newState;
		    		setColors(onOffState);
	    		}
	    		return(snap);
    		}
    	});
    	var startX = (onOffState) ? draggable[0].maxX : draggable[0].minX;
    	TweenMax.set('#fontColorThumb', {x:startX});
    	setColors(onOffState);
    	
    	function setColors(onOffState) {
	    	var color = (onOffState) ? '#00FF00' : '#FFFFFF';
			TweenMax.to(sliderNode, 0.4, {backgroundColor: color});
			sampleNode.style.backgroundColor = (onOffState) ? '#000000' : '#FFFFFF';
			sampleNode.style.color = (onOffState) ? '#FFFFFF' : '#000000';
    	}
    }*/
};



/**
* This class presents the list of available versions to download
*/
var FLAG_PATH = 'licensed/icondrawer/flags/64/';

function VersionsView(settingStorage) {
	this.settingStorage = settingStorage;
	this.database = new VersionsAdapter();
	var that = this;
	that.translation = null;
	deviceSettings.prefLanguage(function(locale) {
		that.database.buildTranslateMap(locale, function(results) {
			that.translation = results;
		});		
	});
	this.root = null;
	this.rootNode = document.getElementById('settingRoot');
	this.defaultCountryNode = null;
	this.dom = new DOMBuilder();
	this.scrollPosition = 0;
	Object.seal(this);
}
VersionsView.prototype.showView = function() {
	if (! this.root) {
		this.buildCountriesList();
	} 
	else if (this.rootNode.children.length < 4) {
		this.rootNode.appendChild(this.root);
		window.scrollTo(10, this.scrollPosition);// move to settings view?
	}
};
VersionsView.prototype.buildCountriesList = function() {
	var that = this;
	var root = document.createElement('div');
	this.database.selectCountries(function(results) {
		if (! (results instanceof IOError)) {
			for (var i=0; i<results.length; i++) {
				var row = results[i];
				var groupNode = that.dom.addNode(root, 'div');

				var countryNode = that.dom.addNode(groupNode, 'table', 'ctry', null, 'cty' + row.countryCode);
				countryNode.addEventListener('click', countryClickHandler);
				if (row.countryCode === 'WORLD') {
					that.defaultCountryNode = countryNode;
				}
				
				var rowNode = that.dom.addNode(countryNode, 'tr');
				var flagCell = that.dom.addNode(rowNode, 'td', 'ctryFlag');
				
				var flagNode = that.dom.addNode(flagCell, 'img');
				flagNode.setAttribute('src', FLAG_PATH + row.countryCode.toLowerCase() + '.png');
				
				that.dom.addNode(rowNode, 'td', 'localCtryName', row.localCountryName);
				var prefLangName = that.translation[row.countryCode];
				if (prefLangName !== row.localCountryName) {
					flagCell.setAttribute('rowspan', 2);
					var row2Node = that.dom.addNode(countryNode, 'tr');
					that.dom.addNode(row2Node, 'td', 'ctryName', prefLangName);
				}
			}
		}
		that.rootNode.appendChild(root);
		that.buildVersionList(that.defaultCountryNode);
		that.root = root;
	});
	
	function countryClickHandler(event) {
		if (this.parentElement.children.length === 1) {
			that.buildVersionList(this);		
		} else {
			var parent = this.parentElement;
			for (var i=parent.children.length -1; i>0; i--) {
				parent.removeChild(parent.children[i]);
			}
		}
	}
};
VersionsView.prototype.buildVersionList = function(countryNode) {
	var that = this;
	var parent = countryNode.parentElement;
	var countryCode = countryNode.id.substr(3);
	this.settingStorage.getVersions();
	this.settingStorage.getCurrentVersion(function(currentVersion) {
		that.database.selectVersions(countryCode, function(results) {
			if (! (results instanceof IOError)) {
				for (var i=0; i<results.length; i++) {
					var row = results[i];
					var versionNode = that.dom.addNode(parent, 'table', 'vers');
					var rowNode = that.dom.addNode(versionNode, 'tr');
					var leftNode = that.dom.addNode(rowNode, 'td', 'versLeft');
					
					var prefLangName = that.translation[row.langCode];
					var languageName = (prefLangName === row.localLanguageName) ? prefLangName : row.localLanguageName + ' (' + prefLangName + ')';
					that.dom.addNode(leftNode, 'p', 'langName', languageName);
					var versionName = (row.localVersionName) ? row.localVersionName : row.scope;
					if (row.versionAbbr && row.versionAbbr.length > 0) {
						versionName += ' (' + row.versionAbbr + ')';
					}
					that.dom.addNode(leftNode, 'span', 'versName', versionName + ',  ');
					
					var ownerNode = that.dom.addNode(leftNode, 'span', 'versName', row.localOwnerName);
					
					var rightNode = that.dom.addNode(rowNode, 'td', 'versRight');
					var btnNode = that.dom.addNode(rightNode, 'button', 'versIcon');
					
					var iconNode = that.dom.addNode(btnNode, 'img');
					iconNode.setAttribute('id', 'ver' + row.versionCode);
					iconNode.setAttribute('data-id', 'fil' + row.filename);
					if (row.filename === currentVersion) {
						iconNode.setAttribute('src', 'licensed/sebastiano/check.png');
					} else if (that.settingStorage.hasVersion(row.versionCode)) {
						iconNode.setAttribute('src', 'licensed/sebastiano/contacts.png');
						iconNode.addEventListener('click',  selectVersionHandler);
					} else {
						iconNode.setAttribute('src', 'licensed/sebastiano/cloud-download.png');
						iconNode.addEventListener('click', downloadVersionHandler);
					}
				}
			}
		});
	});
	
	function selectVersionHandler(event) {
		var filename = this.getAttribute('data-id').substr(3);
		document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_VERSION, { detail: { version: filename }}));
	}
	function downloadVersionHandler(event) {
		this.removeEventListener('click', downloadVersionHandler);
		var gsPreloader = new GSPreloader(gsPreloaderOptions);
		gsPreloader.active(true);
		var iconNode = this;
		var versionCode = iconNode.id.substr(3);
		var versionFile = iconNode.getAttribute('data-id').substr(3);
		that.settingStorage.getCurrentVersion(function(currVersion) {
			var downloader = new FileDownloader(SERVER_HOST, SERVER_PORT, currVersion);
			downloader.download(versionFile, function(error) {
				gsPreloader.active(false);
				if (error) {
					console.log(JSON.stringify(error));
				} else {
					that.settingStorage.setVersion(versionCode, versionFile);
					iconNode.setAttribute('src', 'licensed/sebastiano/contacts.png');
					document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_VERSION, { detail: { version: versionFile }}));
				}
			});
		});
	}
};

/**
* This function draws the 'X' that is used as a close
* button on any popup window.
*/
function drawCloseIcon(hite, color) {
	var lineThick = hite / 7.0;
	var spacer = lineThick / 2;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite);
	var graphics = canvas.getContext('2d');

	graphics.beginPath();
	graphics.moveTo(spacer, spacer);
	graphics.lineTo(hite - spacer, hite - spacer);
	graphics.moveTo(hite - spacer, spacer);
	graphics.lineTo(spacer, hite - spacer);
	graphics.closePath();

	graphics.lineWidth = hite / 5.0;
	graphics.strokeStyle = color;
	graphics.stroke();
	return(canvas);
}/**
* This function draws and icon that is used as a questions button
* on the StatusBar.
*/
function drawQuestionsIcon(hite, color) {
	var widthDiff = 1.25;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite * 1.2);
	var graphics = canvas.getContext('2d');

	drawOval(graphics, hite * 0.72);
	drawArc(graphics, hite * 0.72);
	return(canvas);

	function drawOval(graphics, hite) {
    	var centerX = 0;
    	var centerY = 0;
    	var radius = hite * 0.5;

		graphics.beginPath();
    	graphics.save();
    	graphics.translate(canvas.width * 0.5, canvas.height * 0.5);
    	graphics.scale(widthDiff, 1);
    	graphics.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
    	graphics.restore();
    	graphics.fillStyle = color;
   		graphics.fill();
    }
    
    function drawArc(graphics, hite) {
    	graphics.beginPath();
    	graphics.moveTo(hite * 0.3, hite * 1.25);
    	graphics.bezierCurveTo(hite * 0.6, hite * 1.2, hite * 0.65, hite * 1.1, hite * 0.7, hite * 0.9);
    	graphics.lineTo(hite * 0.5, hite * 0.9);
    	graphics.bezierCurveTo(hite * 0.5, hite * 1, hite * 0.5, hite * 1.1, hite * 0.3, hite * 1.25);
    	graphics.fillStyle = color;
   		graphics.fill();
    }
}

 /**
* This function draws the spyglass that is used as the search
* button on the status bar.
*/
function drawSearchIcon(hite, color) {
	var lineThick = hite / 7.0;
	var radius = (hite / 2) - (lineThick * 1.5);
	var coordX = radius + (lineThick * 1.5);
	var coordY = radius + lineThick * 1.25;
	var edgeX = coordX + radius / 2 + 2;
	var edgeY = coordY + radius / 2 + 2;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite + lineThick);
	var graphics = canvas.getContext('2d');

	graphics.beginPath();
	graphics.arc(coordX, coordY, radius, 0, Math.PI*2, true);
	graphics.moveTo(edgeX, edgeY);
	graphics.lineTo(edgeX + radius, edgeY + radius);
	graphics.closePath();

	graphics.lineWidth = lineThick;
	graphics.strokeStyle = color;
	graphics.stroke();
	return(canvas);
}/**
* This function draws and icon that is used as a send button
* on the QuestionsView input block.
*/
function drawSendIcon(hite, color) {
	var widthDiff = 1.25;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite * widthDiff);
	var graphics = canvas.getContext('2d');

	var lineWidth = hite / 7.0;
	drawArrow(graphics, lineWidth);
	return(canvas);

	function drawArrow(graphics, lineWidth) {
		var middle = canvas.height * 0.5;
		var widt = canvas.width;
		var doubleLineWidth = lineWidth * 2.0;
		var tripleLineWidth = lineWidth * 3.5;
		var controlX = widt - lineWidth * 2.5;

		graphics.beginPath();
		graphics.moveTo(lineWidth, middle);
		graphics.lineTo(widt - 2 * lineWidth, middle);
		graphics.strokeStyle = color;
		graphics.lineWidth = lineWidth;
		graphics.stroke();

		graphics.beginPath();
		graphics.moveTo(widt - lineWidth, middle);
		graphics.lineTo(widt - tripleLineWidth, middle - doubleLineWidth);

		graphics.moveTo(widt - lineWidth, middle);
		graphics.lineTo(widt - tripleLineWidth, middle + doubleLineWidth);

		graphics.bezierCurveTo(controlX, middle, controlX, middle, widt - tripleLineWidth, middle - doubleLineWidth);

		graphics.fillStyle = color;
		graphics.fill();
	}
}/**
* This function draws the gear that is used as the settings
* button on the status bar.
* This is not yet being used.
*/
function drawSettingsIcon(hite, color) {
	var lineThick = hite / 7.0;
	var radius = (hite / 2) - (lineThick * 1.75);
	var coord = hite / 2;
	var circle = Math.PI * 2;
	var increment = Math.PI / 4;
	var first = increment / 2;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite);
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
	return(canvas);
}/**
* This function draws an icon that is used as a TOC button
* on the StatusBar.
*/
function drawTOCIcon(hite, color) {
	var lineThick = hite / 7.0;
	var line1Y = lineThick * 1.5;
	var lineXSrt = line1Y;
	var lineXEnd = hite - lineThick;
	var line2Y = lineThick * 2 + line1Y;
	var line3Y = lineThick * 2 + line2Y;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite + lineXSrt * 0.5);
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

	return(canvas);
}//Pure JS, completely customizable preloader from GreenSock.
//Once you create an instance like var preloader = new GSPreloader(), call preloader.active(true) to open it, preloader.active(false) to close it, and preloader.active() to get the current status. Only requires TweenLite and CSSPlugin (http://www.greensock.com/gsap/)
// Modified so that it must be instantiated preloader = new GSPreloader(gsPreloaderOptions);
var gsPreloaderOptions = {
  radius:42, 
  dotSize:15, 
  dotCount:10, 
  colors:["#61AC27","#555","purple","#FF6600"], //have as many or as few colors as you want.
  boxOpacity:0.2,
  boxBorder:"1px solid #AAA",
  animationOffset: 1.8, //jump 1.8 seconds into the animation for a more active part of the spinning initially (just looks a bit better in my opinion)
};

//this is the whole preloader class/function
function GSPreloader(options) {
  options = options || {};
  var parent = options.parent || document.body,
      element = this.element = document.createElement("div"),
      radius = options.radius || 42,
      dotSize = options.dotSize || 15,
      animationOffset = options.animationOffset || 1.8, //jumps to a more active part of the animation initially (just looks cooler especially when the preloader isn't displayed for very long)
      createDot = function(rotation) {
          var dot = document.createElement("div");
        element.appendChild(dot);
        TweenLite.set(dot, {width:dotSize, height:dotSize, transformOrigin:(-radius + "px 0px"), x: radius, backgroundColor:colors[colors.length-1], borderRadius:"50%", force3D:true, position:"absolute", rotation:rotation});
        dot.className = options.dotClass || "preloader-dot";
        return dot; 
      }, 
      i = options.dotCount || 10,
      rotationIncrement = 360 / i,
      colors = options.colors || ["#61AC27","black"],
      animation = new TimelineLite({paused:true}),
      dots = [],
      isActive = false,
      box = document.createElement("div"),
      tl, dot, closingAnimation, j;
  colors.push(colors.shift());
  
  //setup background box
  TweenLite.set(box, {width: radius * 2 + 70, height: radius * 2 + 70, borderRadius:"14px", backgroundColor:options.boxColor || "white", border: options.boxBorder || "1px solid #AAA", position:"absolute", xPercent:-50, yPercent:-50, opacity:((options.boxOpacity != null) ? options.boxOpacity : 0.3)});
  box.className = options.boxClass || "preloader-box";
  element.appendChild(box);
  
  parent.appendChild(element);
  TweenLite.set(element, {position:"fixed", top:"45%", left:"50%", perspective:600, overflow:"visible", zIndex:2000});
  animation.from(box, 0.1, {opacity:0, scale:0.1, ease:Power1.easeOut}, animationOffset);
  while (--i > -1) {
    dot = createDot(i * rotationIncrement);
    dots.unshift(dot);
    animation.from(dot, 0.1, {scale:0.01, opacity:0, ease:Power1.easeOut}, animationOffset);
    //tuck the repeating parts of the animation into a nested TimelineMax (the intro shouldn't be repeated)
    tl = new TimelineMax({repeat:-1, repeatDelay:0.25});
    for (j = 0; j < colors.length; j++) {
      tl.to(dot, 2.5, {rotation:"-=360", ease:Power2.easeInOut}, j * 2.9)
        .to(dot, 1.2, {skewX:"+=360", backgroundColor:colors[j], ease:Power2.easeInOut}, 1.6 + 2.9 * j);
    }
    //stagger its placement into the master timeline
    animation.add(tl, i * 0.07);
  }
  if (TweenLite.render) {
    TweenLite.render(); //trigger the from() tweens' lazy-rendering (otherwise it'd take one tick to render everything in the beginning state, thus things may flash on the screen for a moment initially). There are other ways around this, but TweenLite.render() is probably the simplest in this case.
  }
  
  //call preloader.active(true) to open the preloader, preloader.active(false) to close it, or preloader.active() to get the current state.
  this.active = function(show) {
    if (!arguments.length) {
      return isActive;
    }
    if (isActive != show) {
      isActive = show;
      if (closingAnimation) {
        closingAnimation.kill(); //in case the preloader is made active/inactive/active/inactive really fast and there's still a closing animation running, kill it.
      }
      if (isActive) {
        element.style.visibility = "visible";
        TweenLite.set([element, box], {rotation:0});
        animation.play(animationOffset);
      } else {
        closingAnimation = new TimelineLite();
        if (animation.time() < animationOffset + 0.3) {
          animation.pause();
          closingAnimation.to(element, 1, {rotation:-360, ease:Power1.easeInOut}).to(box, 1, {rotation:360, ease:Power1.easeInOut}, 0);
        }
        closingAnimation.staggerTo(dots, 0.3, {scale:0.01, opacity:0, ease:Power1.easeIn, overwrite:false}, 0.05, 0).to(box, 0.4, {opacity:0, scale:0.2, ease:Power2.easeIn, overwrite:false}, 0).call(function() { animation.pause(); closingAnimation = null; }).set(element, {visibility:"hidden"});
      }
    }
    return this;
  };
}
/**
* This class draws the stop icon that is displayed
* when there are no search results.
*/
function StopIcon(color) {
	this.hite = window.innerHeight / 7;
	
	this.centerIcon = (window.innerHeight - this.hite) / 2;
	this.color = color;
	this.iconDiv = document.createElement('div');
	this.iconDiv.setAttribute('style', 'text-align: center;');
	this.iconCanvas = null;
	Object.seal(this);
}
StopIcon.prototype.showIcon = function() {
	if (this.iconCanvas === null) {
		this.iconCanvas = this.drawIcon()
	}
	document.body.appendChild(this.iconDiv);
	this.iconDiv.appendChild(this.iconCanvas);

	TweenMax.set(this.iconCanvas, { y: - this.hite });
	TweenMax.to(this.iconCanvas, 0.5, { y: this.centerIcon });
};
StopIcon.prototype.hideIcon = function() {
	if (this.iconDiv && this.iconCanvas && this.iconDiv.hasChildNodes()) {
		this.iconDiv.removeChild(this.iconCanvas);
	}
	if (this.iconDiv && this.iconDiv.parentNode === document.body) {
		document.body.removeChild(this.iconDiv);
	}
};
StopIcon.prototype.drawIcon = function() {
	var lineThick = this.hite / 7.0;
	var radius = (this.hite / 2) - lineThick;
	var coordX = radius + lineThick;
	var coordY = radius + lineThick;
	var edgeX = coordX - radius / 1.5;
	var edgeY = coordY - radius / 1.5;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', this.hite);
	canvas.setAttribute('width', this.hite);
	var graphics = canvas.getContext('2d');

	graphics.beginPath();
	graphics.arc(coordX, coordY, radius, 0, Math.PI*2, true);
	graphics.moveTo(edgeX, edgeY);
	graphics.lineTo(edgeX + radius * 1.5, edgeY + radius * 1.5);
	graphics.closePath();

	graphics.lineWidth = lineThick;
	graphics.strokeStyle = this.color;
	graphics.stroke();
	return(canvas);
};

// stop = new StopIcon(200, '#FF0000');
//stop.showIcon();
/**
* This class is a wrapper for SQL Error so that we can always distinguish an error
* from valid results.  Any method that calls an IO routine, which can expect valid results
* or an error should test "if (results instanceof IOError)".
*/
function IOError(err) {
	if (err.code && err.message) {
		this.code = err.code;
		this.message = err.message;
	} else {
		this.code = 0;
		this.message = JSON.stringify(err);
	}
}
/**
* This class replaces window.localStorage, because I had reliability problems with LocalStorage
* on ios Simulator.  I am guessing the problems were caused by the WKWebView plugin, but I don't really know.
*/
function SettingStorage() {
    this.className = 'SettingStorage';
    this.database = new DatabaseHelper('Settings.db', false);
    this.loadedVersions = null;
	Object.seal(this);
}
SettingStorage.prototype.create = function(callback) {
	var that = this;
	this.database.executeDDL('CREATE TABLE IF NOT EXISTS Settings(name TEXT PRIMARY KEY NOT NULL, value TEXT NULL)', function(err) {
		if (err instanceof IOError) {
			console.log('Error creating Settings', err);
		} else {
			that.database.executeDDL('CREATE TABLE IF NOT EXISTS Installed(version TEXT PRIMARY KEY NOT NULL, filename TEXT NOT NULL, timestamp TEXT NOT NULL)', function(err) {
				if (err instanceof IOError) {
					console.log('Error creating Installed', err);
				} else {
					callback();
				}
			});
		}
	});
};
/**
* Settings
*/
SettingStorage.prototype.getFontSize = function(callback) {
	this.getItem('fontSize', function(fontSize) {
		if (fontSize < 10 || fontSize > 36) fontSize = null; // Null will force calc of fontSize.
		callback(fontSize);
	});
};
SettingStorage.prototype.setFontSize = function(fontSize) {
	this.setItem('fontSize', fontSize);
};
SettingStorage.prototype.getMaxFontSize = function(callback) {
	this.getItem('maxFontSize', function(maxFontSize) {
		callback(maxFontSize);
	});
};
SettingStorage.prototype.setMaxFontSize = function(maxFontSize) {
	this.setItem('maxFontSize', maxFontSize);	
};
SettingStorage.prototype.getCurrentVersion = function(callback) {
	this.getItem('version', function(filename) {
		callback(filename);
	});
};
SettingStorage.prototype.setCurrentVersion = function(filename) {
	this.setItem('version', filename);
};
SettingStorage.prototype.getAppVersion = function(callback) {
	this.getItem('appVersion', function(version) {
		callback(version);
	});
};
SettingStorage.prototype.setAppVersion = function(appVersion) {
	this.setItem('appVersion', appVersion);
};
SettingStorage.prototype.getItem = function(name, callback) {
	this.database.select('SELECT value FROM Settings WHERE name=?', [name], function(results) {
		if (results instanceof IOError) {
			console.log('GetItem', name, JSON.stringify(results));
			callback();
		} else {
			var value = (results.rows.length > 0) ? results.rows.item(0).value : null;
        	console.log('GetItem', name, value);
			callback(value);
		}
	});
};
SettingStorage.prototype.setItem = function(name, value) {
    this.database.executeDML('REPLACE INTO Settings(name, value) VALUES (?,?)', [name, value], function(results) {
	   if (results instanceof IOError) {
		   console.log('SetItem', name, value, JSON.stringify(results));
	   } else {
		   console.log('SetItem', name, value);
	   }
    });
};
/**
* Versions
*/
/** Before calling hasVersion one must call getVersions, which creates a map of available versions
* And getVersions must be called a few ms before any call to hasVersion to make sure result is available.
*/
SettingStorage.prototype.hasVersion = function(version) {
	return(this.loadedVersions[version]);
};
SettingStorage.prototype.getVersions = function() {
	var that = this;
	console.log('GetVersions');
	this.database.select('SELECT version, filename FROM Installed', [], function(results) {
		if (results instanceof IOError) {
			console.log('GetVersions error', JSON.stringify(results));
		} else {
			console.log('GetVersions, rowCount=', results.rows.length);
        	that.loadedVersions = {};
        	for (var i=0; i<results.rows.length; i++) {
	        	var row = results.rows.item(i);
	        	that.loadedVersions[row.version] = row.filename;
        	}
		}
	});
};
SettingStorage.prototype.setVersion = function(version, filename) {
	console.log('SetVersion', version, filename);
	var now = new Date();
	this.database.executeDML('REPLACE INTO Installed(version, filename, timestamp) VALUES (?,?,?)', [version, filename, now.toISOString()], function(results) {
		if (results instanceof IOError) {
			console.log('SetVersion error', JSON.stringify(results));
		} else {
			console.log('SetVersion success', results.rowsAffected);
		}
	});
};
/**
* This class encapsulates the WebSQL function calls, and exposes a rather generic SQL
* interface so that WebSQL could be easily replaced if necessary.
*/
function DatabaseHelper(dbname, isCopyDatabase) {
	this.dbname = dbname;
	var size = 30 * 1024 * 1024;
    if (window.sqlitePlugin === undefined) {
        console.log('opening WEB SQL Database, stores in Cache', this.dbname);
        this.database = window.openDatabase(this.dbname, "1.0", this.dbname, size);
    } else {
        console.log('opening SQLitePlugin Database, stores in Documents with no cloud', this.dbname);
        var options = { name: this.dbname, location: 2 };
        if (isCopyDatabase) options.createFromLocation = 1;
        this.database = window.sqlitePlugin.openDatabase(options);
    }
	Object.seal(this);
}
DatabaseHelper.prototype.select = function(statement, values, callback) {
    this.database.readTransaction(function(tx) {
        console.log(statement, values);
        tx.executeSql(statement, values, onSelectSuccess, onSelectError);
    });
    function onSelectSuccess(tx, results) {
        console.log('select success results, rowCount=', results.rows.length);
        callback(results);
    }
    function onSelectError(tx, err) {
        console.log('select error', JSON.stringify(err));
        callback(new IOError(err));
    }
};
DatabaseHelper.prototype.executeDML = function(statement, values, callback) {
    this.database.transaction(function(tx) {
	    console.log('exec tran start', statement, values);
        tx.executeSql(statement, values, onExecSuccess, onExecError);
    });
    function onExecSuccess(tx, results) {
    	console.log('excute sql success', results.rowsAffected);
    	callback(results.rowsAffected);
    }
    function onExecError(tx, err) {
        console.log('execute tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
};
DatabaseHelper.prototype.manyExecuteDML = function(statement, array, callback) {
	var that = this;
	executeOne(0);
	
	function executeOne(index) {
		if (index < array.length) {
			that.executeDML(statement, array[index], function(results) {
				if (results instanceof IOError) {
					callback(results);
				} else {
					executeOne(index + 1);
				}
			});
		} else {
			callback(array.length);
		}
	}	
};
DatabaseHelper.prototype.bulkExecuteDML = function(statement, array, callback) {
    var rowCount = 0;
	this.database.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
  		console.log('bulk tran start', statement);
  		for (var i=0; i<array.length; i++) {
        	tx.executeSql(statement, array[i], onExecSuccess);
        }
    }
    function onTranError(err) {
        console.log('bulk tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('bulk tran completed');
        callback(rowCount);
    }
    function onExecSuccess(tx, results) {
        rowCount += results.rowsAffected;
    }
};
DatabaseHelper.prototype.executeDDL = function(statement, callback) {
    this.database.transaction(function(tx) {
        console.log('exec tran start', statement);
        tx.executeSql(statement, [], onExecSuccess, onExecError);
    });
    function onExecSuccess(tx, results) {
        callback();
    }
    function onExecError(tx, err) {
        callback(new IOError(err));
    }
};
DatabaseHelper.prototype.close = function() {
	if (window.sqlitePlugin) {
		this.database.close();
	}
};
/** A smoke test is needed before a database is opened. */
/** A second more though test is needed after a database is opened.*/
DatabaseHelper.prototype.smokeTest = function(callback) {
    var statement = 'select count(*) from tableContents';
    this.select(statement, [], function(results) {
        if (results instanceof IOError) {
            console.log('found Error', JSON.stringify(results));
            callback(false);
        } else if (results.rows.length === 0) {
            callback(false);
        } else {
            var row = results.rows.item(0);
            console.log('found', JSON.stringify(row));
            var count = row['count(*)'];
            console.log('count=', count);
            callback(count > 0);
        }
    });
};
/**
* This class is the database adapter for the codex table
*/
//var IOError = require('./IOError'); What needs this, Publisher does not

function ChaptersAdapter(database) {
	this.database = database;
	this.className = 'ChaptersAdapter';
	Object.freeze(this);
}
ChaptersAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists chapters', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop chapters success');
			callback();
		}
	});
};
ChaptersAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists chapters(' +
		'reference text not null primary key, ' +
		'xml text not null, ' +
		'html text not null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create chapters success');
			callback();
		}
	});
};
ChaptersAdapter.prototype.load = function(array, callback) {
	var statement = 'insert into chapters(reference, xml, html) values (?,?,?)';
	this.database.bulkExecuteDML(statement, array, function(count) {
		if (count instanceof IOError) {
			callback(count);
		} else {
			console.log('load chapters success, rowcount', count);
			callback();
		}
	});
};
ChaptersAdapter.prototype.getChapters = function(values, callback) {
	var statement = 'select reference, html from chapters where';
	if (values.length === 1) {
		statement += ' rowid = ?';
	} else {
		statement += ' rowid >= ? and rowid <= ? order by rowid';
	}
	this.database.select(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('found Error', results);
			callback(results);
		} else {
			callback(results);
        }
	});
};
/**
* This class is the database adapter for the verses table
*/
function VersesAdapter(database) {
	this.database = database;
	this.className = 'VersesAdapter';
	Object.freeze(this);
}
VersesAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists verses', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop verses success');
			callback();
		}
	});
};
VersesAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists verses(' +
		'reference text not null primary key, ' +
		'xml text not null, ' +
		'html text not null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create verses success');
			callback();
		}
	});
};
VersesAdapter.prototype.load = function(array, callback) {
	var statement = 'insert into verses(reference, xml, html) values (?,?,?)';
	this.database.bulkExecuteDML(statement, array, function(count) {
		if (count instanceof IOError) {
			callback(count);
		} else {
			console.log('load verses success, rowcount', count);
			callback();
		}
	});
};
VersesAdapter.prototype.getVerses = function(values, callback) {
	var that = this;
	var numValues = values.length || 0;
	var array = [numValues];
	for (var i=0; i<numValues; i++) {
		array[i] = '?';
	}
	var statement = 'select reference, html from verses where reference in (' + array.join(',') + ') order by rowid';
	this.database.select(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('VersesAdapter select found Error', results);
			callback(results);
		} else if (results.rows.length === 0) {
			callback(new IOError({code: 0, message: 'No Rows Found'}));// Is this really an error?
		} else {
			callback(results);
        }
	});
};/**
* This class is the database adapter for the concordance table
*/
function ConcordanceAdapter(database) {
	this.database = database;
	this.className = 'ConcordanceAdapter';
	Object.freeze(this);
}
ConcordanceAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists concordance', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop concordance success');
			callback();
		}
	});
};
ConcordanceAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists concordance(' +
		'word text primary key not null, ' +
    	'refCount integer not null, ' +
    	'refList text not null, ' + // comma delimited list of references where word occurs
    	'refPosition text null, ' + // comma delimited list of references with position in verse.
    	'refList2 text null)';
   	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create concordance success');
			callback();
		}
	});
};
ConcordanceAdapter.prototype.load = function(array, callback) {
	var statement = 'insert into concordance(word, refCount, refList, refPosition, refList2) values (?,?,?,?,?)';
	this.database.bulkExecuteDML(statement, array, function(count) {
		if (count instanceof IOError) {
			callback(count);
		} else {
			console.log('load concordance success', count);
			callback();
		}
	});
};
ConcordanceAdapter.prototype.select = function(words, callback) {
	var values = [ words.length ];
	var questMarks = [ words.length ];
	for (var i=0; i<words.length; i++) {
		values[i] = words[i].toLocaleLowerCase();
		questMarks[i] = '?';
	}
	var statement = 'select refList from concordance where word in(' + questMarks.join(',') + ')';
	this.database.select(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('found Error', results);
			callback(results);
		} else {
			var refLists = [];
			for (i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				if (row && row.refList) { // ignore words that have no ref list
					var array = row.refList.split(',');
					refLists.push(array);
				}
			}
            callback(refLists);
        }
	});
};
/**
* This is similar to select, except that it returns the refList2 field, 
* and resequences the results into the order the words were entered.
*/
ConcordanceAdapter.prototype.select2 = function(words, callback) {
	var values = [ words.length ];
	var questMarks = [ words.length ];
	for (var i=0; i<words.length; i++) {
		values[i] = words[i].toLocaleLowerCase();
		questMarks[i] = '?';
	}
	var statement = 'select word, refList2 from concordance where word in(' + questMarks.join(',') + ')';
	this.database.select(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('found Error', results);
			callback(results);
		} else {
			var resultMap = {};
			for (i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				if (row && row.refList2) { // ignore words that have no ref list
					resultMap[row.word] = row.refList2;
				}
			}
			var refLists = []; // sequence refList by order search words were entered
			for (i=0; i<values.length; i++) {
				var ref = resultMap[values[i]];
				if (ref) {
					refLists.push(ref.split(','));
				}
			}
            callback(refLists);
        }
	});
};/**
* This class is the database adapter for the tableContents table
*/
function TableContentsAdapter(database) {
	this.database = database;
	this.className = 'TableContentsAdapter';
	Object.freeze(this);
}
TableContentsAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists tableContents', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop tableContents success');
			callback();
		}
	});
};
TableContentsAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists tableContents(' +
		'code text primary key not null, ' +
    	'heading text not null, ' +
    	'title text not null, ' +
    	'name text not null, ' +
    	'abbrev text not null, ' +
		'lastChapter integer not null, ' +
		'priorBook text null, ' +
		'nextBook text null, ' +
		'chapterRowId integer not null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create tableContents success');
			callback();
		}
	});
};
TableContentsAdapter.prototype.load = function(array, callback) {
	var statement = 'insert into tableContents(code, heading, title, name, abbrev, lastChapter, priorBook, nextBook, chapterRowId) ' +
		'values (?,?,?,?,?,?,?,?,?)';
	//this.database.manyExecuteDML(statement, array, function(count) {
	this.database.bulkExecuteDML(statement, array, function(count) {
		if (count instanceof IOError) {
			callback(count);
		} else {
			console.log('load tableContents success, rowcount', count);
			callback();
		}
	});
};
TableContentsAdapter.prototype.selectAll = function(callback) {
	var statement = 'select code, heading, title, name, abbrev, lastChapter, priorBook, nextBook, chapterRowId ' +
		'from tableContents order by rowid';
	this.database.select(statement, [], function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				var tocBook = new TOCBook(row.code, row.heading, row.title, row.name, row.abbrev, 
					row.lastChapter, row.priorBook, row.nextBook, row.chapterRowId);
				array.push(tocBook);
			}
			callback(array);
		}
	});
};/**
* This class is the database adapter for the styleIndex table
*/
function StyleIndexAdapter(database) {
	this.database = database;
	this.className = 'StyleIndexAdapter';
	Object.freeze(this);
}
StyleIndexAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists styleIndex', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop styleIndex success');
			callback();
		}
	});
};
StyleIndexAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists styleIndex(' +
		'style text not null, ' +
		'usage text not null, ' +
		'book text not null, ' +
		'chapter integer null, ' +
		'verse integer null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create styleIndex success');
			callback();
		}
	});
};
StyleIndexAdapter.prototype.load = function(array, callback) {
	var statement = 'insert into styleIndex(style, usage, book, chapter, verse) values (?,?,?,?,?)';
	this.database.bulkExecuteDML(statement, array, function(count) {
		if (count instanceof IOError) {
			callback(count);
		} else {
			console.log('load styleIndex success', count);
			callback();
		}
	});
};/**
* This class is the database adapter for the styleUse table
*/
function StyleUseAdapter(database) {
	this.database = database;
	this.className = 'StyleUseAdapter';
	Object.freeze(this);
}
StyleUseAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists styleUse', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop styleUse success');
			callback();
		}
	});
};
StyleUseAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists styleUse(' +
		'style text not null, ' +
		'usage text not null, ' +
		'primary key(style, usage))';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create styleUse success');
			callback();
		}
	});
};
StyleUseAdapter.prototype.load = function(array, callback) {
	var statement = 'insert into styleUse(style, usage) values (?,?)';
	this.database.bulkExecuteDML(statement, array, function(count) {
		if (count instanceof IOError) {
			callback(count);
		} else {
			console.log('load styleUse success', count);
			callback();
		}
	});
};/**
* This class is the database adapter for the history table
*/
var MAX_HISTORY = 20;

function HistoryAdapter(database) {
	this.database = database;
	this.className = 'HistoryAdapter';
	this.lastSelectCurrent = false;
	Object.seal(this);
}
HistoryAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists history', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop history success');
			callback();
		}
	});
};
HistoryAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists history(' +
		'timestamp text not null primary key, ' +
		'reference text not null unique, ' +
		'source text not null, ' +
		'search text null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create history success');
			callback();
		}
	});
};
HistoryAdapter.prototype.selectPassages = function(callback) {
	var that = this;
	var statement = 'select reference from history order by timestamp desc limit ?';
	this.database.select(statement, [ MAX_HISTORY ], function(results) {
		if (results instanceof IOError) {
			console.log('HistoryAdapter.selectAll Error', JSON.stringify(results));
			callback(results);
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				array.push(row.reference);
			}
			that.lastSelectCurrent = true;
			callback(array);
		}
	});
};
HistoryAdapter.prototype.lastItem = function(callback) {
	var statement = 'select reference from history order by rowid desc limit 1';
	this.database.select(statement, [], function(results) {
		if (results instanceof IOError) {
			console.log('HistoryAdapter.lastItem Error', JSON.stringify(results));
			callback(results);
		} else {
			if (results.rows.length > 0) {
				var row = results.rows.item(0);
				callback(row.reference);
			} else {
				callback(null);
			}
		}
	});
};
HistoryAdapter.prototype.lastConcordanceSearch = function(callback) {
	var statement = 'select search from history where search is not null order by timestamp desc limit 1';
	this.database.select(statement, [], function(results) {
		if (results instanceof IOError) {
			console.log('HistoryAdapter.lastConcordance Error', JSON.stringify(results));
			callback(results);
		} else {
			if (results.rows.length > 0) {
				var row = results.rows.item(0);
				callback(row.search);
			} else {
				callback(new IOError('No rows found'));
			}
		}
	});
};
HistoryAdapter.prototype.replace = function(item, callback) {
	var timestampStr = item.timestamp.toISOString();
	var values = [ timestampStr, item.reference, item.source, item.search || null ];
	var statement = 'replace into history(timestamp, reference, source, search) values (?,?,?,?)';
	var that = this;
	this.lastSelectCurrent = false;
	this.database.executeDML(statement, values, function(count) {
		if (count instanceof IOError) {
			console.log('replace error', JSON.stringify(count));
			callback(count);
		} else {
			that.cleanup(function(count) {
				callback(count);
			});
		}
	});
};
HistoryAdapter.prototype.cleanup = function(callback) {
	var statement = ' delete from history where ? < (select count(*) from history) and timestamp = (select min(timestamp) from history)';
	this.database.executeDML(statement, [ MAX_HISTORY ], function(count) {
		if (count instanceof IOError) {
			console.log('delete error', JSON.stringify(count));
			callback(count);
		} else {
			callback(count);
		}
	});
};/**
* This class is the database adapter for the questions table
*/
function QuestionsAdapter(database) {
	this.database = database;
	this.className = 'QuestionsAdapter';
	Object.freeze(this);
}
QuestionsAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists questions', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop questions success');
			callback();
		}
	});
};
QuestionsAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists questions(' +
		'askedDateTime text not null primary key, ' +
		'discourseId text not null, ' +
		'reference text null, ' + // possibly should be not null
		'question text not null, ' +
		'instructor text null, ' +
		'answerDateTime text null, ' +
		'answer text null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create questions success');
			callback();
		}
	});
};
QuestionsAdapter.prototype.selectAll = function(callback) {
	var statement = 'select discourseId, reference, question, askedDateTime, instructor, answerDateTime, answer ' +
		'from questions order by askedDateTime';
	this.database.select(statement, [], function(results) {
		if (results instanceof IOError) {
			console.log('select questions failure ' + JSON.stringify(results));
			callback(results);
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);	
				var askedDateTime = (row.askedDateTime) ? new Date(row.askedDateTime) : null;
				var answerDateTime = (row.answerDateTime) ? new Date(row.answerDateTime) : null;
				var ques = new QuestionItem(row.reference, row.question, 
					askedDateTime, row.instructor, answerDateTime, row.answer);
				ques.discourseId = row.discourseId;
				array.push(ques);
			}
			callback(array);
		}
	});
};
QuestionsAdapter.prototype.replace = function(item, callback) {
	var statement = 'replace into questions(discourseId, reference, question, askedDateTime) ' +
		'values (?,?,?,?)';
	var values = [ item.discourseId, item.reference, item.question, item.askedDateTime.toISOString() ];
	this.database.executeDML(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('Error on Insert');
			callback(results);
		} else {
			callback(results.rowsAffected);
		}
	});
};
QuestionsAdapter.prototype.update = function(item, callback) {
	var statement = 'update questions set instructor = ?, answerDateTime = ?, answer = ?' +
		'where askedDateTime = ?';
	var values = [ item.instructor, item.answerDateTime.toISOString(), item.answer, item.askedDateTime.toISOString() ];
	this.database.executeDML(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('Error on update');
			callback(results);
		} else {
			callback(results.rowsAffected);
		}
	});
};
/**
* This database adapter is different from the others in this package.  It accesses
* not the Bible, but a different database, which contains a catalog of versions of the Bible.
*
* The App selects from, but never modifies this data.
*/
function VersionsAdapter() {
    this.className = 'VersionsAdapter';
	this.database = new DatabaseHelper('Versions.db', true);
	this.translation = null;
	Object.seal(this);
}
VersionsAdapter.prototype.buildTranslateMap = function(locale, callback) {
	if (this.translation == null) {
		this.translation = {};
		var that = this;
		var locales = findLocales(locale);
		selectLocale(locales.pop());
	}
	
	function selectLocale(oneLocale) {
		// terminate once there are translation items, or there no more locales to process.
		if (that.translation.length > 10 || oneLocale == null) {
			callback(that.translation);
		} else {
			var statement = 'SELECT source, translated FROM Translation WHERE target = ?';
			that.database.select(statement, [oneLocale], function(results) {
				if (results instanceof IOError) {
					console.log('VersionsAdapter.BuildTranslationMap', results);
					callback(results);
				} else {
					for (var i=0; i<results.rows.length; i++) {
						var row = results.rows.item(i);
						that.translation[row.source] = row.translated;
					}
					selectLocale(locales.pop());
				}
			});
		}
	}
	
	function findLocales(locale) {
		var locales = [];
		var parts = locale.split('-');
		locales.push(parts[0]);
		locales.push('en');
		return(locales);
	}
};
VersionsAdapter.prototype.selectCountries = function(callback) {
	var statement = 'SELECT countryCode, primLanguage, localCountryName FROM Country ORDER BY localCountryName';
	this.database.select(statement, null, function(results) {
		if (results instanceof IOError) {
			callback(results)
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				if (row.countryCode === 'WORLD') {
					array.unshift(row);
				} else {
					array.push(row);
				}
			}
			callback(array);
		}
	});
};
VersionsAdapter.prototype.selectVersions = function(countryCode, callback) {
	var statement =	'SELECT v.versionCode, l.localLanguageName, l.langCode, v.localVersionName, v.versionAbbr,' +
		' v.copyright, v.filename, o.localOwnerName, o.ownerURL' +
		' FROM Version v' + 
		' JOIN Owner o ON v.ownerCode = o.ownerCode' +
		' JOIN Language l ON v.silCode = l.silCode' +
		' JOIN CountryVersion cv ON v.versionCode = cv.versionCode' +
		' WHERE cv.countryCode = ?'
	this.database.select(statement, [countryCode], function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				array.push(row);
			}
			callback(array);
		}
	});
};
VersionsAdapter.prototype.selectVersionByFilename = function(versionFile, callback) {
	var statement = 'SELECT v.versionCode, v.silCode, v.isQaActive, v.copyright, v.introduction,' +
		' l.localLanguageName, l.langCode, l.direction, v.localVersionName, v.versionAbbr, o.ownerCode, o.localOwnerName, o.ownerURL' +
		' FROM Version v' +
		' JOIN Owner o ON v.ownerCode = o.ownerCode' +
		' JOIN Language l ON v.silCode = l.silCode' +
		' WHERE v.filename = ?';
	this.database.select(statement, [versionFile], function(results) {
		if (results instanceof IOError) {
			callback(results);
		} if (results.rows.length === 0) {
			callback(new IOError('No version found'));
		} else {
			callback(results.rows.item(0));
		}
	});
};
VersionsAdapter.prototype.close = function() {
	this.database.close();		
};

/**
* This class encapsulates the get and post to the BibleApp Server
* from the BibleApp
*/
function HttpClient(server, port) {
	this.server = server;
	this.port = port;
	this.authority = 'http://' + this.server + ':' + this.port;
}
HttpClient.prototype.get = function(path, callback) {
	this.request('GET', path, null, callback);
};
HttpClient.prototype.put = function(path, postData, callback) {
	this.request('PUT', path, postData, callback);
};
HttpClient.prototype.post = function(path, postData, callback) {
	this.request('POST', path, postData, callback);
};
HttpClient.prototype.request = function(method, path, postData, callback) {
	console.log(method, path, postData);	
	var request = createRequest();
	if (request) {
		request.onreadystatechange = progressEvents;
		request.open(method, this.authority + path, true);
		var data = (postData) ? JSON.stringify(postData) : null;
		if (data) {
			request.setRequestHeader('Content-Type', 'application/json');
		}
		request.send(data);		
	} else {
		callback(-2, new Error('XMLHttpRequest was not created.'));
	}

	function progressEvents() {
		try {
	    	if (request.readyState === 4) {
		    	if (request.status === 0) {
			    	callback(request.status, new Error('Could not reach the server, please try again when you have a better connection.'));
		    	} else {
		    		callback(request.status, JSON.parse(request.responseText));
		    	}
	    	}
	    } catch(error) {
		    callback(-1, error);
	    }
  	}

	function createRequest() {
		var request;
		if (window.XMLHttpRequest) { // Mozilla, Safari, ...
			request = new XMLHttpRequest();
    	} else if (window.ActiveXObject) { // IE
			try {
				request = new ActiveXObject("Msxml2.XMLHTTP");
      		} 
	  		catch (e) {
	  			try {
	  				request = new ActiveXObject("Microsoft.XMLHTTP");
        		} 
				catch (e) {}
      		}
    	}
    	return(request);
	}
};

/**
* This class first checks to see if the App is a first install or update.
* It does this by checking the App version number against a copy of the
* App version number stored in the Settings database.  If the versions are
* the same, it is not an update and nothing further needs to be done by this class.
*
* Next this class gets a list of all the database (.db) files in the www
* directory and a map of all the database files in the databases directory.
* For every database present in the www directory, it deletes the corresponding
* file in the databases directory.
*
* By deleting the files from the databases directory, it ensures that when one
* of those deleted databases is opened, the DatabaseHelper class will first copy
* the database from the www directory to the databases directory.
*/
function FileMover(settingStorage) {
	this.settingStorage = settingStorage;
	Object.seal(this);
}
FileMover.prototype.copyFiles = function(callback) {
	var that = this;
	var sourceDir = null;
	var targetDir = null;
	var sourceDirEntry = null;
	var targetDirEntry = null;
	this.settingStorage.getAppVersion(function(appVersion) {
		try {
			if (BuildInfo.version === appVersion) {
				callback();
			} else {
				sourceDir = cordova.file.applicationDirectory + 'www/';
				if (deviceSettings.platform() === 'ios') {
					targetDir = cordova.file.applicationStorageDirectory + 'Library/LocalDatabase/';
				} else {
					targetDir = cordova.file.applicationStorageDirectory + 'databases/';
				}
				readDirectories(sourceDir, targetDir, callback);
			}
		} catch(err) {
			sourceDir = 'www/';
			targetDir = '../../../Library/Application Support/BibleAppNW/databases/file__0/';
			//readDirectories(sourceDir, targetDir, callback); window.resolve... does not work for node-webkit
			callback();
		}
	});
	
	function readDirectories(sourceDir, targetDir, callback) {
		getDirEntry(sourceDir, function(dirEntry) {
			sourceDirEntry = dirEntry;
			getFiles(dirEntry, function(sourceDirMap, sourceDirArray) {
				getDirEntry(targetDir, function(dirEntry) {
					targetDirEntry = dirEntry;
					getFiles(dirEntry, function(targetDirMap, targetDirArray) {
						doRemoves(0, sourceDirArray, targetDirMap, callback);
					});
				});
			});
		});
	}
	
	function getDirEntry(filePath, callback) {
		window.resolveLocalFileSystemURL(filePath, function(dirEntry) {
			callback(dirEntry);
		},
		function(fileError) {
			console.log('RESOLVE ERROR', filePath, JSON.stringify(fileError));
			callback();
		});
	}
	
	function getFiles(dirEntry, callback) {
		var dirMap = {};
		var dirArray = [];
		if (dirEntry) {
			var dirReader = dirEntry.createReader();
			dirReader.readEntries (function(results) {
				for (var i=0; i<results.length; i++) {
					var file = results[i];
					var filename = file.name;
					var fileType = filename.substr(filename.length -3, 3);
					if (fileType === '.db') {
						dirMap[filename] = file;
						dirArray.push(file);
					}
				}
				callback(dirMap, dirArray);
			});
		} else {
			callback(dirMap, dirArray);
		}	
	}
	
	function doRemoves(index, sourceFiles, targetFiles, callback) {
		if (index >= Object.keys(sourceFiles).length) {
			that.settingStorage.setAppVersion(BuildInfo.version);
			callback();
		} else {
			var source = sourceFiles[index];
			console.log('CHECK FOR REMOVE FROM /databases', source.name);
			var target = targetFiles[source.name];
			if (target) {
				target.remove(function() {
					console.log('REMOVE FROM /databases SUCCESS', target.name);
					doRemoves(index + 1, sourceFiles, targetFiles, callback);
				}, 
				function(fileError) {
					console.log('REMOVE ERROR', target.name, JSON.stringify(fileError));
					doRemoves(index + 1, sourceFiles, targetFiles, callback);
				});
			} else {
				doRemoves(index + 1, sourceFiles, targetFiles, callback);
			}
		}
	}
};

/**
* This class encapsulates the Cordova FileTransfer plugin for file download
* It is a simple plugin, but encapsulated here in order to make it easy to change
* the implementation.
*
* 'persistent' will store the file in 'Documents' in Android and 'Library' in iOS
* 'LocalDatabase' is the file under Library where the database is expected.
*/
function FileDownloader(host, port, currVersion) {
	this.fileTransfer = new FileTransfer();
	this.uri = encodeURI('http://' + host + ':' + port + '/book/');
	this.currVersion = currVersion;
	this.downloadPath = 'cdvfile://localhost/temporary/';
	if (deviceSettings.platform() === 'ios') {
		this.finalPath = 'cdvfile://localhost/persistent/../LocalDatabase/';
	} else {
		this.finalPath = '/data/data/com.shortsands.yourbible/databases/';
	}
	Object.seal(this);
}
FileDownloader.prototype.download = function(bibleVersion, callback) {
	var that = this;
	var bibleVersionZip = bibleVersion + '.zip';
	var remotePath = this.uri + bibleVersionZip;
	var tempPath = this.downloadPath + bibleVersionZip;
	console.log('download from', remotePath, ' to ', tempPath);
	var datetime = new Date().toISOString();
	var encrypted = CryptoJS.AES.encrypt(datetime, CREDENTIAL.key);
	getLocale(function(locale) {
		var options = { 
			headers: {
				'Authorization': 'Signature  ' + CREDENTIAL.id + '  ' + CREDENTIAL.version + '  ' + encrypted,
				'x-time': datetime,
				'x-locale': locale,
				'x-referer-version': that.currVersion
			}
		}
	    that.fileTransfer.download(remotePath, tempPath, onDownSuccess, onDownError, true, options);
	});
    
    function getLocale(callback) {
		preferredLanguage(function(pLocale) {
			localeName(function(locale) {
				callback(pLocale + ',' + locale);
			});
		});
	}
	function preferredLanguage(callback) {
		navigator.globalization.getPreferredLanguage(
	    	function(locale) { callback(locale.value); },
			function() { callback(''); }
		);
	}
	function localeName(callback) {
		navigator.globalization.getLocaleName(
	    	function(locale) { callback(locale.value); },
			function() { callback(''); }
		);
	}

    function onDownSuccess(entry) {
    	console.log("download complete: ", JSON.stringify(entry));
    	zip.unzip(tempPath, that.finalPath, function(resultCode) {
	    	if (resultCode == 0) {
	    		console.log('ZIP done', resultCode);
	    		callback();		    	
	    	} else {
		    	callback(new IOError({code: 'unzip failed', message: entry.nativeURL}));
	    	}
		});
    }
    function onDownError(error) {
       	callback(new IOError({ code: error.code, message: error.source}));   	
    }
};
/**
* This class is used to contain the fields about a version of the Bible
* as needed.
*/
function BibleVersion() {
	this.code = null;
	this.filename = null;
	this.userFilename = null;
	this.silCode = null;
	this.langCode = null;
	this.direction = null;
	this.isQaActive = null;
	this.versionAbbr = null;
	this.localLanguageName = null;
	this.localVersionName = null;
	this.ownerCode = null;
	this.ownerName = null;
	this.ownerURL = null;
	this.copyright = null;
	this.introduction = null;
	Object.seal(this);
}
BibleVersion.prototype.fill = function(filename, callback) {
	var that = this;
	var versionsAdapter = new VersionsAdapter();
	versionsAdapter.selectVersionByFilename(filename, function(row) {
		if (row instanceof IOError) {
			console.log('IOError selectVersionByFilename', JSON.stringify(row));
			that.code = 'WEB';
			that.filename = 'WEB.db';
			that.userFilename = 'WEBUser.db';
			that.silCode = 'eng';
			that.langCode = 'en';
			that.direction = 'ltr';
			that.isQaActive = 'F';
			that.versionAbbr = 'WEB';
			that.localLanguageName = 'English';
			that.localVersionName = 'World English Bible';
			that.ownerCode = 'EB';
			that.ownerName = 'eBible';
			that.ownerURL = 'www.eBible.org';
			that.copyright = 'World English Bible (WEB), Public Domain, eBible.';
			that.introduction = null;
		} else {
			that.code = row.versionCode;
			that.filename = filename;
			var parts = filename.split('.');
			that.userFilename = parts[0] + 'User.db';
			that.silCode = row.silCode;
			that.langCode = row.langCode;
			that.direction = row.direction;
			that.isQaActive = row.isQaActive;
			that.versionAbbr = row.versionAbbr;
			that.localLanguageName = row.localLanguageName;
			that.localVersionName = row.localVersionName;
			that.ownerCode = row.ownerCode;
			that.ownerName = row.localOwnerName;
			that.ownerURL = row.ownerURL;
			that.copyright = row.copyright;
			that.introduction = row.introduction;
		}
		callback();
	});
};

/**
* This class holds the concordance of the entire Bible, or whatever part of the Bible was available.
*/
function Concordance(adapter, wordsLookAhead) {
	this.adapter = adapter;
	this.wordsLookAhead = (wordsLookAhead) ? wordsLookAhead : 0;
	Object.freeze(this);
}
Concordance.prototype.search = function(words, callback) {
	var that = this;
	this.adapter.select(words, function(refLists) {
		if (refLists instanceof IOError) {
			callback(refLists);
		} else {
			var result = intersection(refLists);
			callback(result);
		}
	});
	function intersection(refLists) {
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
	}
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
Concordance.prototype.search2 = function(words, callback) {
	var that = this;
	this.adapter.select2(words, function(refLists) {
		if (refLists instanceof IOError) {
			callback(refLists);
		} else if (refLists.length !== words.length) {
			callback([]);
		} else {
			var resultList = intersection(refLists);
			callback(resultList);
		}
	});
	function intersection(refLists) {
		if (refLists.length === 0) {
			return([]);
		}
		var resultList = [];
		if (refLists.length === 1) {
			for (var ii=0; ii<refLists[0].length; ii++) {
				resultList.push([refLists[0][ii]]);
			}
			return(resultList);
		}
		var mapList = [];
		for (var i=1; i<refLists.length; i++) {
			var map = arrayToMap(refLists[i]);
			mapList.push(map);
		}
		var firstList = refLists[0];
		for (var j=0; j<firstList.length; j++) {
			var reference = firstList[j];
			var resultItem = matchEachWord(mapList, reference);
			if (resultItem) {
				resultList.push(resultItem);
			}
		}
		return(resultList);
	}
	function arrayToMap(array) {
		var map = {};
		for (var i=0; i<array.length; i++) {
			map[array[i]] = true;
		}
		return(map);
	}
	function matchEachWord(mapList, reference) {
		var resultItem = [ reference ];
		for (var i=0; i<mapList.length; i++) {
			reference = matchWordWithLookahead(mapList[i], reference);
			if (reference == null) {
				return(null);
			}
			resultItem.push(reference);
		}
		return(resultItem);
	}
	function matchWordWithLookahead(mapRef, reference) {
		for (var look=1; look<=that.wordsLookAhead + 1; look++) {
			var next = nextPosition(reference, look);
			if (mapRef[next]) {
				return(next);
			}
		}
		return(null);
	}
	function nextPosition(reference, position) {
		var parts = reference.split(';');
		var next = parseInt(parts[1]) + position;
		return(parts[0] + ';' + next.toString());
	}
};
/**
* This class process search strings to determine if they are book chapter,
* or book chapter:verse lookups.  If so, then it processes them by dispatching
* the correct event.  If not, then it returns them to be processed as
* concordance searches.
*/
function Lookup(tableContents) {
	this.index = {};
	for (var i=0; i<tableContents.bookList.length; i++) {
		var tocBook = tableContents.bookList[i];
		this.index[tocBook.name.toLocaleLowerCase()] = tocBook;
		this.index[tocBook.abbrev.toLocaleLowerCase()] = tocBook;
	}
	Object.freeze(this);
}

Lookup.prototype.find = function(search) {
	var matches = search.match(/^(\d*)\s*(\w+)\s+(\d+):?(\d*)$/i);
	if (matches === null) {
		return(false);
	} else {
		if (matches[1].length < 1) {
			var book = matches[2].toLocaleLowerCase();
		} else {
			book = matches[1] + ' ' + matches[2].toLocaleLowerCase();
		}
		var chap = matches[3];
		var verse = (matches.length > 4) ? matches[4] : null;
		console.log('book=', book, '  chap=', chap, '  verse=', verse);
		var tocBook = this.index[book];
		if (tocBook) {
			var nodeId = tocBook.code + ':' + chap;
			if (verse) {
				nodeId += ':' + verse;
			}
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId }}));
			return(true);
		} else {
			return(false);
		}
	}
};
/**
* This class contains the contents of one user question and one instructor response.
*/
function QuestionItem(reference, question, askedDt, instructor, answerDt, answer) {
	this.discourseId = null;
	this.reference = reference;
	this.question = question;
	this.askedDateTime = askedDt;
	this.instructor = instructor;
	this.answerDateTime = answerDt;
	this.answer = answer;
	Object.seal(this);
}/**
* This class contains the list of questions and answers for this student
* or device.
*/
function Questions(questionsAdapter, versesAdapter, tableContents, version) {
	this.questionsAdapter = questionsAdapter;
	this.versesAdapter = versesAdapter;
	this.tableContents = tableContents;
	this.version = version;
	this.httpClient = new HttpClient(SERVER_HOST, SERVER_PORT);
	this.items = [];
	Object.seal(this);
}
Questions.prototype.size = function() {
	return(this.items.length);
};
Questions.prototype.find = function(index) {
	return((index >= 0 && index < this.items.length) ? this.items[index] : null);
};
Questions.prototype.addQuestion = function(item, callback) {
	var that = this;
	var postData = {versionId:this.version.code, reference:item.reference, message:item.question};
	this.httpClient.put('/question', postData, function(status, results) {
		if (status !== 200 && status !== 201) {
			callback(results);
		} else {
			item.discourseId = results.discourseId;
			item.askedDateTime = new Date(results.timestamp);
			that.addQuestionLocal(item, callback);
		}
	});
};
Questions.prototype.addQuestionLocal = function(item, callback) {
	var that = this;
	this.questionsAdapter.replace(item, function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else {
			that.items.push(item);
			callback();
		}
	});
};
Questions.prototype.addAnswerLocal = function(item, callback) {
	this.questionsAdapter.update(item, function(results) {
		if (results instanceof IOError) {
			console.log('Error on update', results);
			callback(results);
		} else {
			callback();
		}
	});
};
Questions.prototype.fill = function(callback) {
	var that = this;
	this.questionsAdapter.selectAll(function(results) {
		if (results instanceof IOError) {
			console.log('select questions failure ' + JSON.stringify(results));
			callback(results);
		} else {
			that.items = results;
			callback(results);// needed to determine if zero length result
		}
	});
};
Questions.prototype.checkServer = function(callback) {
	var that = this;
	var unanswered = findUnansweredQuestions();
	var discourseIds = Object.keys(unanswered);
	if (discourseIds.length > 0) {
		var path = '/response/' + discourseIds.join('/');
		this.httpClient.get(path, function(status, results) {
			if (status === 200) {
				var indexes = updateAnsweredQuestions(unanswered, results);
				callback(indexes);
			} else {
				callback([]);
			}
		});
	} else {
		callback([]);
	}
	function findUnansweredQuestions() {
		var indexes = {};
		for (var i=0; i<that.items.length; i++) {
			var item = that.items[i];
			if (item.answerDateTime === null || item.answerDateTime === undefined) {
				indexes[item.discourseId] = i;
			}
		}
		return(indexes);
	}
	function updateAnsweredQuestions(unanswered, results) {
		var indexes = [];
		for (var i=0; i<results.length; i++) {
			var row = results[i];
			var itemId = unanswered[row.discourseId];
			var item = that.items[itemId];
			if (item.discourseId !== row.discourseId) {
				console.log('Attempt to update wrong item in Questions.checkServer');
			} else {
				item.instructor = row.pseudonym;
				item.answerDateTime = new Date(row.timestamp);
				item.answer = row.message;
				indexes.push(itemId);
				
				that.addAnswerLocal(item, function(error) {
					if (error) {
						console.log('Error occurred adding answer to local store ' + error);
					}
				});
			}
		}
		return(indexes);
	}
};
Questions.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};
/**
* This class contains a reference to a chapter or verse.  It is used to
* simplify the transition from the "GEN:1:1" format to the format
* of distinct parts { book: GEN, chapter: 1, verse: 1 }
* This class leaves unset members as undefined.
*/
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
	this.chapterId = this.book + ':' + this.chapter;
	Object.freeze(this);
}
Reference.prototype.path = function() {
	return(this.book + '/' + this.chapter + '.usx');
};
Reference.prototype.chapterVerse = function() {
	return((this.verse) ? this.chapter + ':' + this.verse : this.chapter);
};
Reference.prototype.append = function(parent, html) {
	var rootNode = document.createElement('div');
	rootNode.setAttribute('id', 'top' + this.nodeId);
	rootNode.innerHTML = html;
	parent.appendChild(rootNode);
};
Reference.prototype.prepend = function(parent, html) {
	var rootNode = document.createElement('div');
	rootNode.setAttribute('id', 'top' + this.nodeId);
	rootNode.innerHTML = html;
	parent.insertBefore(rootNode, parent.firstChild);
};
/**
* This class holds data for the table of contents of the entire Bible, or whatever part of the Bible was loaded.
*/
function TOC(adapter) {
	this.adapter = adapter;
	this.bookList = [];
	this.bookMap = {};
	this.isFilled = false;
	Object.seal(this);
}
TOC.prototype.fill = function(callback) {
	var that = this;
	this.adapter.selectAll(function(results) {
		if (results instanceof IOError) {
			callback();
		} else {
			that.bookList = results;
			that.bookMap = {};
			for (var i=0; i<results.length; i++) {
				var tocBook = results[i];
				that.bookMap[tocBook.code] = tocBook;
			}
			that.isFilled = true;
		}
		Object.freeze(that);
		callback();
	});
};
TOC.prototype.addBook = function(book) {
	this.bookList.push(book);
	this.bookMap[book.code] = book;
};
TOC.prototype.find = function(code) {
	return(this.bookMap[code]);
};
TOC.prototype.rowId = function(reference) {
	var current = this.bookMap[reference.book];
	var rowid = current.chapterRowId + reference.chapter;
	return(rowid);	
};
TOC.prototype.size = function() {
	return(this.bookList.length);
};
TOC.prototype.toString = function(reference) {
	return(this.find(reference.book).name + ' ' + reference.chapter + ':' + reference.verse);
};
TOC.prototype.toJSON = function() {
	return(JSON.stringify(this.bookList, null, ' '));
};/**
* This class holds the table of contents data each book of the Bible, or whatever books were loaded.
*/
function TOCBook(code, heading, title, name, abbrev, lastChapter, priorBook, nextBook, chapterRowId) {
	this.code = code || null;
	this.heading = heading || null;
	this.title = title || null;
	this.name = name || null;
	this.abbrev = abbrev || null;
	this.lastChapter = lastChapter || null;
	this.priorBook = priorBook || null;
	this.nextBook = nextBook || null; // do not want undefined in database
	this.chapterRowId = chapterRowId || null;
	if (lastChapter) {
		Object.freeze(this);
	} else {
		Object.seal(this);
	}
}/**
* This class performs localized date and time formatting.
* It is written as a distinct class, because the way this is done
* using Cordova is different than how it is done using WebKit/Node.js
*/
function DateTimeFormatter() {
	// get the students country and language information
	this.language = 'en';
	this.country = 'US';
	this.locale = this.language + '-' + this.country;
	Object.freeze(this);
}
DateTimeFormatter.prototype.localDate = function(date) {
	if (date) {
		var options = { year: 'numeric', month: 'long', day: 'numeric' };
		return(date.toLocaleString('en-US', options));
	} else {
		return('');
	}
};
DateTimeFormatter.prototype.localTime = function(date) {
	if (date) {
		var options = { hour: 'numeric', minute: 'numeric', second: 'numeric' };
		return(date.toLocaleString('en-US', options));
	} else {
		return('');
	}
};
DateTimeFormatter.prototype.localDatetime = function(date) {
	if (date) {
		var options = { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric', second: 'numeric' };
		return(date.toLocaleString('en-US', options));
	} else {
		return('');
	}
};
/**
 * This class accesses the device locale and language information using the globalization plugin
 * and the versions, platform and model of the device plugin, and the network status.
 */
var deviceSettings = {
    prefLanguage: function(callback) {
        navigator.globalization.getPreferredLanguage(onSuccess, onError);

        function onSuccess(pref) {
            callback(pref.value);
        }
        function onError() {
            callback('en-US');
        }
    },
    platform: function() {
        return((device.platform) ? device.platform.toLowerCase() : null);
    },
    model: function() {
        return(device.model);
    },
    uuid: function() {
        return(device.uuid);
    },
    osVersion: function() {
        return(device.version);
    },
    cordovaVersion: function() {
        return(device.cordova);
    },
    connectionType: function() {
        return(navigator.connection.type);
    },
    hasConnection: function() {
        var type = navigator.connection.type;
        return(type !== 'none' && type !== 'unknown'); // not sure of correct value for UNKNOWN
    }
};/**
* This is a helper class to remove the repetitive operations needed
* to dynamically create DOM objects.
*/
function DOMBuilder() {
	//this.rootNode = root;
}
DOMBuilder.prototype.addNode = function(parent, type, clas, content, id) {
	var node = document.createElement(type);
	if (id) node.setAttribute('id', id);
	if (clas) node.setAttribute('class', clas);
	if (content) node.textContent = content;
	parent.appendChild(node);
	return(node);
};
