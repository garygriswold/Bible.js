/**
* This class gets information from the concordance that was built, and produces 
* a word list with frequency counts for each word.
*/
"use strict";

function WordCountBuilder(concordance) {
	this.concordance = concordance;
	this.filename = 'wordCount.json';
};
WordCountBuilder.prototype.readBook = function(usxRoot) {
};
WordCountBuilder.prototype.toJSON = function() {
	var countMap = {};
	var freqMap = {};
	var index = this.concordance.index;
	var words = Object.keys(index);
	for (var i=0; i<words.length; i++) {
		var key = words[i];
		var len = index[key].length;
		countMap[key] = len;
		if (freqMap[len] === undefined) {
			freqMap[len] = [];
		}
		freqMap[len].push(key);
	}
	var wordSort = Object.keys(countMap).sort();
	var freqSort = Object.keys(freqMap).sort(function(a, b) {
		return(a - b);
	});
	var result = [];
	result.push('Num Words:  ' + wordSort.length);
	for (var i=0; i<wordSort.length; i++) {
		var word = wordSort[i];
		result.push(word + ':\t\t' + countMap[word]);
	}
	for (i=0; i<freqSort.length; i++) {
		var freq = freqSort[i];
		var words = freqMap[freq];
		for (var j=0; j<words.length; j++) {
			result.push(freq + ':\t\t' + words[j]);
		}
	}
	return(result.join('\n'));
};
