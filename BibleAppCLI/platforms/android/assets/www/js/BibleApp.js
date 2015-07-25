"use strict";
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
	this.history = new History(this.database.history);
	var that = this;
	fillFromDatabase(function() {

		console.log('loaded toc', that.tableContents.size());
		console.log('loaded history', that.history.size());
		
		that.tableContentsView = new TableContentsView(that.tableContents);
		that.lookup = new Lookup(that.tableContents);
		that.statusBar = new StatusBarView(that.tableContents);
		that.statusBar.showView();
		that.searchView = new SearchView(that.tableContents, that.concordance, that.database.verses, that.history);
		that.codexView = new CodexView(that.database.chapters, that.tableContents, that.statusBar.barHite);
		that.historyView = new HistoryView(that.history, that.tableContents);
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
			that.historyView.showView();
			break;
		case 'QuestionsView':
			that.questionsView.showView();
			break;
		default:
			var lastItem = that.history.last();
			console.log('LastItem', JSON.stringify(lastItem));
			if (that.tableContents.size() > 0) {
				that.codexView.showView(lastItem.nodeId);
			} else {
				window.alert('There is no Bible present');
			}
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
		document.body.addEventListener(BIBLE.SHOW_NOTE, function(event) {
			that.codexView.showFootnote(event.detail.id);
		});
		document.body.addEventListener(BIBLE.HIDE_NOTE, function(event) {
			that.codexView.hideFootnote(event.detail.id);
		});
	});
	document.body.addEventListener(BIBLE.CHG_HEADING, function(event) {
		console.log('caught set title event', JSON.stringify(event.detail.reference.nodeId));
		that.statusBar.setTitle(event.detail.reference);
	});
	function fillFromDatabase(callback) {
		that.tableContents.fill(function() {
			that.history.fill(function() {
				callback();
			});
		});
	}
};
/**
* This class contains user interface features for the display of the Bible text
*/
var CODEX_VIEW = { MAX: 10, SCROLL_TIMEOUT: 100 };

