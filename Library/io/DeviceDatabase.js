/**
* This class is a facade over the database that is used to store bible text, concordance,
* table of contents, history and questions.  At this writing, it is a facade over a
* Web SQL Sqlite3 database, but it intended to hide all database API specifics
* from the rest of the application so that a different database can be put in its
* place, if that becomes advisable.
* Gary Griswold, July 2, 2015
*/
function DeviceDatabase(code, name) {
	this.code = code;
	this.name = name;
	var size = 30 * 1024 * 1024;
	this.db = window.openDatabase(this.code, "1.0", this.name, size);
	this.codex = new DeviceCollection(this.db, 'codex');
	this.tableContents = new DeviceCollection(this.db, 'tableContents');
	this.concordance = new DeviceCollection(this.db, 'concordance');
	this.styleIndex = new DeviceCollection(this.db, 'styleIndex');
	this.styleUse = new DeviceCollection(this.db, 'styleUse');
	this.history = new DeviceCollection(this.db, 'history');
	this.questions = new DeviceCollection(this.db, 'questions');
	Object.freeze(this);
}


