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
HistoryBuilder.prototype.loadDB = function(callback) {
	callback();  // This class does not load history
};