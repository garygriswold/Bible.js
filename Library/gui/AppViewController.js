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
		HIDE_NOTE: 'bible-hide-note', // Hide footnote as a result of user action
	};
var SERVER_HOST = 'cloudfront.net';
var SERVER_PORT = '80';
//var SERVER_HOST = 'cloud.shortsands.com';
//var SERVER_PORT = '8080';

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
	var dynamicCSS = new DynamicCSS();
	dynamicCSS.setDirection(this.version.direction);
	
	this.settingStorage = settingStorage;
	
	this.database = new DatabaseHelper(version.filename, true);
	this.chapters = new ChaptersAdapter(this.database);
    this.verses = new VersesAdapter(this.database);
	this.tableAdapter = new TableContentsAdapter(this.database);
	this.concordance = new ConcordanceAdapter(this.database);
	this.styleIndex = new StyleIndexAdapter(this.database);
	this.styleUse = new StyleUseAdapter(this.database);

	this.history = new HistoryAdapter(this.settingStorage.database);
	this.questions = new QuestionsAdapter(this.settingStorage.database);
}
AppViewController.prototype.begin = function(develop) {
	this.tableContents = new TOC(this.tableAdapter);
	this.concordance = new Concordance(this.concordance);
	var that = this;
	this.tableContents.fill(function() { // must complete before codexView.showView()
		console.log('loaded toc', that.tableContents.size());
		that.copyrightView = new CopyrightView(that.version);
		that.localizeNumber = new LocalizeNumber(that.version.silCode);
		that.header = new HeaderView(that.tableContents, that.version, that.localizeNumber);
		that.tableContentsView = new TableContentsView(that.tableContents, that.copyrightView, that.localizeNumber);
		that.tableContentsView.rootNode.style.top = that.header.barHite + 'px';  // Start view at bottom of header.
		that.searchView = new SearchView(that.tableContents, that.concordance, that.verses, that.history, that.version, that.localizeNumber);
		that.searchView.rootNode.style.top = that.header.barHite + 'px';  // Start view at bottom of header.
		that.codexView = new CodexView(that.chapters, that.tableContents, that.header.barHite, that.copyrightView);
		that.historyView = new HistoryView(that.history, that.tableContents, that.localizeNumber);
		that.historyView.rootNode.style.top = that.header.barHite + 'px';
		that.questionsView = new QuestionsView(that.questions, that.verses, that.tableContents, that.version);
		that.questionsView.rootNode.style.top = that.header.barHite + 'px'; // Start view at bottom of header.
		that.settingsView = new SettingsView(that.settingStorage, that.verses);
		that.settingsView.rootNode.style.top = that.header.barHite + 'px';  // Start view at bottom of header.
		that.touch = new Hammer(document.getElementById('codexRoot'));
		setInitialFontSize();
		Object.seal(that);
		that.header.showView();

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
					that.codexView.showView('JHN:3');
				} else {
					console.log('LastItem' + JSON.stringify(lastItem));
					that.codexView.showView(lastItem);
				}
			});
		}
		/* Turn off user selection, and selection popup */
		document.documentElement.style.webkitTouchCallout = 'none';
        document.documentElement.style.webkitUserSelect = 'none';

		document.body.addEventListener(BIBLE.SHOW_NOTE, function(event) {
			that.codexView.showFootnote(event.detail.id);
		});
		document.body.addEventListener(BIBLE.HIDE_NOTE, function(event) {
			that.codexView.hideFootnote(event.detail.id);
		});
		that.touch.on("panright", function(event) {
			if (that.version.hasHistory && event.deltaX > 4 * Math.abs(event.deltaY)) {
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
				fontSize = '16';
			}
			document.documentElement.style.fontSize = fontSize + 'pt';			
		});
	}
};
AppViewController.prototype.clearViews = function() {
	this.tableContentsView.hideView();
	this.searchView.hideView();
	this.codexView.hideView();
	this.questionsView.hideView();
	this.settingsView.hideView();
	this.historyView.hideView();
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
