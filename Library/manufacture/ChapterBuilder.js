/**
* This class iterates over the USX data model, and breaks it into files one for each chapter.
*
*/
function ChapterBuilder(location, versionCode) {
	this.location = location;
	this.versionCode = versionCode;
	this.filename = 'chapterMetaData.json';
	Object.seal(this);
};
ChapterBuilder.prototype.readBook = function(usxRoot) {
	var that = this;
	var bookCode = ''; // set by side effect of breakBookIntoChapters
	var chapters = breakBookIntoChapters(usxRoot);

	var reader = new NodeFileReader(this.location);
	var writer = new NodeFileWriter(this.location);

	var oneChapter = chapters.shift();
	var chapterNum = findChapterNum(oneChapter);
	createDirectory(bookCode);

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
	function createDirectory(bookCode) {
		var filepath = getPath(bookCode);
		writer.createDirectory(filepath, function(dirName) {
			if (dirName.errno) {
				writeChapter(bookCode, chapterNum, oneChapter);				
			} else {
				writeChapter(bookCode, chapterNum, oneChapter);	
			}
		});
	}
	function writeChapter(bookCode, chapterNum, oneChapter) {
		var filepath = getPath(bookCode) + '/' + chapterNum + '.usx';
		var data = oneChapter.toUSX();
		writer.writeTextFile(filepath, data, function(filename) {	
			if (filename.errno) {
				console.log('ChapterBuilder.writeChapterFailure ', JSON.stringify(filename));
			} else {
				oneChapter = chapters.shift();
				if (oneChapter) {
					chapterNum = findChapterNum(oneChapter);
					writeChapter(bookCode, chapterNum, oneChapter);
				} else {
					// done
				}
			}
		});
	}
	function getPath(filename) {
		return('usx/' + that.versionCode + '/' + filename);
	}
};
ChapterBuilder.prototype.toJSON = function() {
	//return(JSON.stringify(this.usxRoot));
};

