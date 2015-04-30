/**
* The Table of Contents and Concordance must be created by processing the entire text.  Since the parsing of the XML
* is a significant amount of the time to do this, this class reads over the entire Bible text and creates
* all of the required assets.
*/
"use strict";

function AssetBuilder(location, versionCode, options) {
	this.versionCode = versionCode;
	this.builders = [];
	if (options.buildChapters) {
		this.builders.push(new ChapterBuilder(location, versionCode));
	}
	if (options.buildTableContents) {
		this.builders.push(new TOCBuilder());
	}
	if (options.buildConcordance) {
		this.builders.push(new ConcordanceBuilder());
	}
	if (options.buildStyleIndex) {
		this.builders.push(new StyleIndexBuilder());
	}
	if (options.buildHTML) {
		this.builders.push(new HTMLBuilder()); // HTMLBuilder does NOT yet have the correct interface for this.
	}
	this.reader = new NodeFileReader(location);
	this.parser = new USXParser();
	this.writer = new NodeFileWriter(location);
	this.filesToProcess = [];
	Object.freeze(this);
};
AssetBuilder.prototype.build = function(successCallback, failureCallback) {
	var that = this;
	this.reader.readDirectory(this.getPath(''), function(files) {
		if (files instanceof Error) {
			console.log('directory read err ', JSON.stringify(err));
			failureCallback(err);
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
	function processReadFile(file) {
		if (file) {
			that.reader.readTextFile(that.getPath(file), function(data) {
				if (data instanceof Error) {
					console.log('file read err ', JSON.stringify(data));
					failureCallback(data);
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
			var filepath = that.getPath(builder.filename);
			that.writer.writeTextFile(filepath, json, function(filename) {
				if (filename instanceof Error) {
					console.log('file write failure ', filename);
					failureCallback(filename);
				} else {
					console.log('file write success ', filename);
					processWriteResult(that.builders.shift());
				}
			});
		} else {
			successCallback();
		}
	}
};
AssetBuilder.prototype.getPath = function(filename) {
	return('usx/' + this.versionCode + '/' + filename);
};