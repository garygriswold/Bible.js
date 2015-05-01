/**
* The Table of Contents and Concordance must be created by processing the entire text.  Since the parsing of the XML
* is a significant amount of the time to do this, this class reads over the entire Bible text and creates
* all of the required assets.
*/
"use strict";

function AssetBuilder(types) {
	this.types = types;
	this.builders = [];
	if (types.chapterFiles) {
		this.builders.push(new ChapterBuilder(types.location, types.versionCode));
	}
	if (types.tableContents) {
		this.builders.push(new TOCBuilder());
	}
	if (types.concordance) {
		this.builders.push(new ConcordanceBuilder());
	}
	if (types.styleIndex) {
		this.builders.push(new StyleIndexBuilder());
	}
	if (types.html) {
		this.builders.push(new HTMLBuilder()); // HTMLBuilder does NOT yet have the correct interface for this.
	}
	this.reader = new NodeFileReader(types.location);
	this.parser = new USXParser();
	this.writer = new NodeFileWriter(types.location);
	this.filesToProcess = [];
	Object.freeze(this);
};
AssetBuilder.prototype.build = function(callback) {
	if (this.builders.length > 0) {
		var that = this;
		this.reader.readDirectory(this.types.getPath(''), function(files) {
			if (files instanceof Error) {
				console.log('directory read err ', JSON.stringify(files));
				callback(files);
			} else {
				var count = 0
				for (var i=0; i<files.length && count < 66; i++) {
					if (files[i].indexOf('.usx') > 0) {
						that.filesToProcess.push(files[i]);
						count++;
					}
				}
				processReadFile(that.filesToProcess.shift());
			}
		});
	} else {
		callback();
	}
	function processReadFile(file) {
		if (file) {
			that.reader.readTextFile(that.types.getPath(file), function(data) {
				if (data instanceof Error) {
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
			processWriteResult(that.builders.shift());
		}
	}
	function processWriteResult(builder) {
		if (builder) {
			var json = builder.toJSON();
			var filepath = that.types.getPath(builder.filename);
			that.writer.writeTextFile(filepath, json, function(filename) {
				if (filename instanceof Error) {
					console.log('file write failure ', filename);
					callback(filename);
				} else {
					console.log('file write success ', filename);
					processWriteResult(that.builders.shift());
				}
			});
		} else {
			callback();
		}
	}
};
