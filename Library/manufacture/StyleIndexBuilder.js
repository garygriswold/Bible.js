/**
* This class traverses the USX data model in order to find each style, and 
* reference to that style.  It builds an index to each style showing
* all of the references where each style is used.
*/
function StyleIndexBuilder(collection) {
	this.collection = collection;
	this.styleIndex = new StyleIndex();
}
StyleIndexBuilder.prototype.readBook = function(usxRoot) {
	this.bookCode = '';
	this.chapter = null;
	this.verse = null;
	this.readRecursively(usxRoot);
};
StyleIndexBuilder.prototype.readRecursively = function(node) {
	switch(node.tagName) {
		case 'book':
			this.bookCode = node.code;
			var style = 'book.' + node.style;
			var reference = this.bookCode;
			this.styleIndex.addEntry(style, reference);
			break;
		case 'chapter':
			this.chapter = node.number;
			style = 'chapter.' + node.style;
			reference = this.bookCode + ':' + this.chapter;
			this.styleIndex.addEntry(style, reference);
			break;
		case 'verse':
			this.verse = node.number;
			style = 'verse.' + node.style;
			reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
			this.styleIndex.addEntry(style, reference);
			break;
		case 'usx':
		case 'text':
			// do nothing
			break;
		default:
			style = node.tagName + '.' + node.style;
			reference = this.bookCode + ':' + this.chapter + ':' + this.verse;
			this.styleIndex.addEntry(style, reference);
	}
	if ('children' in node) {
		for (var i=0; i<node.children.length; i++) {
			this.readRecursively(node.children[i]);
		}
	}
};
StyleIndexBuilder.prototype.schema = function() {
	var sql = 'style text not null, ' +
		'usage text not null, ' +
		'book text not null, ' +
		'chapter integer null, ' +
		'verse integer null';
	return(sql);
};
StyleIndexBuilder.prototype.loadDB = function(callback) {
	console.log('style index loadDB records count', this.styleIndex.size());
	var array = [];
	var styles = Object.keys(this.styleIndex.index);
	for (var i=0; i<styles.length; i++) {
		var style = styles[i];
		var styleUse = style.split('.');
		var refList = this.styleIndex.index[style];
		for (var j=0; j<refList.length; j++) {
			var refItem = refList[j];
			var reference = refItem.split(':');
			switch(reference.length) {
				case 1:
					var values = [ styleUse[1], styleUse[0], reference[0], null, null ];
					break;
				case 2:
					values = [ styleUse[1], styleUse[0], reference[0], reference[1], null ];
					break;
				case 3:
					values = [ styleUse[1], styleUse[0], reference[0], reference[1], reference[2] ];
			}
			array.push(values);
		}
	}
	var names = [ 'style', 'usage', 'book', 'chapter', 'verse' ];
	this.collection.load(names, array, function(err) {
		if (err) {
			window.alert('StyleIndex Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('StyleIndex loaded in database');
			callback();
		}
	});
};
StyleIndexBuilder.prototype.toJSON = function() {
	return(this.styleIndex.toJSON());
};
