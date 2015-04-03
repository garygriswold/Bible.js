/**
* This class holds an index of styles of the entire Bible, or whatever part of the Bible was loaded into it.
*/
"use strict";

function StyleIndex() {
	this.index = {};
	Object.freeze(this);
};
StyleIndex.prototype.addEntry = function(word, reference) {
	if (this.index[word] === undefined) {
		this.index[word] = [];
	}
	this.index[word].push(reference);
};
StyleIndex.prototype.find = function(word) {
	return(this.index[word]);
};
StyleIndex.prototype.dumpAlphaSort = function() {
	var words = Object.keys(this.index);
	var alphaWords = words.sort();
	this.dump(alphaWords);
};
StyleIndex.prototype.dump = function(words) {
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		console.log(word, this.index[word]);
	};	
};