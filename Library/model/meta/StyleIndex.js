/**
* This class holds an index of styles of the entire Bible, or whatever part of the Bible was loaded into it.
*/
function StyleIndex() {
	this.index = {};
	this.isFilled = false;
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