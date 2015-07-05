/**
* This class creates an empty History table.  The table is filled
* by user action.
*/
function HistoryBuilder(collection) {
	this.collection = collection;
	Object.freeze(this);
}
HistoryBuilder.prototype.readBook = function(usxRoot) {
	// This class does not process the Bible
};
HistoryBuilder.prototype.schema = function() {
	var sql = 'timestamp text not null primary key, ' +
		'book text not null, ' +
		'chapter integer not null, ' +
		'verse integer null, ' +
		'source text not null, ' +
		'search text null';
	return(sql);
};
HistoryBuilder.prototype.loadDB = function(callback) {
	callback();  // This class does not load history
};