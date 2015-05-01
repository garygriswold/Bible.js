/**
* This class holds the concordance of the entire Bible, or whatever part of the Bible was available.
*/
"use strict";

function Concordance() {
	this.index = {};
	this.filename = 'concordance.json';
	this.isFilled = false;
	Object.seal(this);
};
Concordance.prototype.fill = function(words) {
	this.index = words;
	this.isFilled = true;
	Object.freeze(this);
};
Concordance.prototype.addEntry = function(word, reference) {
	if (this.index[word] === undefined) {
		this.index[word] = [];
		this.index[word].push(reference);
	}
	else {
		var refList = this.index[word];
		if (reference !== refList[refList.length -1]) { /* ignore duplicate reference */
			refList.push(reference);
		}
	}
};
Concordance.prototype.size = function() {
	return(Object.keys(this.index).length);
}
Concordance.prototype.search = function(search) {
	var refList = []; 
	var words = search.split(' ');
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		refList.push(this.index[word]);
	}
	return(this.intersection(refList));
}
Concordance.prototype.intersection = function(refLists) {
	if (refLists.length === 0) {
		return([]);
	}
	if (refLists.length === 1) {
		return(refLists[0]);
	}
	var mapList = [];
	for (var i=1; i<refLists.length; i++) {
		var map = arrayToMap(refLists[i]);
		mapList.push(map);
	}
	var result = [];
	var firstList = refLists[0];
	for (var j=0; j<firstList.length; j++) {
		var reference = firstList[j];
		var present = true;
		for (var k=0; k<mapList.length; k++) {
			present = present && mapList[k][reference];
			if (present) {
				result.push(reference)
			}
		}
	}
	return(result);

	function arrayToMap(array) {
		var map = {};
		for (var i=0; i<array.length; i++) {
			map[array[i]] = true;
		}
		return(map);
	}
}
/** This is a fast intersection method, but it requires the lists to be sorted. */
Concordance.prototype.intersectionOld = function(a, b) {
	var ai = 0
	var bi = 0;
	var result = [];

  	while( ai < a.length && bi < b.length ) {
    	if      (a[ai] < b[bi] ){ ai++; }
   		else if (a[ai] > b[bi] ){ bi++; }
   		else { /* they're equal */
     		result.push(a[ai]);
     		ai++;
     		bi++;
   		}
  	}
  	return result;
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