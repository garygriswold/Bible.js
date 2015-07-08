/**
* This class is the database adapter for the questions table
*/
function QuestionsAdapter(database) {
	this.database = database;
	this.className = 'QuestionsAdapter';
	Object.freeze(this);
}
QuestionsAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists questions', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop questions success', err);
			callback(err);
		}
	});
};
QuestionsAdapter.prototype.create = function(callback) {

};
QuestionsAdapter.prototype.select = function(values, callback) {

};
QuestionsAdapter.prototype.insert = function(values, callback) {

};
QuestionsAdapter.prototype.update = function(values, callback) {

};
QuestionsAdapter.prototype.delete = function(values, callback) {

};