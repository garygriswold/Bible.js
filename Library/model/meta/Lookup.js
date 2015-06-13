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
