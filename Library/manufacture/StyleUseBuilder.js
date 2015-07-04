/**
* This class builds a table of already handled styles so that we can easily
* query the styleIndex table for any styles that are new in a table.
*/
function StyleUseBuilder(collection) {
	this.collection = collection;
}
StyleUseBuilder.prototype.readBook = function(usxRoot) {
	// This table is not populated from text of the Bible
};
StyleUseBuilder.prototype.schema = function() {
	var sql = 'style text not null, ' +
		'usage text not null';
	return(sql);
};
StyleUseBuilder.prototype.loadDB = function(callback) {
	var styles = [ 'book.id', 'para.ide', 'para.h', 'para.toc1', 'para.toc2', 'para.toc3', 'para.cl', 'para.rem',
		'para.mt', 'para.mt1', 'para.mt2', 'para.mt3', 'para.ms', 'para.ms1', 'para.d',
		'chapter.c', 'verse.v',
		'para.p', 'para.m', 'para.b', 'para.mi', 'para.pi', 'para.li', 'para.li1', 'para.nb',
		'para.sp', 'para.q', 'para.q1', 'para.q2',
		'note.f', 'note.x', 'char.fr', 'char.ft', 'char.fqa', 'char.xo',
		'char.wj', 'char.qs'];
	var array = [];
	for (var i=0; i<styles.length; i++) {
		var style = styles[i];
		var styleUse = style.split('.');
		var values = [ styleUse[1], styleUse[0] ];
		array.push(values);
	}
	var names = [ 'style', 'usage' ];
	this.collection.load(names, array, function(err) {
		if (err) {
			window.alert('StyleUse Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('StyleUse loaded in database');
			callback();
		}
	});
};