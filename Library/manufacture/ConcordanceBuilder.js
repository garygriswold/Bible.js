/**
* This class traverses the USX data model in order to find each word, and 
* reference to that word.
*
* This solution might not be unicode safe. GNG Apr 2, 2015
*/
function ConcordanceBuilder(adapter) {
	this.adapter = adapter;
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.refList = {};
	this.refPositions = {};
	Object.seal(this);
}
ConcordanceBuilder.prototype.readBook = function(usxRoot) {
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
	this.readRecursively(usxRoot);
};
ConcordanceBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			this.bookCode = node.code;
			break;
		case 'chapter':
			this.chapter = node.number;
			break;
		case 'verse':
			this.verse = node.number;
			break;
		case 'note':
			break; // Do not index notes
		case 'text':
			var words = node.text.split(/\b/);
			for (var i=0; i<words.length; i++) {
				var word = words[i].replace(/[\u2000-\u206F\u2E00-\u2E7F\\'!"#\$%&\(\)\*\+,\-\.\/:;<=>\?@\[\]\^_`\{\|\}~\s0-9]/g, '');
				if (word.length > 0 && this.chapter > 0 && this.verse > 0) {
					var reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
					this.addEntry(word.toLocaleLowerCase(), reference, i);
				}
			}
			break;
		default:
			if ('children' in node) {
				for (i=0; i<node.children.length; i++) {
					this.readRecursively(node.children[i]);
				}
			}

	}
};
ConcordanceBuilder.prototype.addEntry = function(word, reference, index) {
	if (this.refList[word] === undefined) {
		this.refList[word] = [];
		this.refPositions[word] = [];
	}
	var list = this.refList[word];
	var pos = this.refPositions[word];
	if (reference !== list[list.length -1]) { /* ignore duplicate reference */
		list.push(reference);
		pos.push(reference + ':' + index);
	} else {
		pos[pos.length -1] = pos[pos.length -1] + ':' + index;
	}
};
ConcordanceBuilder.prototype.size = function() {
	return(Object.keys(this.refList).length); 
};
ConcordanceBuilder.prototype.loadDB = function(callback) {
	console.log('Concordance loadDB records count', this.size());
	var words = Object.keys(this.refList);
	var array = [];
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		array.push([ word, this.refList[word].length, this.refList[word], this.refPositions[word] ]);
	}
	this.adapter.load(array, function(err) {
		if (err instanceof IOError) {
			console.log('Concordance Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('concordance loaded in database');
			callback();
		}
	});
};
ConcordanceBuilder.prototype.toJSON = function() {
	return(JSON.stringify(this.refList, null, ' '));
};