/**
* This class holds the concordance of the entire Bible, or whatever part of the Bible was available.
*/
"use strict";

function Concordance() {
	this.index = {};
	this.filename = 'concordance.json';
	Object.freeze(this);
};
Concordance.prototype.addEntry = function(word, reference) {
	if (this.index[word] === undefined) {
		this.index[word] = [];
	}
	this.index[word].push(reference);
};
Concordance.prototype.find = function(word) {
	return(this.index[word]);
};
Concordance.prototype.dumpAlphaSort = function() {
	var words = Object.keys(this.index);
	var alphaWords = words.sort();
	this.dump(alphaWords);
};
Concordance.prototype.dumpFrequencySort = function() {
	var freqMap = {};
	var words = Object.keys(this.index);
	for (var i=0; i<words.length; i++) {
		var key = words[i];
		var len = this.index[key].length;
		console.log('***', key, len);
		if (freqMap[len] === undefined) {
			freqMap[len] = [];
		}
		freqMap[len].push(key);
	}
	var freqSort = Object.keys(freqMap).sort(function(a, b) {
		return(a-b);
	});
	for (var i=0; i<freqSort.length; i++) {
		var freq = freqSort[i];
		console.log(freq, freqMap[freq]);
	}
};
Concordance.prototype.dump = function(words) {
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		console.log(word, this.index[word]);
	};	
};
Concordance.prototype.toJSON = function() {
	return(JSON.stringify(this.index, null, ' '));
};