/**
* This class iterates over the USX data model, and breaks it into files one for each chapter.
*
*/
function ChapterBuilder(collection) {
	this.collection = collection;
	this.chapters = [];
	Object.seal(this);
}
ChapterBuilder.prototype.readBook = function(usxRoot) {
	var that = this;
	var bookCode = null;
	var chapterNum = 0;
	var oneChapter = new USX({ version: 2.0 });
	for (var i=0; i<usxRoot.children.length; i++) {
		var childNode = usxRoot.children[i];
		switch(childNode.tagName) {
			case 'book':
				bookCode = childNode.code;
				break;
			case 'chapter':
				this.chapters.push({bookCode: bookCode, chapterNum: chapterNum, usxTree: oneChapter});
				oneChapter = new USX({ version: 2.0 });
				chapterNum = childNode.number;
				break;
		}
		oneChapter.addChild(childNode);
	}
	this.chapters.push({bookCode: bookCode, chapterNum: chapterNum, usxTree: oneChapter});
};
ChapterBuilder.prototype.loadDB = function(callback) {
	var array = [];
	for (var i=0; i<this.chapters.length; i++) {
		var chapObj = this.chapters[i];
		var xml = chapObj.usxTree.toUSX();
		var domBuilder = new DOMBuilder();
		var dom = domBuilder.toDOM(chapObj.usxTree);
		var htmlBuilder = new HTMLBuilder();
		var html = htmlBuilder.toHTML(dom);
		var values = [ chapObj.bookCode, chapObj.chapterNum, xml, html ];
		array.push(values);
	}
	this.collection.load(array, function(err) {
		if (err instanceof IOError) {
			console.log('Storing chapters failed');
			callback(err);
		} else {
			console.log('store chapters success');
			callback();
		}
	});	
};
