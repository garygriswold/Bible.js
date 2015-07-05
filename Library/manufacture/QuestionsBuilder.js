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
QuestionsBuilder.prototype.schema = function() {
	var sql = 'askedDateTime text not null primary key, ' +
		'book text not null, ' +
		'chapter integer not null, ' +
		'verse integer null, ' +
		'question text not null, ' +
		'instructor text not null, ' +
		'answerDateTime text not null, ' +
		'answer text not null';
	return(sql);
};
QuestionsBuilder.prototype.loadDB = function(callback) {
	callback();  // This class does not load history
};