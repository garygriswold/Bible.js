/**
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
var BIBLE = { SHOW_TOC: 'bible-show-toc', // present toc page, create if needed
		SHOW_SEARCH: 'bible-show-search', // present search page, create if needed
		SHOW_QUESTIONS: 'bible-show-questions', // present questions page, create first
		SHOW_HISTORY: 'bible-show-history', // present history tabs
		HIDE_HISTORY: 'bible-hide-history', // hide history tabs
		SHOW_PASSAGE: 'bible-show-passage', // show passage in codex view
		LOOKUP: 'TBD-bible-lookup', // TBD
		SEARCH_START: 'bible-search-start', // process user entered search string
		CHG_HEADING: 'bible-chg-heading', // change title at top of page as result of user scrolling
		SHOW_NOTE: 'bible-show-note', // Show footnote as a result of user action
		HIDE_NOTE: 'bible-hide-note' // Hide footnote as a result of user action
	};

function AppViewController(versionCode) {
	this.versionCode = versionCode;
	this.touch = new Hammer(document.getElementById('codexRoot'));
	this.database = new DeviceDatabase(versionCode, 'nameForVersion');
}
AppViewController.prototype.begin = function(develop) {
	this.tableContents = new TOC(this.database.tableContents);
	this.bibleCache = new BibleCache(this.database.codex);
	this.concordance = new Concordance(this.database.concordance);
	this.history = new History(this.database.history);
	var that = this;
	initDatabase(function() {
		console.log('loaded toc', that.tableContents.size());
		console.log('loaded history', that.history.size());
		
		that.tableContentsView = new TableContentsView(that.tableContents);
		that.lookup = new Lookup(that.tableContents);
		that.statusBar = new StatusBarView(88, that.tableContents);
		that.statusBar.showView();
		that.searchView = new SearchView(that.tableContents, that.concordance, that.bibleCache, that.history);
		that.codexView = new CodexView(that.tableContents, that.bibleCache, that.statusBar.hite + 7);
		that.historyView = new HistoryView(that.history, that.tableContents);
		that.questionsView = new QuestionsView(that.database.questions, that.bibleCache, that.tableContents);
		Object.freeze(that);

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
		default:
			var lastItem = that.history.last();
			console.log(lastItem);
			console.log('History size', that.history.size());
			that.codexView.showView(lastItem.nodeId);
		}
		document.body.addEventListener(BIBLE.SHOW_TOC, function(event) {
			that.tableContentsView.showView();
			that.statusBar.showTitleField();
			that.searchView.hideView();
			that.historyView.hideView();
			that.questionsView.hideView();
			that.codexView.hideView();
		});
		document.body.addEventListener(BIBLE.SHOW_SEARCH, function(event) {
			that.searchView.showView();
			that.statusBar.showSearchField();
			that.tableContentsView.hideView();
			that.historyView.hideView();
			that.questionsView.hideView();
			that.codexView.hideView();
		});
		document.body.addEventListener(BIBLE.SHOW_QUESTIONS, function(event) {
			that.questionsView.showView();
			that.statusBar.showTitleField();
			that.tableContentsView.hideView();
			that.searchView.hideView();
			that.historyView.hideView();
			that.codexView.hideView();			
		});
		that.touch.on("panright", function(event) {
			if (event.deltaX > 4 * Math.abs(event.deltaY)) {
				that.historyView.showView();
			}
		});
		that.touch.on("panleft", function(event) {
			if ( -event.deltaX > 4 * Math.abs(event.deltaY)) {
				that.historyView.hideView();
			}
		});
		document.body.addEventListener(BIBLE.SEARCH_START, function(event) {
			console.log('SEARCH_START', event.detail);
			if (! that.lookup.find(event.detail.search)) {
				that.searchView.showView(event.detail.search);
				that.statusBar.showSearchField(event.detail.search);
			}
		});
		document.body.addEventListener(BIBLE.SHOW_PASSAGE, function(event) {
			console.log(JSON.stringify(event.detail));
			that.codexView.showView(event.detail.id);
			that.statusBar.showTitleField();
			that.tableContentsView.hideView();
			that.searchView.hideView();
			that.history.addEvent(event);
		});
		document.body.addEventListener(BIBLE.CHG_HEADING, function(event) {
			that.statusBar.setTitle(event.detail.reference);
		});
		document.body.addEventListener(BIBLE.SHOW_NOTE, function(event) {
			that.codexView.showFootnote(event.detail.id);
		});
		document.body.addEventListener(BIBLE.HIDE_NOTE, function(event) {
			that.codexView.hideFootnote(event.detail.id);
		});
	});
	function initDatabase(callback) {
		that.database.smokeTest(function(databaseOK) {
			if (databaseOK) {
				console.log('database passed smoke test');
				fillFromDatabase(function() {
					callback();
				});
			} else {
				console.log('attempt download');
				console.log('download', that.versionCode);
				var downloader = new FileDownloader('72.2.112.243', '8080');
				downloader.download(that.versionCode, function(result) {
					if (result instanceof IOError) {
						window.alert('Unable to load Bible');
						callback();
					} else {
						console.log('download succeeded');
						that.database.refreshOpen();
						fillFromDatabase(function() {
							callback();
						});
					}
				});
			}
		});
	}
	function fillFromDatabase(callback) {
		that.tableContents.fill(function() {
			that.history.fill(function() {
				callback();
			});
		});
	}
};
