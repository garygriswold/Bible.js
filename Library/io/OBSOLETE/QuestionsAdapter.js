/**
* This class is the database adapter for the questions table
*/
function QuestionsAdapter(database) {
	this.database = database;
	this.className = 'QuestionsAdapter';
	Object.freeze(this);
}
QuestionsAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists Questions', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop Questions success');
			callback();
		}
	});
};
QuestionsAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists Questions(' +
		'askedDateTime text not null primary key, ' +
		'discourseId text not null, ' +
		'reference text null, ' + // possibly should be not null
		'question text not null, ' +
		'instructor text null, ' +
		'answerDateTime text null, ' +
		'answer text null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create Questions success');
			callback();
		}
	});
};
QuestionsAdapter.prototype.selectAll = function(callback) {
	var statement = 'select discourseId, reference, question, askedDateTime, instructor, answerDateTime, answer ' +
		'from Questions order by askedDateTime';
	this.database.select(statement, [], function(results) {
		if (results instanceof IOError) {
			console.log('select Questions failure ' + JSON.stringify(results));
			callback(results);
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);	
				var askedDateTime = (row.askedDateTime) ? new Date(row.askedDateTime) : null;
				var answerDateTime = (row.answerDateTime) ? new Date(row.answerDateTime) : null;
				var ques = new QuestionItem(row.reference, row.question, 
					askedDateTime, row.instructor, answerDateTime, row.answer);
				ques.discourseId = row.discourseId;
				array.push(ques);
			}
			callback(array);
		}
	});
};
QuestionsAdapter.prototype.replace = function(item, callback) {
	var statement = 'replace into Questions(discourseId, reference, question, askedDateTime) ' +
		'values (?,?,?,?)';
	var values = [ item.discourseId, item.reference, item.question, item.askedDateTime.toISOString() ];
	this.database.executeDML(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('Error on Insert');
			callback(results);
		} else {
			callback(results);
		}
	});
};
QuestionsAdapter.prototype.update = function(item, callback) {
	var statement = 'update Questions set instructor = ?, answerDateTime = ?, answer = ?' +
		'where askedDateTime = ?';
	var values = [ item.instructor, item.answerDateTime.toISOString(), item.answer, item.askedDateTime.toISOString() ];
	this.database.executeDML(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('Error on update');
			callback(results);
		} else {
			callback(results);
		}
	});
};
