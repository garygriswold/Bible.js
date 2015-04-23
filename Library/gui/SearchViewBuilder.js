/**
* This class does a lazy construction of all of the parts of the SearchView, or just attaches
* the searchView if it already exists.
*/
"use strict";

function SearchViewBuilder(versionCode, toc) {
	this.versionCode = versionCode;
	this.toc = toc;
	this.searchView = null;
	this.concordance = new Concordance();

	Object.seal(this);
};
SearchViewBuilder.prototype.showSearch = function() {
	if (this.searchView) {
		this.attachSearchView();
	} 
	else if (this.concordance.size > 1000) {
		this.buildSearchView();
	}
	else {
		var that = this;
		var reader = new NodeFileReader('application');
		reader.fileExists(this.getPath(this.concordance.filename), existsSuccessHandler, existsFailureHandler);
	}

	function existsFailureHandler(err) {
		if (err.code === 'ENOENT') {
			console.log('check exists concordance json is not found');
			that.createConcordanceFile();
		} 
		else {
			console.log('check exists concordance.json failure ' + JSON.stringify(err));
		}
	}
	function existsSuccessHandler(stat) {
		console.log('concordance.json exists ' + JSON.stringify(stat));
		that.readConcordanceFile();
 	}
};
SearchViewBuilder.prototype.createConcordanceFile = function() {
	var that = this;
	var options = { buildTableContents: true, buildConcordance: true, buildStyleIndex: true };
	var builder = new AssetBuilder('application', this.versionCode, options);
	builder.build(createConcordanceSuccess, createConcordanceFailure);

	function createConcordanceFailure(err) {
		console.log('create concordance file failure');
	}
	function createConcordanceSuccess() {
		that.readConcordanceFile();
	}
};
SearchViewBuilder.prototype.readConcordanceFile = function() {
	var that = this;
	var reader = new NodeFileReader('application');
	var fullPath = this.getPath(this.concordance.filename);
	reader.readTextFile(fullPath, readSuccessHandler, readFailureHandler);
	
	function readFailureHandler(err) {
		console.log('read concordance.json failure ' + JSON.stringify(err));
	};
	function readSuccessHandler(data) {
		that.concordance = new Concordance(JSON.parse(data));
		console.log('condordance word ' + that.concordance.size());
		that.buildSearchView();
	};
};
SearchViewBuilder.prototype.buildSearchView = function() {
	this.searchView = new SearchView(this.concordance, this.toc);
	this.searchView.build();
	this.attachSearchView();
};
SearchViewBuilder.prototype.attachSearchView = function() {
	var appTop = document.getElementById('appTop');
	for (var i=appTop.children.length -1; i>=0; i--) {
		var child = appTop.children[i];
		appTop.removeChild(child);
	}
	//appTop.appendChild(this.searchView);
};
SearchViewBuilder.prototype.processFailure = function(err) {
	console.log('process failure  ' + JSON.stringify(err));
};
SearchViewBuilder.prototype.getPath = function(filename) {
	return('usx/' + this.versionCode + '/' + filename);
};
