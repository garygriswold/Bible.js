/**
* This class creates an initial Questions table.  The table is filled
* by user and instructor input.
*/
function QuestionsBuilder(collection) {
	this.collection = collection;
	Object.freeze(this);
}
QuestionsBuilder.prototype.readBook = function(usxRoot) {
	// This class does not process the Bible
};
QuestionsBuilder.prototype.loadDB = function(callback) {
	callback();  // This class does not load history
};
