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
var SERVER_HOST = 'localhost'; // 72.2.112.243
var SERVER_PORT = '8080'; 

function AppViewController(versionCode) {
	this.versionCode = versionCode;
	this.touch = new Hammer(document.getElementById('codexRoot'));
	this.database = new DeviceDatabase(versionCode);
}
AppViewController.prototype.begin = function(develop) {
	this.tableContents = new TOC(this.database.tableContents);
	this.bibleCache = new BibleCache(this.database.codex);
	this.concordance = new Concordance(this.database.concordance);
	var that = this;
	fillFromDatabase(function() {

		console.log('loaded toc', that.tableContents.size());
		
		that.tableContentsView = new TableContentsView(that.tableContents);
		that.lookup = new Lookup(that.tableContents);
		that.header = new HeaderView(that.tableContents);
		that.header.showView();
		that.searchView = new SearchView(that.tableContents, that.concordance, that.database.verses, that.database.history);
		that.codexView = new CodexView(that.database.chapters, that.tableContents, that.header.barHite);
		that.historyView = new HistoryView(that.database.history, that.tableContents);
		that.questionsView = new QuestionsView(that.database.questions, that.database.verses, that.tableContents);
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
		default:
			that.database.history.lastItem(function(lastItem) {
				if (lastItem instanceof IOError || lastItem === null || lastItem === undefined) {
					that.codexView.showView('JHN:1');
				} else {
					console.log('LastItem', JSON.stringify(lastItem));
					that.codexView.showView(lastItem);
				}
			});
		}
		document.body.addEventListener(BIBLE.SHOW_TOC, function(event) {
			that.tableContentsView.showView();
			that.header.showTitleField();
			that.searchView.hideView();
			that.historyView.hideView(function() {});
			that.questionsView.hideView();
			that.codexView.hideView();
		});
		document.body.addEventListener(BIBLE.SHOW_SEARCH, function(event) {
			that.searchView.showView();
			that.header.showSearchField();
			that.tableContentsView.hideView();
			that.historyView.hideView(function() {});
			that.questionsView.hideView();
			that.codexView.hideView();
		});
		document.body.addEventListener(BIBLE.SHOW_QUESTIONS, function(event) {
			that.questionsView.showView();
			that.header.showTitleField();
			that.tableContentsView.hideView();
			that.searchView.hideView();
			that.historyView.hideView(function() {});
			that.codexView.hideView();			
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
		document.body.addEventListener(BIBLE.SEARCH_START, function(event) {
			console.log('SEARCH_START', event.detail);
			if (! that.lookup.find(event.detail.search)) {
				that.searchView.showView(event.detail.search);
				that.header.showSearchField(event.detail.search);
			}
		});
		document.body.addEventListener(BIBLE.SHOW_PASSAGE, function(event) {
			console.log(JSON.stringify(event.detail));
			that.codexView.showView(event.detail.id);
			that.header.showTitleField();
			that.tableContentsView.hideView();
			that.searchView.hideView();
			var historyItem = { timestamp: new Date(), reference: event.detail.id, 
				source: event.type, search: event.detail.source };
			that.database.history.replace(historyItem, function(count) {});
		});
		document.body.addEventListener(BIBLE.SHOW_NOTE, function(event) {
			that.codexView.showFootnote(event.detail.id);
		});
		document.body.addEventListener(BIBLE.HIDE_NOTE, function(event) {
			that.codexView.hideFootnote(event.detail.id);
		});
	});
	document.body.addEventListener(BIBLE.CHG_HEADING, function(event) {
		console.log('caught set title event', JSON.stringify(event.detail.reference.nodeId));
		that.header.setTitle(event.detail.reference);
	});
	function fillFromDatabase(callback) {
		that.tableContents.fill(function() {
			callback();
		});
	}
};
