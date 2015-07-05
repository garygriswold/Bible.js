/**
* This class iterates over the USX data model, and breaks it into files one for each chapter.
*
*/
function ChapterBuilder(collection) {
	this.collection = collection;
	this.books = [];
	Object.seal(this);
}
ChapterBuilder.prototype.readBook = function(usxRoot) {
	var that = this;
	this.books.push(usxRoot);
};
ChapterBuilder.prototype.schema = function() {
	var sql = 'book text not null, ' +
		'chapter integer not null, ' +
		'xml text not null';
	return(sql);
};
ChapterBuilder.prototype.loadDB = function(callback) {
	var array = [];
	for (var i=0; i<this.books.length; i++) {
		var usxRoot = this.books[i];
		var bookCode = null; // set as a side-effect of breakBookIntoChapters
		var chapters = breakBookIntoChapters(usxRoot);
		for (var j=0; j<chapters.length; j++) {
			var chapter = chapters[j];
			var chapterNum = findChapterNum(chapter);
			var values = [ bookCode, chapterNum, chapter.toUSX() ];
			array.push(values);
		}
	}
	var names = [ 'book', 'chapter', 'xml' ];
	this.collection.load(names, array, function(err) {
		if (err) {
			console.log('Storing chapters failed');
			callback(err);
		} else {
			console.log('store chapters success');
			callback();
		}
	});

	function breakBookIntoChapters(usxRoot) {
		var chapters = [];
		var chapterNum = 0;
		var oneChapter = new USX({ version: 2.0 });
		for (var i=0; i<usxRoot.children.length; i++) {
			var childNode = usxRoot.children[i];
			switch(childNode.tagName) {
				case 'book':
					bookCode = childNode.code;
					break;
				case 'chapter':
					chapters.push(oneChapter);
					oneChapter = new USX({ version: 2.0 });
					chapterNum = childNode.number;
					break;
			}
			oneChapter.addChild(childNode);
		}
		chapters.push(oneChapter);
		return(chapters);
	}
	function findChapterNum(oneChapter) {
		for (var i=0; i<oneChapter.children.length; i++) {
			var child = oneChapter.children[i];
			if (child.tagName === 'chapter') {
				return(child.number);
			}
		}
		return(0);
	}	
};
ChapterBuilder.prototype.toJSON = function() {
	return('');
};

