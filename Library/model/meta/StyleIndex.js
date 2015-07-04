/**
* This class holds an index of styles of the entire Bible, or whatever part of the Bible was loaded into it.
*/
function StyleIndex() {
	this.index = {};
	this.isFilled = false;
	this.completed = [ 'book.id', 'para.ide', 'para.h', 'para.toc1', 'para.toc2', 'para.toc3', 'para.cl', 'para.rem',
		'para.mt', 'para.mt1', 'para.mt2', 'para.mt3', 'para.ms', 'para.ms1', 'para.d',
		'chapter.c', 'verse.v',
		'para.p', 'para.m', 'para.b', 'para.mi', 'para.pi', 'para.li', 'para.li1', 'para.nb',
		'para.sp', 'para.q', 'para.q1', 'para.q2',
		'note.f', 'note.x', 'char.fr', 'char.ft', 'char.fqa', 'char.xo',
		'char.wj', 'char.qs'];
	Object.seal(this);
}
StyleIndex.prototype.fill = function(entries) {
	this.index = entries;
	this.isFilled = true;
	Object.freeze(this);
};
StyleIndex.prototype.addEntry = function(word, reference) {
	if (this.index[word] === undefined) {
		this.index[word] = [];
	}
	if (this.index[word].length < 100) {
		this.index[word].push(reference);
	}
};
StyleIndex.prototype.find = function(word) {
	return(this.index[word]);
};
StyleIndex.prototype.size = function() {
	return(Object.keys(this.index).length);
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
	}	
};
StyleIndex.prototype.toJSON = function() {
	return(JSON.stringify(this.index, null, ' '));
};