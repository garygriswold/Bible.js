/**
* This class loads each of the assets that is specified in the types file.
*
* On May 3, 2015 some performance checks were done
* 1) Toc Read 10.52ms  85.8KB heap increase
* 2) Toc Loaded 1.22ms  322KB heap increase
* 3) Concordance Read 20.99ms  7.695MB heap increase
* 4) Concordance Loaded 96.49ms  27.971MB heap increase
*/
"use strict";

function AssetLoader(types) {
	this.types = types;
	this.toc = new TOC();
	this.concordance = new Concordance();
	this.history = new History(types);
	this.styleIndex = new StyleIndex();
}
AssetLoader.prototype.load = function(callback) {
	var that = this;
	this.types.chapterFiles = false; // do not load this
	var result = new AssetType(that.types.location, that.types.versionCode);
	var reader = new NodeFileReader(that.types.location);
	var toDo = this.types.toBeDoneQueue();
	readTextFile(toDo.shift());

	function readTextFile(filename) {
		if (filename) {
			var fullPath = that.types.getAppPath(filename);
			reader.readTextFile(fullPath, function(data) {
				if (data.errno) {
					console.log('read concordance.json failure ' + JSON.stringify(data));
				} else {
					switch(filename) {
						case 'chapterMetaData.json':
							result.chapterFiles = true;
							break;
						case 'toc.json':
							result.tableContents = true;
							var bookList = JSON.parse(data);
							that.toc.fill(bookList);
							break;
						case 'concordance.json':
							result.concordance = true;
							var wordList = JSON.parse(data);
							that.concordance.fill(wordList);
							break;
						case 'history.json':
							result.history = true;
							var historyList = JSON.parse(data);
							that.history.fill(historyList);
							break;
						case 'styleIndex.json':
							result.styleIndex = true;
							var styleList = JSON.parse(data);
							that.styleIndex.fill(styleList);
							break;
						default:
							throw new Error('File ' + filename + ' is not known in AssetLoader.load.');

					}
				}
				readTextFile(toDo.shift());
			});
		} else {
			callback(result);
		}
	}
};
