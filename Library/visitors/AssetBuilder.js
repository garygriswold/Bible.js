/**
* The Table of Contents and Concordance must be created by processing the entire text.  Since the parsing of the XML
* is a significant amount of the time to do this, this class reads over the entire Bible text and creates
* all of the required assets.
*/
"use strict";

function AssetBuilder(location, versionCode, options) {
	this.versionCode = versionCode;
	this.builders = [];
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
	this.reader.readDirectory(this.getPath(''), dirReadSuccess, dirReadFailure);

	function dirReadFailure(err) {
		console.log('directory read err ', JSON.stringify(err));
		// what do we do now???
	}
	function dirReadSuccess(files) {
		var count = 0
		for (var i=0; i<files.length && count < 66; i++) {
			if (files[i].indexOf('.usx') > 0) {
				that.filesToProcess.push(files[i]);
				count++;
			}
		}
		processFile(that.filesToProcess.shift());
	}
	function fileReadFailure(err) {
		console.log('file read err ', JSON.stringify(err));
		// now what?
	}
	function fileReadSuccess(data) {
		var rootNode = that.parser.readBook(data);
		for (var i=0; i<that.builders.length; i++) {
			that.builders[i].readBook(rootNode);
		}
		processFile(that.filesToProcess.shift());
	}
	function processFile(file) {
		if (file) {
			that.reader.readTextFile(that.getPath(file), fileReadSuccess, fileReadFailure);
		} else {
			for (var i=0; i<that.builders.length; i++) {
				var json = that.builders[i].toJSON();
				var filepath = that.getPath(that.builders[i].filename);
				that.writer.writeTextFile(filepath, json, fileWriteSuccess, fileWriteFailure);
			}
		}
	}
	function fileWriteFailure(err) {
		console.log('file write failure ', err);
		// what now
	}
	function fileWriteSuccess(filename) {
		console.log('file write success ', filename);
	}
};
AssetBuilder.prototype.getPath = function(filename) {
	return('usx/' + this.versionCode + '/' + filename);
};