/**
* This class traverses the USX data model in order to find each word, and 
* reference to that word.
*
* This solution might not be unicode safe. GNG Apr 2, 2015
*/
function ConcordanceBuilder(collection) {
	this.collection = collection;
	this.index = {};
	this.bookCode = '';
	this.chapter = 0;
	this.verse = 0;
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
					this.addEntry(word.toLocaleLowerCase(), reference);
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
ConcordanceBuilder.prototype.addEntry = function(word, reference) {
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
ConcordanceBuilder.prototype.size = function() {
	return(Object.keys(this.index).length); 
};
ConcordanceBuilder.prototype.schema = function() {
	var sql = 'word text primary key not null, ' +
    	'refCount integer not null, ' +
    	'refList text not null';
    return(sql);
};
ConcordanceBuilder.prototype.loadDB = function(callback) {
	console.log('Concordance loadDB records count', this.size());
	var words = Object.keys(this.index);
	var array = [];
	for (var i=0; i<words.length; i++) {
		var word = words[i];
		var refList = this.index[word];
		var refCount = refList.length;
		var item = [ words[i], refCount, refList ];
		array.push(item);
	}
	var names = [ 'word', 'refCount', 'refList' ];
	this.collection.load(names, array, function(err) {
		if (err) {
			window.alert('Concordance Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('concordance loaded in database');
			callback();
		}
	});
};
ConcordanceBuilder.prototype.toJSON = function() {
	return(JSON.stringify(this.index, null, ' '));
};