function CodexView(chaptersAdapter, tableContents, statusBarHeight) {
	this.chaptersAdapter = chaptersAdapter;
	this.tableContents = tableContents;
	this.statusBarHeight = statusBarHeight;
	this.rootNode = document.getElementById('codexRoot');
	this.currentNodeId = null;
	this.checkScrollID = null;
	Object.seal(this);
}
CodexView.prototype.hideView = function() {
	window.clearTimeout(this.checkScrollID);
	for (var i=this.rootNode.children.length -1; i>=0; i--) {
		this.rootNode.removeChild(this.rootNode.children[i]);
	}
};
CodexView.prototype.showView = function(nodeId) {
	var chapterQueue = [];
	var firstChapter = new Reference(nodeId);
	firstChapter = this.tableContents.ensureChapter(firstChapter);
	document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: firstChapter }}));
	var chapter = firstChapter;
	for (var i=0; i<3 && chapter; i++) {
		chapter = this.tableContents.priorChapter(chapter);
		if (chapter) {
			chapterQueue.unshift(chapter);
		}
	}
	chapterQueue.push(firstChapter);
	chapter = firstChapter;
	for (i=0; i<3 && chapter; i++) {
		chapter = this.tableContents.nextChapter(chapter);
		if (chapter) {
			chapterQueue.push(chapter);
		}
	}
	var that = this;
	this.showChapters(chapterQueue, true, function(results) {
		that.scrollTo(firstChapter);
		that.currentNodeId = firstChapter.nodeId;
		that.checkScrollID = window.setTimeout(onScrollHandler, CODEX_VIEW.SCROLL_TIMEOUT);
	});

	function onScrollHandler(event) {
		var ref = identifyCurrentChapter();//expensive solution
		if (ref && ref.nodeId !== that.currentNodeId) {
			that.currentNodeId = ref.nodeId;
			document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_HEADING, { detail: { reference: ref }}));
		}
		if (document.body.scrollHeight - window.scrollY <= 2 * window.innerHeight) {
			var lastNode = that.rootNode.lastChild;
			var lastChapter = new Reference(lastNode.id.substr(3));
			var nextChapter = that.tableContents.nextChapter(lastChapter);
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
			var firstNode = that.rootNode.firstChild;
			var firstChapter = new Reference(firstNode.id.substr(3));
			var beforeChapter = that.tableContents.priorChapter(firstChapter);
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
	}
	function identifyCurrentChapter() {
		var half = window.innerHeight / 2;
		for (var i=that.rootNode.children.length -1; i>=0; i--) {
			var node = that.rootNode.children[i];
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
	if (this.rootNode.children.length > CODEX_VIEW.MAX) {
		switch(whichEnd) {
			case 'top':
				var discard = this.rootNode.firstChild;
				var offsetHeight = discard.offsetHeight;
				this.rootNode.removeChild(discard);
				// Scroll the offset of the removed element to stay in the same place.
				window.scrollBy(0, - offsetHeight);
				break;
			case 'bottom':
				discard = this.rootNode.lastChild;
				this.rootNode.removeChild(discard);
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
/**
* This class provides the user interface to display history as tabs,
* and to respond to user interaction with those tabs.
*/

function HistoryView(history, tableContents) {
	this.history = history;
	this.tableContents = tableContents;
	this.viewRoot = null;
	this.rootNode = document.getElementById('historyRoot');
	Object.seal(this);
}
HistoryView.prototype.showView = function() {
	if (this.viewRoot) {
	 	if (! this.history.isViewCurrent) {
			this.rootNode.removeChild(this.viewRoot);
			this.viewRoot = this.buildHistoryView();
		}
	} else {
		this.viewRoot = this.buildHistoryView();
	}
	this.history.isViewCurrent = true;
	this.rootNode.appendChild(this.viewRoot);
	TweenLite.to(this.rootNode, 2, { left: "0px" });
};
HistoryView.prototype.hideView = function() {
	var rect = this.rootNode.getBoundingClientRect();
	if (rect.left > -150) {
		TweenLite.to(this.rootNode, 2, { left: "-150px" });
	}
};
HistoryView.prototype.buildHistoryView = function() {
	var that = this;
	var root = document.createElement('ul');
	root.setAttribute('id', 'historyTabBar');
	var numHistory = this.history.size();
	for (var i=numHistory -1; i>=0; i--) {
		var historyNodeId = this.history.items[i].nodeId;
		var tab = document.createElement('li');
		tab.setAttribute('class', 'historyTab');
		root.appendChild(tab);

		var btn = document.createElement('button');
		btn.setAttribute('id', 'his' + historyNodeId);
		btn.setAttribute('class', 'historyTabBtn');
		btn.innerHTML = generateReference(historyNodeId);
		tab.appendChild(btn);
		btn.addEventListener('click', function(event) {
			console.log('btn is clicked ', btn.innerHTML);
			var nodeId = this.id.substr(3);
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId }}));
			that.hideView();
		});
	}
	return(root);

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
function QuestionsView(questionsAdapter, versesAdapter, tableContents) {
	this.tableContents = tableContents;
	this.questions = new Questions(questionsAdapter, versesAdapter, tableContents);
	this.viewRoot = null;
	this.rootNode = document.getElementById('questionsRoot');
	this.referenceInput = null;
	this.questionInput = null;
	Object.seal(this);
}
QuestionsView.prototype.showView = function() {
	var that = this;
	this.hideView();
	this.questions.fill(function(results) {
		if (results instanceof IOError) {
			console.log('QuestionView.showView');
		} else {
			if (results.length === 0) {
				that.questions.createActs8Question(function(item) {
					that.questions.items.push(item);
					that.questions.insert(item, function(err) {
						that.questions.update(item, function(err) {
							presentView();
						});
					});
				});
			} else {
				presentView();
			}
		}
	});
	function presentView() {
		that.viewRoot = that.buildQuestionsView();
		that.rootNode.appendChild(that.viewRoot);

		that.questions.checkServer(function(results) {
			//that.appendToQuestionView();
			// when a question comes back from the server
			// we are able to display input block.
		});		
	}
};
QuestionsView.prototype.hideView = function() {
	for (var i=this.rootNode.children.length -1; i>=0; i--) {
		this.rootNode.removeChild(this.rootNode.children[i]);
	}
	this.viewRoot = null;
};
QuestionsView.prototype.buildQuestionsView = function() {
	var that = this;
	var formatter = new DateTimeFormatter();
	var root = document.createElement('div');
	root.setAttribute('id', 'questionsView');
	var numQuestions = this.questions.size();
	for (var i=0; i<numQuestions; i++) {
		buildOneQuestion(root, i);
	}
	includeInputBlock(root);
	return(root);

	function buildOneQuestion(parent, i) {
		var item = that.questions.find(i);

		var aQuestion = document.createElement('div');
		aQuestion.setAttribute('id', 'que' + i);
		aQuestion.setAttribute('class', 'oneQuestion');
		parent.appendChild(aQuestion);

		var line1 = document.createElement('div');
		line1.setAttribute('class', 'queTop');
		aQuestion.appendChild(line1);

		var reference = document.createElement('p');
		reference.setAttribute('class', 'queRef');
		reference.textContent = item.displayRef;
		line1.appendChild(reference);

		var questDate = document.createElement('p');
		questDate.setAttribute('class', 'queDate');
		questDate.textContent = formatter.localDatetime(item.askedDateTime);
		line1.appendChild(questDate);

		var question = document.createElement('p');
		question.setAttribute('class', 'queText');
		question.textContent = item.question;
		aQuestion.appendChild(question);

		if (i === numQuestions -1) {
			displayAnswer(aQuestion);
		} else {
			aQuestion.addEventListener('click', displayAnswerOnRequest);	
		}
	}

	function displayAnswerOnRequest(event) {
		var selected = document.getElementById(this.id);
		selected.removeEventListener('click', displayAnswerOnRequest);
		displayAnswer(selected);
	}

	function displayAnswer(selected) {
		var idNum = selected.id.substr(3);
		var item = that.questions.find(idNum);

		var line = document.createElement('hr');
		line.setAttribute('class', 'ansLine');
		selected.appendChild(line);

		var answerTop = document.createElement('div');
		answerTop.setAttribute('class', 'ansTop');
		selected.appendChild(answerTop);

		var instructor = document.createElement('p');
		instructor.setAttribute('class', 'ansInstructor');
		instructor.textContent = item.instructor;
		answerTop.appendChild(instructor);

		var ansDate = document.createElement('p');
		ansDate.setAttribute('class', 'ansDate');
		ansDate.textContent = formatter.localDatetime(item.answerDateTime);
		answerTop.appendChild(ansDate);

		var answer = document.createElement('p');
		answer.setAttribute('class', 'ansText');
		answer.textContent = item.answer;
		selected.appendChild(answer);
	}

	function includeInputBlock(parentNode) {
		var inputTop = document.createElement('div');
		inputTop.setAttribute('id', 'quesInput');
		parentNode.appendChild(inputTop);

		that.referenceInput = document.createElement('input');
		that.referenceInput.setAttribute('id', 'inputRef');
		that.referenceInput.setAttribute('type', 'text');
		that.referenceInput.setAttribute('value', 'reference goes here');// How does reference get here
		inputTop.appendChild(that.referenceInput);

		that.questionInput = document.createElement('textarea');
		that.questionInput.setAttribute('id', 'inputText');
		that.questionInput.textContent = 'Matt 7:7 goes here';//Matt 7:7 text goes here
		that.questionInput.setAttribute('rows', 10);
		inputTop.appendChild(that.questionInput);

		var quesBtn = document.createElement('button');
		quesBtn.setAttribute('id', 'inputBtn');
		inputTop.appendChild(quesBtn);
		quesBtn.appendChild(drawSendIcon(50, '#777777'));

		quesBtn.addEventListener('click', function(event) {
			console.log('submit button clicked');

			var item = new QuestionItem();
			// set book, chapter, verse by position of page
			item.displayRef = that.referenceInput.textContent;
			item.question = that.questionInput.text;

			that.questions.addItem(item, function(result) {
				console.log('file is written to disk and server');
			});
		});
	}
};/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
function SearchView(toc, concordance, versesAdapter, history) {
	this.toc = toc;
	this.concordance = concordance;
	this.versesAdapter = versesAdapter;
	this.history = history;
	this.query = '';
	this.words = [];
	this.bookList = {};
	this.viewRoot = null;
	this.rootNode = document.getElementById('searchRoot');
	this.scrollPosition = 0;
	Object.seal(this);
}
SearchView.prototype.showView = function(query) {
	this.hideView();
	if (query) {
		console.log('Create new search page');
		this.showSearch(query);
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, 0);
	} else if (this.viewRoot) {
		console.log('Reattach existing search page');
		this.rootNode.appendChild(this.viewRoot);
		window.scrollTo(10, this.scrollPosition);
	} else {
		var lastSearch = this.history.lastConcordanceSearch();
		if (lastSearch && lastSearch.length > 0) { // check trim also
			document.body.dispatchEvent(new CustomEvent(BIBLE.SEARCH_START, { detail: { search: lastSearch }}));
		} else {
			console.log('Nothing to search for, display blank page');
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
	var that = this;
	this.viewRoot = document.createElement('div');
	this.query = query;
	this.words = query.split(' ');
	this.concordance.search(this.words, function(refList) {
		if (refList instanceof IOError) {
			// Error should display some kind of icon to represent error.
		} else {
			that.bookList = refListsByBook(refList);
			var selectList = selectListWithLimit(that.bookList);
			that.versesAdapter.getVerses(selectList, function(results) {
				if (results instanceof IOError) {
					// Error should display some kind of error icon
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
						that.appendReference(bookNode, reference, verseText);
					}
				}
			});
		}
	});
	function refListsByBook(refList) {
		var bookList = {};
		for (var i=0; i<refList.length; i++) {
			var bookCode = refList[i].substr(0, 3);
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
SearchView.prototype.appendReference = function(bookNode, reference, verseText) {
	var that = this;
	var entryNode = document.createElement('p');
	bookNode.appendChild(entryNode);
	var refNode = document.createElement('span');
	refNode.setAttribute('class', 'conRef');
	refNode.textContent = reference.chapterVerse();
	entryNode.appendChild(refNode);
	entryNode.appendChild(document.createElement('br'));

	var verseNode = document.createElement('span');
	verseNode.setAttribute('id', 'con' + reference.nodeId);
	verseNode.setAttribute('class', 'conVerse');
	verseNode.innerHTML = styleSearchWords(verseText);
	entryNode.appendChild(verseNode);
	verseNode.addEventListener('click', function(event) {
		var nodeId = this.id.substr(3);
		console.log('open chapter', nodeId);
		that.hideView();
		document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId, source: that.query }}));
	});

	function styleSearchWords(verseText) {
		var verseWords = verseText.split(/\b/); // Non-destructive, preserves all characters
		var searchWords = verseWords.map(function(wrd) {
			return(wrd.toLocaleLowerCase());
		});
		for (var i=0; i<that.words.length; i++) {
			var word = that.words[i];
			var wordNum = searchWords.indexOf(word.toLocaleLowerCase());
			if (wordNum >= 0) {
				verseWords[wordNum] = '<span class="conWord">' + verseWords[wordNum] + '</span>';
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
	entryNode.textContent = '...';
	bookNode.appendChild(entryNode);
	entryNode.addEventListener('click', function(event) {
		var moreNode = document.getElementById(this.id);
		var parentNode = moreNode.parentNode;
		parentNode.removeChild(moreNode);

		var bookCode = this.id.substr(3);
		var bookNode = document.getElementById('con' + bookCode);
		var refList = that.bookList[bookCode];

		that.versesAdapter.getVerses(refList, function(results) {
			if (results instanceof IOError) {
				// display some error graphic?
			} else {
				for (var i=3; i<results.rows.length; i++) {
					var row = results.rows.item(i);
					var nodeId = row.reference;
					var verseText = row.html;
					var reference = new Reference(nodeId);
					that.appendReference(bookNode, reference, verseText);
				}
			}
		});
	});
};
/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
var STATUS_BAR_BUTTON_HEIGHT = 44;
var STATUS_BAR_HEIGHT = 62; // ios

function StatusBarView(tableContents) {
	this.hite = STATUS_BAR_BUTTON_HEIGHT;
	this.barHite = STATUS_BAR_HEIGHT;
	this.tableContents = tableContents;
	this.titleWidth = window.innerWidth - this.hite * 3.5;
	this.titleCanvas = null;
	this.titleGraphics = null;
	this.currentReference = null;
	this.searchField = null;
	this.rootNode = document.getElementById('statusRoot');
	this.labelCell = document.getElementById('labelCell');
	Object.seal(this);
}
StatusBarView.prototype.showView = function() {
	var that = this;
	setupBackground(this.hite);
	setupTocButton(this.hite, '#F7F7BB');
	setupHeading(this.hite);
	setupQuestionsButton(this.hite, '#F7F7BB');
	setupSearchButton(this.hite, '#F7F7BB');

	function setupBackground(hite) {
    	var canvas = document.createElement('canvas');
    	canvas.setAttribute('height', STATUS_BAR_HEIGHT);
    	var maxSize = (window.innerHeight > window.innerWidth) ? window.innerHeight : window.innerWidth;
    	canvas.setAttribute('width', maxSize);
    	canvas.setAttribute('style', 'position: absolute; top: 0; z-index: -1');
      	var graphics = canvas.getContext('2d');
      	graphics.rect(0, 0, canvas.width, canvas.height);

      	// create radial gradient
      	var vMidpoint = hite / 2;
      	var gradient = graphics.createRadialGradient(238, vMidpoint, 10, 238, vMidpoint, window.innerHeight - hite);
      	// light blue
      	gradient.addColorStop(0, '#8ED6FF');
      	// dark blue
      	gradient.addColorStop(1, '#004CB3');

      	graphics.fillStyle = gradient;
      	graphics.fill();
      	that.rootNode.appendChild(canvas);
	}
	function setupTocButton(hite, color) {
		var canvas = drawTOCIcon(hite, color);
		canvas.setAttribute('style', 'position: fixed; top: 14px; left: 0');
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
		that.titleCanvas.setAttribute('style', 'position: fixed; top: 14px; left:' + hite * 1.1 + 'px');

		that.titleGraphics = that.titleCanvas.getContext('2d');
		that.titleGraphics.fillStyle = '#000000';
		that.titleGraphics.font = '24pt sans-serif';
		that.titleGraphics.textAlign = 'center';
		that.titleGraphics.textBaseline = 'middle';
		that.titleGraphics.borderStyle = 'solid';

		that.labelCell.appendChild(that.titleCanvas);
		that.titleCanvas.addEventListener('click', function(event) {
			if (that.currentReference) {
				console.log('title bar click', that.currentReference.nodeId);
				document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: that.currentReference.nodeId }}));
			}
		});
	}
	function setupSearchButton(hite, color) {
		var canvas = drawSearchIcon(hite, color);
		canvas.setAttribute('style', 'position: fixed; top: 14px; right: 0; border: none');
		document.getElementById('searchCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('search button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_SEARCH));
		});
	}
	function setupQuestionsButton(hite, color) {
		var canvas = drawQuestionsIcon(hite, color);
		canvas.setAttribute('style', 'position: fixed; top: 14px; border: none; right: ' + hite * 1.14 + 'px');
		document.getElementById('questionsCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('questions button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_QUESTIONS));
		});
	}
};
StatusBarView.prototype.setTitle = function(reference) {
	this.currentReference = reference;
	var book = this.tableContents.find(reference.book);
	var text = book.name + ' ' + ((reference.chapter > 0) ? reference.chapter : 1);
	this.titleGraphics.clearRect(0, 0, this.titleWidth, this.hite);
	this.titleGraphics.fillText(text, this.titleWidth / 2, this.hite / 2, this.titleWidth);
};
StatusBarView.prototype.showSearchField = function(query) {
	if (! this.searchField) {
		this.searchField = document.createElement('input');
		this.searchField.setAttribute('type', 'text');
		this.searchField.setAttribute('class', 'searchField');
		this.searchField.setAttribute('value', query);
		var yPos = (this.hite - 40) / 2; // The 40 in this calculation is a hack.
		var xPos = (this.hite * 1.2);
		this.searchField.setAttribute('style', 'position: fixed; top: ' + yPos + 'px; left: ' + xPos + 'px');
		var that = this;
		this.searchField.addEventListener('keyup', function(event) {
			if (event.keyCode === 13) {
				document.body.dispatchEvent(new CustomEvent(BIBLE.SEARCH_START, { detail: { search: that.searchField.value }}));

			}
		});
	}
	this.changeLabelCell(this.searchField);
};
StatusBarView.prototype.showTitleField = function() {
	this.changeLabelCell(this.titleCanvas);
};
StatusBarView.prototype.changeLabelCell = function(node) {
	for (var i=this.labelCell.children.length -1; i>=0; i--) {
		this.labelCell.removeChild(this.labelCell.children[i]);
	}
	this.labelCell.appendChild(node);
};
/**
* This class presents the table of contents, and responds to user actions.
*/
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
	document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId }}));
};


