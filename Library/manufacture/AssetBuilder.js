/**
* The Table of Contents and Concordance must be created by processing the entire text.  Since the parsing of the XML
* is a significant amount of the time to do this, this class reads over the entire Bible text and creates
* all of the required assets.
*/
function AssetBuilder(types, database) {
	this.types = types;
	this.database = database;
	this.builders = [];
	if (types.chapterFiles) {
		this.builders.push(new ChapterBuilder(this.database.codex));
	}
	if (types.tableContents) {
		this.builders.push(new TOCBuilder(this.database.tableContents));
	}
	if (types.concordance) {
		this.builders.push(new ConcordanceBuilder(this.database.concordance));
	}
	if (types.history) { 
		// do nothing 
	}
	if (types.styleIndex) {
		this.builders.push(new StyleIndexBuilder(this.database.styleIndex));
		this.builders.push(new StyleUseBuilder(this.database.styleUse));
	}
	if (types.history) {
		this.builders.push(new HistoryBuilder(this.database.history));
	}
	if (types.html) {
		this.builders.push(new HTMLBuilder()); // HTMLBuilder does NOT yet have the correct interface for this.
	}
	this.reader = new FileReader(types.location);
	this.parser = new USXParser();
	this.writer = new FileWriter(types.location);
	this.filesToProcess = [];
	Object.freeze(this);
}
AssetBuilder.prototype.build = function(callback) {
	var that = this;
	if (this.builders.length > 0) {
		this.filesToProcess.splice(0);
		var canon = new Canon();
		for (var i=0; i<canon.books.length; i++) {
			this.filesToProcess.push(canon.books[i].code + '.usx');
		}
		processReadFile(this.filesToProcess.shift());
	} else {
		callback();
	}
	function processReadFile(file) {
		if (file) {
			that.reader.readTextFile(that.types.getUSXPath(file), function(data) {
				if (data.errno) {
					console.log('file read err ', JSON.stringify(data));
					callback(data);
				} else {
					var rootNode = that.parser.readBook(data);
					for (var i=0; i<that.builders.length; i++) {
						that.builders[i].readBook(rootNode);
					}
					processReadFile(that.filesToProcess.shift());
				}
			});
		} else {
			processDatabaseLoad(that.builders.shift());
		}
	}
	function processDatabaseLoad(builder) {
		if (builder) {
			builder.collection.drop(function(err) {
				if (err) {
					console.log('drop error', err);
					callback(err);
				} else {
					builder.collection.create(builder.schema(), function(err) {
						if (err) {
							console.log('create error', err);
							callback(err);
						} else {
							builder.loadDB(function(err) {
								if (err) {
									console.log('load db error', err);
									callback(err);
								} else {
									processDatabaseLoad(that.builders.shift());
								}
							});
						}
					});
				}
			});
		} else {
			callback();
		}
	}
};
