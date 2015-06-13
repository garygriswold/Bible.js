/**
* This class holds the concordance of the entire Bible, or whatever part of the Bible was available.
*/
function Concordance() {
	this.index = {};
	this.filename = 'concordance.json';
	this.isFilled = false;
	Object.seal(this);
}
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
};
Concordance.prototype.search = function(words) {
	var refList = [];
	for (var i=0; i<words.length; i++) {
		var list = this.index[words[i].toLocaleLowerCase()];
		if (list) { // This is ignoring words that return no list, and allowing search to continue.
			refList.push(list);
		}
	}
	return(this.intersection(refList));
};
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
		if (presentInAllMaps(mapList, reference)) {
			result.push(reference);
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
	function presentInAllMaps(mapList, reference) {
		for (var i=0; i<mapList.length; i++) {
			if (mapList[i][reference] === undefined) {
				return(false);
			}
		}
		return(true);
	}
};
Concordance.prototype.toJSON = function() {
	return(JSON.stringify(this.index, null, ' '));
};