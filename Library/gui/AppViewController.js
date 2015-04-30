/**
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
"use strict"

var EVENT = { TOC2PASSAGE: 'toc2passage', CON2PASSAGE: 'con2passage' };

function AppViewController(versionCode) {
	this.versionCode = versionCode;
	this.tableContents = new TableContentsView(versionCode);
	this.codex = new CodexView(versionCode);
	this.searchViewBuilder = new SearchViewBuilder(versionCode, this.tableContents.toc, this.codex.bibleCache);

	this.bodyNode = this.tableContents.bodyNode;
	this.bodyNode.addEventListener(EVENT.TOC2PASSAGE, toc2PassageHandler);
	this.bodyNode.addEventListener(EVENT.CON2PASSAGE, con2PassageHandler);
	var that = this;
	Object.freeze(this);

	function toc2PassageHandler(event) {
		var detail = event.detail;
		console.log(JSON.stringify(detail));
		that.codex.showPassage(detail.id);	
	}
	function con2PassageHandler(event) {
		var detail = event.detail;
		console.log(JSON.stringify(detail));
		that.codex.showPassage(detail.id);
	}
};
AppViewController.prototype.begin = function() {
	//this.tableContents.showTocBookList();
	this.tableContents.readTocFile();
	this.searchViewBuilder.showSearch("risen");
};


