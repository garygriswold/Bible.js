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
		'instructor text null, ' +
		'answerDateTime text null, ' +
		'answer text null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create questions success');
			callback();
		}
	});
};
QuestionsAdapter.prototype.selectAll = function(callback) {
	var statement = 'select askedDateTime, book, chapter, verse, question, instructor, answerDateTime, answer ' +
		'from questions order by askedDateTime';
	this.database.select(statement, [], function(results) {
		if (results instanceof IOError) {
			console.log('select questions failure ' + JSON.stringify(results));
			callback();
		} else {
			callback(results);
		}
	});
};
QuestionsAdapter.prototype.replace = function(values, callback) {
var statement = 'replace into questions(askedDateTime, book, chapter, verse, question) ' +
		'values (?,?,?,?,?)';
	this.database.executeDML(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('Error on Insert');
			callback(results);
		} else {
			callback(results);
		}
	});
};
QuestionsAdapter.prototype.update = function(values, callback) {
	var statement = 'update questions set instructor = ?, answerDateTime = ?, answer = ?' +
		'where askedDateTime = ?';
	this.database.update(statement, values, function(results) {
		if (err instanceof IOError) {
			console.log('Error on update');
			callback(err);
		} else {
			callback();
		}
	});
};
