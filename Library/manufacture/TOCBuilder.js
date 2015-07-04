/**
* This class traverses the USX data model in order to find each book, and chapter
* in order to create a table of contents that is localized to the language of the text.
*/
function TOCBuilder(collection) {
	this.collection = collection;
	this.toc = new TOC(collection);
	this.tocBook = null;
	Object.seal(this);
}
TOCBuilder.prototype.readBook = function(usxRoot) {
	this.readRecursively(usxRoot);
};
TOCBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			var priorBook = null;
			if (this.tocBook) {
				this.tocBook.nextBook = node.code;
				priorBook = this.tocBook.code;
			}
			this.tocBook = new TOCBook(node.code);
			this.tocBook.priorBook = priorBook;
			this.toc.addBook(this.tocBook);
			break;
		case 'chapter':
			this.tocBook.lastChapter = node.number;
			break;
		case 'para':
			switch(node.style) {
				case 'h':
					this.tocBook.heading = node.children[0].text;
					break;
				case 'toc1':
					this.tocBook.title = node.children[0].text;
					break;
				case 'toc2':
					this.tocBook.name = node.children[0].text;
					break;
				case 'toc3':
					this.tocBook.abbrev = node.children[0].text;
					break;
			}
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};
TOCBuilder.prototype.size = function() {
	return(this.toc.bookList.length);
};
TOCBuilder.prototype.schema = function() {
	var sql = 'code text primary key not null, ' +
    	'heading text not null, ' +
    	'title text not null, ' +
    	'name text not null, ' +
    	'abbrev text not null, ' +
		'lastChapter integer not null, ' +
		'priorBook text null, ' +
		'nextBook text null';
	return(sql);
};
TOCBuilder.prototype.loadDB = function(callback) {
	console.log('TOC loadDB records count', this.size());
	var array = [];
	var len = this.size();
	for (var i=0; i<len; i++) {
		var tocBook = this.toc.bookList[i];
		var names = Object.keys(tocBook);
		var values = this.collection.valuesToArray(names, tocBook);
		array.push(values);
	}
	this.collection.load(names, array, function(err) {
		if (err) {
			window.alert('TOC Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('TOC loaded in database');
			callback();
		}
	});
};
TOCBuilder.prototype.toJSON = function() {
	return(this.toc.toJSON());
};