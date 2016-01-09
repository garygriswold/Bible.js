/**
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
		HIDE_NOTE: 'bible-hide-note' // Hide footnote as a result of user action
	};
var SERVER_HOST = 'qa.shortsands.com';//'localhost';
var SERVER_PORT = '8080';

function bibleShowNoteClick(nodeId) {
	console.log('show note clicked', nodeId);
	event.stopImmediatePropagation();
	document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_NOTE, { detail: { id: nodeId }}));
	var node = document.getElementById(nodeId);
	if (node) {
		node.setAttribute('onclick', "bibleHideNoteClick('" + nodeId + "');");
	}
}
function bibleHideNoteClick(nodeId) {
	console.log('hide note clicked', nodeId);
	event.stopImmediatePropagation();
	document.body.dispatchEvent(new CustomEvent(BIBLE.HIDE_NOTE, { detail: { id: nodeId }}));
	var node = document.getElementById(nodeId);
	if (node) {
		node.setAttribute('onclick', "bibleShowNoteClick('" + nodeId + "');");
	}
}

function AppViewController(version, settingStorage) {
	this.version = version;
	this.settingStorage = settingStorage;
	this.database = new DeviceDatabase(version.filename);
	for (var i=document.body.children.length -1; i>=0; i--) {
		document.body.removeChild(document.body.children[i]);
	}
}
AppViewController.prototype.begin = function(develop) {
	this.tableContents = new TOC(this.database.tableContents);
	this.concordance = new Concordance(this.database.concordance);
	var that = this;
	this.tableContents.fill(function() {

		console.log('loaded toc', that.tableContents.size());
		
		that.header = new HeaderView(that.tableContents, that.version);
		that.header.showView();
		that.tableContentsView = new TableContentsView(that.tableContents);
		that.tableContentsView.rootNode.style.top = that.header.barHite + 'px';  // Start view at bottom of header.
		that.searchView = new SearchView(that.tableContents, that.concordance, that.database.verses, that.database.history);
		that.searchView.rootNode.style.top = that.header.barHite + 'px';  // Start view at bottom of header.
		that.codexView = new CodexView(that.database.chapters, that.tableContents, that.header.barHite);
		that.historyView = new HistoryView(that.database.history, that.tableContents);
		that.historyView.rootNode.style.top = that.header.barHite + 'px';
		that.questionsView = new QuestionsView(that.database.questions, that.database.verses, that.tableContents);
		that.questionsView.rootNode.style.top = that.header.barHite + 'px'; // Start view at bottom of header.
		that.settingsView = new SettingsView(that.settingStorage, that.database.verses);
		that.settingsView.rootNode.style.top = that.header.barHite + 'px';  // Start view at bottom of header.
		that.touch = new Hammer(document.getElementById('codexRoot'));
		setInitialFontSize();
		Object.freeze(that);

		switch(develop) {
		case 'TableContentsView':
			that.tableContentsView.showView();
			break;
		case 'SearchView':
			that.searchView.showView('risen');
			break;
		case 'HistoryView':
			that.historyView.showView(function() {});
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
			that.database.history.lastItem(function(lastItem) {
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
        
		document.body.addEventListener(BIBLE.SHOW_TOC, showTocHandler);
		document.body.addEventListener(BIBLE.SHOW_SEARCH, showSearchHandler);
		document.body.addEventListener(BIBLE.SHOW_PASSAGE, showPassageHandler);
		document.body.addEventListener(BIBLE.SHOW_QUESTIONS, showQuestionsHandler);
		document.body.addEventListener(BIBLE.SHOW_SETTINGS, showSettingsHandler);

		document.body.addEventListener(BIBLE.SHOW_NOTE, function(event) {
			that.codexView.showFootnote(event.detail.id);
		});
		document.body.addEventListener(BIBLE.HIDE_NOTE, function(event) {
			that.codexView.hideFootnote(event.detail.id);
		});
		var panRightEnabled = true;
		that.touch.on("panright", function(event) {
			if (panRightEnabled && event.deltaX > 4 * Math.abs(event.deltaY)) {
				panRightEnabled = false;
				that.historyView.showView(function() {
					panRightEnabled = true;
				});
			}
		});
		var panLeftEnabled = true;
		that.touch.on("panleft", function(event) {
			if (panLeftEnabled && -event.deltaX > 4 * Math.abs(event.deltaY)) {
				panLeftEnabled = false;
				that.historyView.hideView(function() {
					panLeftEnabled = true;		
				});
			}
		});
	});
	document.body.addEventListener(BIBLE.CHG_HEADING, function(event) {
		console.log('caught set title event', JSON.stringify(event.detail.reference.nodeId));
		that.header.setTitle(event.detail.reference);
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
		console.log('SHOW PASSAGE', event.detail.id, event.detail.search);
		disableHandlers();
		clearViews();
		that.codexView.showView(event.detail.id);
		enableHandlersExcept('NONE');
		var historyItem = { timestamp: new Date(), reference: event.detail.id, 
			source: 'P', search: event.detail.source };
		that.database.history.replace(historyItem, function(count) {});
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
