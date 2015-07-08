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
			console.log('drop questions success');
			callback();
		}
	});
};
QuestionsAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists questions(' +
		'askedDateTime text not null primary key, ' +
		'book text not null, ' +
		'chapter integer not null, ' +
		'verse integer null, ' +
		'question text not null, ' +
		'instructor text not null, ' +
		'answerDateTime text not null, ' +
		'answer text not null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create questions success');
			callback();
		}
	});
};
QuestionsAdapter.prototype.select = function(values, callback) {

};
QuestionsAdapter.prototype.insert = function(values, callback) {

};
QuestionsAdapter.prototype.update = function(values, callback) {

};
QuestionsAdapter.prototype.delete = function(values, callback) {

};