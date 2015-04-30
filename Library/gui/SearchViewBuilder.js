/**
* This class does a lazy construction of all of the parts of the SearchView, or just attaches
* the searchView if it already exists.
*/
"use strict";

function SearchViewBuilder(versionCode, toc, bibleCache) {
	this.versionCode = versionCode;
	this.toc = toc;
	this.bibleCache = bibleCache;
	this.searchView = null;
	this.query = '';
	this.concordance = new Concordance();

	Object.seal(this);
};
SearchViewBuilder.prototype.showSearch = function(query) {
	this.query = query;
	if (this.searchView) {
		this.attachSearchView();
	} 
	else if (this.concordance.size > 1000) {
		this.buildSearchView(query);
	}
	else {
		var that = this;
		var reader = new NodeFileReader('application');
		reader.fileExists(this.getPath(this.concordance.filename), function(stat) {
			if (stat instanceof Error) {
				if (stat.code === 'ENOENT') {
					console.log('check exists concordance json is not found');
					that.createConcordanceFile();	
				} else {
					console.log('check exists concordance.json failure ' + JSON.stringify(stat));
				}
			} else {
				that.readConcordanceFile();
			}
		});
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
	reader.readTextFile(fullPath, function(data) {
		if (data instanceof Error) {
			console.log('read concordance.json failure ' + JSON.stringify(data));
		} else {
			that.concordance = new Concordance(JSON.parse(data));
			that.buildSearchView(that.query);
		}
	});
};
SearchViewBuilder.prototype.buildSearchView = function(query) {
	this.searchView = new SearchView(this.concordance, this.toc, this.bibleCache);
	this.searchView.showSearch(query);
	this.attachSearchView();
};
SearchViewBuilder.prototype.attachSearchView = function() {
	var appTop = document.getElementById('appTop');
	for (var i=appTop.children.length -1; i>=0; i--) {
		var child = appTop.children[i];
		appTop.removeChild(child);
	}
	appTop.appendChild(this.searchView.viewRoot);
};
SearchViewBuilder.prototype.processFailure = function(err) {
	console.log('process failure  ' + JSON.stringify(err));
};
SearchViewBuilder.prototype.getPath = function(filename) {
	return('usx/' + this.versionCode + '/' + filename);
};
