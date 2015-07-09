/**
* This class holds the table of contents data each book of the Bible, or whatever books were loaded.
*/
function TOCBook(code, heading, title, name, abbrev, lastChapter, priorBook, nextBook) {
	this.code = code;
	this.heading = heading;
	this.title = title;
	this.name = name;
	this.abbrev = abbrev;
	this.lastChapter = lastChapter;
	this.priorBook = priorBook;
	this.nextBook = nextBook;
	if (lastChapter) {
		Object.freeze(this);
	} else {
		Object.seal(this);
	}
}