/**
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
}/**
* This class is a wrapper for SQL Error so that we can always distinguish an error
* from valid results.  Any method that calls an IO routine, which can expect valid results
* or an error should test "if (results instanceof IOError)".
*/
function IOError(err) {
	this.code = err.code;
	this.message = err.message;
}
/**
* This class is a facade over the database that is used to store bible text, concordance,
* table of contents, history and questions.
*/
function DeviceDatabase(code) {
	this.code = code;
    this.className = 'DeviceDatabase';
	var size = 30 * 1024 * 1024;
    if (window.sqlitePlugin === undefined) {
        console.log('opening WEB SQL Database, stores in Cache');
        this.database = window.openDatabase(this.code, "1.0", this.code, size);
    } else {
        console.log('opening SQLitePlugin Database, stores in Documents with no cloud');
        this.database = window.sqlitePlugin.openDatabase({name: this.code, location: 2, createFromLocation: 1});
    }
	this.chapters = new ChaptersAdapter(this);
    this.verses = new VersesAdapter(this);
	this.tableContents = new TableContentsAdapter(this);
	this.concordance = new ConcordanceAdapter(this);
	this.styleIndex = new StyleIndexAdapter(this);
	this.styleUse = new StyleUseAdapter(this);
	this.history = new HistoryAdapter(this);
	this.questions = new QuestionsAdapter(this);
	Object.seal(this);
}
DeviceDatabase.prototype.select = function(statement, values, callback) {
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
DeviceDatabase.prototype.executeDML = function(statement, values, callback) {
    this.database.transaction(onTranStart, onTranError);

    function onTranStart(tx) {
        console.log('exec tran start', statement, values);
        tx.executeSql(statement, values, onExecSuccess);
    }
    function onTranError(err) {
        console.log('execute tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onExecSuccess(tx, results) {
    	console.log('excute sql success', results.rowsAffected);
    	callback(results.rowsAffected);
    }
};
DeviceDatabase.prototype.bulkExecuteDML = function(statement, array, callback) {
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
DeviceDatabase.prototype.executeDDL = function(statement, callback) {
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
/** A smoke test is needed before a database is opened. */
/** A second more though test is needed after a database is opened.*/
DeviceDatabase.prototype.smokeTest = function(callback) {
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
	var that = this;
	var numValues = values.length || 0;
	var array = [numValues];
	for (var i=0; i<numValues; i++) {
		array[i] = '?';
	}
	var statement = 'select reference, html from chapters where reference in (' + array.join(',') + ') order by rowid';
	this.database.select(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('found Error', results);
			callback(results);
		} else {
			callback(results);
        }
	});
};/**
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
    	'refList text not null)';
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
	var statement = 'insert into concordance(word, refCount, refList) values (?,?,?)';
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
		'nextBook text null)';
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
	var statement = 'insert into tableContents(code, heading, title, name, abbrev, lastChapter, priorBook, nextBook) ' +
		'values (?,?,?,?,?,?,?,?)';
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
	var statement = 'select code, heading, title, name, abbrev, lastChapter, priorBook, nextBook ' +
		'from tableContents order by rowid';
	this.database.select(statement, [], function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				var tocBook = new TOCBook(row.code, row.heading, row.title, row.name, row.abbrev, 
					row.lastChapter, row.priorBook, row.nextBook);
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
	Object.freeze(this);
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
		'book text not null, ' +
		'chapter integer not null, ' +
		'verse integer null, ' +
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
HistoryAdapter.prototype.selectAll = function(callback) {
	var statement = 'select timestamp, book, chapter, verse, source, search ' +
		'from history order by timestamp desc limit ?';
	this.database.select(statement, [ MAX_HISTORY ], function(results) {
		if (results instanceof IOError) {
			console.log('HistoryAdapter.selectAll Error', JSON.stringify(results));
			callback(results);
		} else {
			console.log('HistoryAdapter.selectAll Success, rows=', results.rows.length);
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				var ref = new Reference(row.book, row.chapter, row.verse);
				var hist = new HistoryItem(ref.nodeId, row.source, row.search, row.timestamp);
				array.push(hist);
			}
			callback(array);
		}
	});
};
HistoryAdapter.prototype.replace = function(item, callback) {
	var timestampStr = item.timestamp.toISOString();
	var ref = new Reference(item.nodeId);
	var values = [ timestampStr, ref.book, ref.chapter, ref.verse, item.source, item.search ];
	var statement = 'replace into history(timestamp, book, chapter, verse, source, search) ' +
		'values (?,?,?,?,?,?)';
	this.database.executeDML(statement, values, function(count) {
		if (count instanceof IOError) {
			console.log('replace error', JSON.stringify(count));
			callback(count);
		} else {
			callback(count);
		}
	});
};
HistoryAdapter.prototype.delete = function(values, callback) {
	// Will be needed to prevent growth of history
	callback();
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
		'book text not null, ' +
		'chapter integer not null, ' +
		'verse integer null, ' +
		'displayRef text null, ' +
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
	var statement = 'select book, chapter, verse, displayRef, question, askedDateTime, instructor, answerDateTime, answer ' +
		'from questions order by askedDateTime';
	this.database.select(statement, [], function(results) {
		if (results instanceof IOError) {
			console.log('select questions failure ' + JSON.stringify(results));
			callback(results);
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				var ques = new QuestionItem(row.book, row.chapter, row.verse, row.displayRef, row.question, 
					row.askedDt, row.instructor, row.answerDt, row.answer);
				array.push(ques);
			}
			callback(array);
		}
	});
};
QuestionsAdapter.prototype.replace = function(item, callback) {
	var statement = 'replace into questions(book, chapter, verse, displayRef, question, askedDateTime) ' +
		'values (?,?,?,?,?,?)';
	var values = [ item.book, item.chapter, item.verse, item.displayRef, item.question, item.askedDateTime.toISOString() ];
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
* This class encapsulates the Cordova FileTransfer plugin for file download
* It is a simple plugin, but encapsulated here in order to make it easy to change
* the implementation.
*
* 'persistent' will store the file in 'Documents' in Android and 'Library' in iOS
* 'LocalDatabase' is the file under Library where the database is expected.
*/
function FileDownloader(host, port) {
	this.fileTransfer = new FileTransfer();
	this.uri = encodeURI('http://' + host + ':' + port + '/down/');
	this.basePath = 'cdvfile://localhost/persistent/';
}
FileDownloader.prototype.download = function(bibleVersion, callback) {
	var remotePath = this.uri + bibleVersion;
	//if (device === 'ios') {
		var filePath = this.basePath + '../LocalDatabase/' + bibleVersion;
	//} else {
	//	filePath = this.basePath + bibleVersion;
	//}
	console.log('download to', filePath);
    this.fileTransfer.download(remotePath, filePath, onDownSuccess, onDownError, true, {});

    function onDownSuccess(entry) {
    	console.log("download complete: ", JSON.stringify(entry));
       	callback(entry);   	
    }
    function onDownError(error) {
    	console.log("download error source " + error.source);
      	console.log("download error target " + error.target);
       	console.log("download error code" + error.code);
       	callback(new IOError({ code: error.code, message: error.source}));   	
    }
};/**
* This class iterates over the USX data model, and translates the contents to DOM.
*
* This method generates a DOM tree that has exactly the same parentage as the USX model.
* This is probably a problem.  The easy insertion and deletion of nodes probably requires
* having a hierarchy of books and chapters. GNG April 13, 2015
*
* NOTE: This class must be instantiated once for an entire book are all books, not just one chapter,
* because the bookCode is only present in chapter 0, but is needed by all chapters.
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
* This class handles all request to deliver scripture.  It handles all passage display requests to display passages of text,
* and it also handles all requests from concordance search requests to display individual verses.
* It will deliver the content from cache if it is present.  Or, it will find the content in persistent storage if it is
* not present in cache.  All content retrieved from persistent storage is added to the cache.
*
* On May 3, 2015 some performance checks were done.  The time measurements where from a sample of 4, the memory from a sample of 1.
* 1) Read Chapter 11.2ms, 49K heap increase
* 2) Parse USX 6.0ms, 306K heap increase
* 3) Generate Dom 2.16ms, 85K heap increase
* These tests were done when IO was file.
*
* On Jul 21, 2015 some performance checks were done using SQLite as the datastore.
* 1) Read Chapter 4.4 ms, 4K heap increase
* 2) Parse USX 1.8 ms, still large heap increase
* 3) Generate Dom  1ms, still large heap increase
*
* On Jul 22, 2015 stored HTML in DB and changed to use that so there is less App processing
* 1) Read Chapter 2.0 ms
* 2) Assign using innerHTML 0.5 ms
* 3) Append 0.13 ms
*
* This class does not yet have a means to remove old entries from cache.  
* It is possible that DB access is fast enough, and this is not needed.
* GNG July 5, 2015
*/
function BibleCache(adapter) {
	this.adapter = adapter;
	this.chapterMap = {};
	this.parser = new USXParser();
	Object.freeze(this);
}
/** deprecated */
BibleCache.prototype.getChapterHTML = function(reference, callback) {
	var that = this;
	var chapter = this.chapterMap[reference.nodeId];
	if (chapter !== undefined) {
		callback(chapter);
	} else {
		this.adapter.getChapterHTML(reference, function(chapter) {
			if (chapter instanceof IOError) {
				console.log('Bible Cache found Error', chapter);
				callback(chapter);
			} else {
				that.chapterMap[reference.nodeId] = chapter;
				callback(chapter);
			}
		});
	}
};

// Before deleting be sure to move performance nots to CodexView


/**
* This class contains the Canon of Scripture as 66 books.  It is used to control
* which books are published using this App.  The codes are used to identify the
* books of the Bible, while the names, which are in English are only used to document
* the meaning of each code.  These names are not used for display in the App.
*/
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
* This class holds the concordance of the entire Bible, or whatever part of the Bible was available.
*/
function Concordance(adapter) {
	this.adapter = adapter;
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
/**
* This class manages a queue of history items up to some maximum number of items.
* It adds items when there is an event, such as a toc click, a search lookup,
* or a concordance search.  It also responds to function requests to go back 
* in history, forward in history, or return to the last event.
*/
function History(adapter) {
	this.adapter = adapter;
	this.items = [];
	this.isFilled = false;
	this.isViewCurrent = false;
	Object.seal(this);
}
History.prototype.fill = function(callback) {
	var that = this;
	this.items.splice(0);
	this.adapter.selectAll(function(results) {
		if (results instanceof IOError) {
			console.log('History.fill Error', JSON.stringify(results));
			callback(results);
		} else {
			console.log('History.fill Success, rows=', results.length);
			that.items = results;
			that.isFilled = true;
			that.isViewCurrent = false;
			callback();
		}
	});
};
History.prototype.addEvent = function(event) {
	var itemIndex = this.search(event.detail.id);
	if (itemIndex >= 0) {
		this.items.splice(itemIndex, 1);
	}
	var item = new HistoryItem(event.detail.id, event.type, event.detail.source);
	this.items.push(item);
	if (this.items.length > MAX_HISTORY) {
		var discard = this.items.shift();
	}
	this.isViewCurrent = false;
	
	// I might want a timeout to postpone this until after animation is finished.
	this.adapter.replace(item, function(err) {
		if (err instanceof IOError) {
			console.log('replace error', JSON.stringify(err));
		}
	});
};
History.prototype.search = function(nodeId) {
	for (var i=0; i<this.items.length; i++) {
		var item = this.items[i];
		if (item.nodeId === nodeId) {
			return(i);
		}
	}
	return(-1);
};
History.prototype.size = function() {
	return(this.items.length);
};
History.prototype.last = function() {
	return(this.item(this.items.length -1));
};
History.prototype.item = function(index) {
	return((index > -1 && index < this.items.length) ? this.items[index] : new HistoryItem('JHN:1'));
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
History.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};

/**
* This class contains the details of a single history event, such as
* clicking on the toc to get a chapter, doing a lookup of a specific passage
* or clicking on a verse during a concordance search.
*/
function HistoryItem(nodeId, source, search, timestamp) {
	this.nodeId = nodeId;
	this.source = source;
	this.search = search;
	this.timestamp = (timestamp) ? new Date(timestamp) : new Date();
	Object.freeze(this);
}/**
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
function QuestionItem(book, chapter, verse, displayRef, question, askedDt, instructor, answerDt, answer) {
	this.book = book;
	this.chapter = chapter;
	this.verse = verse;
	this.displayRef = displayRef;
	this.question = question;
	this.askedDateTime = (askedDt) ? new Date(askedDt) : new Date();
	this.instructor = instructor;
	this.answerDateTime = (answerDt) ? new Date(answerDt) : null;
	this.answer = answer;
	Object.seal(this);
}/**
* This class contains the list of questions and answers for this student
* or device.
*/
function Questions(questionsAdapter, versesAdapter, tableContents) {
	this.questionsAdapter = questionsAdapter;
	this.versesAdapter = versesAdapter;
	this.tableContents = tableContents;
	this.items = [];
	Object.seal(this);
}
Questions.prototype.size = function() {
	return(this.items.length);
};
Questions.prototype.find = function(index) {
	return((index >= 0 && index < this.items.length) ? this.items[index] : null);
};
Questions.prototype.addItem = function(questionItem, callback) {
	this.items.push(questionItem);
	// This method must add to the database, as well as add to the server
	// callback when the addQuestion, either succeeds or fails.
	this.insert(questionItem, function(result) {
		callback(result);
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
Questions.prototype.createActs8Question = function(callback) {
	var acts8 = new QuestionItem();
	acts8.book = 'ACT';
	acts8.chapter = 8;
	acts8.verse = 30;
	acts8.askedDateTime = new Date();
	var refActs830 = new Reference('ACT:8:30');
	acts8.displayRef = this.tableContents.toString(refActs830);
	var verseList = [ 'ACT:8:30', 'ACT:8:31', 'ACT:8:35' ];
	this.versesAdapter.getVerses(verseList, function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else {
			var acts830 = results.rows.item(0);
			var acts831 = results.rows.item(1);
			var acts835 = results.rows.item(2);
			acts8.question = acts830.html + ' ' + acts831.html;
			acts8.answer = acts835.html;
			acts8.instructor = '';
			acts8.answerDateTime = new Date();
			callback(acts8);
		}
	});
};
Questions.prototype.checkServer = function(callback) {
	var that = this;
	var lastItem = this.items[this.items.length -1];
	if (lastItem.answeredDateTime === null) {
		// send request to the server.

		
		if (lastItem.answeredDateTime) { // if updated by server
			that.update(lastItem, function(err) {
				callback();
			});
		} else {
			callback();
		}
	}
	else {
		callback();
	}
};
Questions.prototype.insert = function(item, callback) {
	this.questionsAdapter.replace(item, function(results) {
		if (results instanceof IOError) {
			console.log('Error on Insert');
			callback(results);
		} else {
			callback();
		}
	});
};
Questions.prototype.update = function(item, callback) {
	this.questionsAdapter.update(item, function(results) {
		if (results instanceof IOError) {
			console.log('Error on update', results);
			callback(results);
		} else {
			callback(results);
		}
	});
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
	this.rootNode = document.createElement('div');
	this.rootNode.setAttribute('id', 'top' + this.nodeId);
	Object.freeze(this);
}
Reference.prototype.path = function() {
	return(this.book + '/' + this.chapter + '.usx');
};
Reference.prototype.chapterVerse = function() {
	return((this.verse) ? this.chapter + ':' + this.verse : this.chapter);
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
TOC.prototype.ensureChapter = function(reference) {
	var current = this.bookMap[reference.book];
	if (reference.chapter > current.lastChapter) {
		return(new Reference(reference.book, current.lastChapter, 1));
	}
	if (reference.chapter < 1) {
		return(new Reference(reference.book, 1, 1));
	}
	return(reference);
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
TOC.prototype.toString = function(reference) {
	return(this.find(reference.book).name + ' ' + reference.chapter + ':' + reference.verse);
};
TOC.prototype.toJSON = function() {
	return(JSON.stringify(this.bookList, null, ' '));
};/**
* This class holds the table of contents data each book of the Bible, or whatever books were loaded.
*/
function TOCBook(code, heading, title, name, abbrev, lastChapter, priorBook, nextBook) {
	this.code = code || null;
	this.heading = heading || null;
	this.title = title || null;
	this.name = name || null;
	this.abbrev = abbrev || null;
	this.lastChapter = lastChapter || null;
	this.priorBook = priorBook || null;
	this.nextBook = nextBook || null; // do not want undefined in database
	if (lastChapter) {
		Object.freeze(this);
	} else {
		Object.seal(this);
	}
}/**
* This class contains a book of the Bible
*/
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
* This class contains a character style as parsed from a USX Bible file.
*/
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
* This class contains a Note from a USX parsed Bible
*/
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
* This object contains a paragraph of the Bible text as parsed from a USX version of the Bible.
*/
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
* This class contains a text string as parsed from a USX Bible file.
*/
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
* This class is the root object of a parsed USX document
*/
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
* This chapter contains the verse of a Bible text as parsed from a USX Bible file.
*/
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
* This class reads USX files and creates an equivalent object tree
* elements = [usx, book, chapter, para, verse, note, char];
* paraStyle = [b, d, cl, cp, h, li, p, pc, q, q2, mt, mt2, mt3, mte, toc1, toc2, toc3, ide, ip, ili, ili2, is, m, mi, ms, nb, pi, s, sp];
* charStyle = [add, bk, it, k, fr, fq, fqa, ft, wj, qs, xo, xt];
*/
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
