/**
* This class holds an index of styles of the entire Bible, or whatever part of the Bible was loaded into it.
*/
"use strict";

function StyleIndex() {
	this.index = {};
	this.completed = [ 'book.id', 'para.ide', 'para.h', 'para.toc1', 'para.toc2', 'para.toc3', 'para.cl',
		'para.mt', 'para.mt2', 'para.mt3', 'para.ms', 'para.d',
		'chapter.c', 'verse.v',
		'para.p', 'para.m', 'para.b', 'para.mi', 'para.pi', 'para.li', 'para.nb',
		'para.sp', 'para.q', 'para.q2',
		'char.wj', 'char.qs'];
	Object.freeze(this);
};
StyleIndex.prototype.addEntry = function(word, reference) {
	if (this.completed.indexOf(word) < 0) {
		if (this.index[word] === undefined) {
			this.index[word] = [];
		}
		if (this.index[word].length < 100) {
			this.index[word].push(reference);
		}
	}
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