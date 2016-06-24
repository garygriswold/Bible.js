/**
* This class builds a table of already handled styles so that we can easily
* query the styleIndex table for any styles that are new in a table.
*/
function StyleUseBuilder(adapter) {
	this.adapter = adapter;
}
StyleUseBuilder.prototype.readBook = function(usxRoot) {
	// This table is not populated from text of the Bible
};
StyleUseBuilder.prototype.loadDB = function(callback) {
	var styles = [ 'book.id', 'para.ide', 'para.h', 'para.toc1', 'para.toc2', 'para.toc3', 'para.cl', 'para.rem',
		'para.mt', 'para.mt1', 'para.mt2', 'para.mt3', 'para.ms', 'para.ms1', 'para.s', 'para.s1', 'para.s2', 'para.d', 'para.r',
		'para.imt', 'para.io', 'para.io1', 'para.io2', 'para.ip', 'para.is',
		'chapter.c', 'verse.v',
		'para.p', 'para.m', 'para.b', 'para.mi', 'para.pi', 'para.pi1', 'para.li', 'para.li1', 'para.nb',
		'para.sp', 'para.q', 'para.q1', 'para.q2', 'para.qc', 'para.qa',
		'char.pn', 'char.wj', 'char.qs', 'char.add', 'char.nd', 'char.tl',
		'note.f', 'note.x', 'char.xt', 'char.fr', 'char.ft', 'char.fv', 'char.fqa', 'char.xo' ];
	var array = [];
	for (var i=0; i<styles.length; i++) {
		var style = styles[i];
		var styleUse = style.split('.');
		var values = [ styleUse[1], styleUse[0] ];
		array.push(values);
	}
	this.adapter.load(array, function(err) {
		if (err instanceof IOError) {
			console.log('StyleUse Builder Failed', JSON.stringify(err));
			callback(err);
		} else {
			console.log('StyleUse loaded in database');
			callback();
		}
	});
};