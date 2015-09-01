/**
* This class provides a convenient JS interface to a SQL database.
* The interface is intended to be useful for any kind of database,
* but this implementation is for SQLite3.
*
* Note: as of 8/24/2015, when no rows are updated or deleted, because
* key was wrong, no error is being generated.
*/
function DatabaseAdapter(options) {
	var sqlite3 = (options.verbose) ? require('sqlite3').verbose() : require('sqlite3');
	this.db = new sqlite3.Database(options.filename);
	this.db.on('trace', function(sql) {
		console.log('DO ', sql);
	});
	this.db.on('profile', function(sql, ms) {
		console.log(ms, 'DONE', sql);
	});
	this.db.run("PRAGMA foreign_keys = ON");
}
DatabaseAdapter.prototype.create = function(callback) {
	var statements = [
		'drop table if exists Message',
		'drop table if exists Discourse',
		'drop table if exists Position',
		'drop table if exists Teacher',
		
		'create table Teacher(' +
			' teacherId text PRIMARY KEY NOT NULL,' + // GUID
			' fullname text NOT NULL,' +
			' pseudonym text NOT NULL,' +
			' signature text NOT NULL)',
			
		'CREATE TABLE Position(' +
			' positionId INTEGER PRIMARY KEY NOT NULL,' +
			' teacherId text REFERENCES Teacher(teacherId) ON DELETE CASCADE NOT NULL,' +
			' versionId text NOT NULL,' + // may reference a Version table
			' position text check(position in ("teacher", "principal", "super")) NOT NULL)',
			
		'CREATE INDEX PositionTeacherId ON Position(teacherId)',
		'CREATE INDEX PositionVersionId ON Position(versionId)',
		'CREATE UNIQUE INDEX PositionTable ON Position(teacherId, versionId, position)',
		
		'CREATE TABLE Discourse(' +
			' discourseId text PRIMARY KEY NOT NULL,' + // GUID
			' versionId text NOT NULL,' +
			' status text check(status in ("open", "assigned", "answered", "sent")) NOT NULL,' +
			' teacherId text REFERENCES Teacher(teacherId) NULL)',
			
		'CREATE INDEX DiscourseTeacher ON Discourse(teacherId)',
		'CREATE INDEX DiscourseVersion ON Discourse(versionId, status)', // Needed for Assign Question
			
		'CREATE TABLE Message(' +
			' messageId INTEGER PRIMARY KEY NOT NULL,' +
			' discourseId text REFERENCES Discourse(discourseId) ON DELETE CASCADE NOT NULL,' +
			' reference text NULL,' +
			' timestamp text NOT NULL,' +
			' message text NOT NULL)',
			
		'CREATE INDEX MessageDiscourseId ON Message(discourseId)'
	];
	var values = new Array(statements.length);
	this.executeSQL(statements, values, callback);
	
	// Message primary key could be discourseId + timestamp
	// Position primary key could be teacherId, versionId
	// But I might need both sequence.  When getting infomration on a teacher I would want teacher/version
	// When providing assignment information I would want version/position
};
DatabaseAdapter.prototype.selectTeachers = function(versionId, callback) {
	// Must select teachers where versionId, join or two queries
	// Must select positions where version
	// Join or two queries?
};
/**
* Teacher registration transaction
*/
DatabaseAdapter.prototype.insertTeacher = function(obj, callback) {
	var statements = [ 
		'insert into Teacher(teacherId, fullname, pseudonym, signature) values (?,?,?,?)',
		'insert into Position(teacherId, versionId, position) values (?,?,?)'
	 ];
	var values = [
		[ obj.teacherId, obj.fullname, obj.pseudonym, obj.signature ],
		[ obj.teacherId, obj.versionId, obj.position || "teacher" ]
	];
	this.executeSQL(statements, values, callback);
};
/**
* Needs primary key Teacher.teacherId
* If I need to update individual fields, then I will need to change this to generate SQL
*/
DatabaseAdapter.prototype.updateTeacher = function(obj, callback) {
	var statements = [ 'update Teacher set fullname=?, pseudonym=? where teacherId=?' ];
	var values = [[ obj.fullname, obj.pseudonym, obj.teacherId ]];
	this.executeSQL(statements, values, callback);
};
/**
* Needs primary key Teacher.teacherId
* Requires Position.teacherId to be on delete cascade
* Needs index on Position(teacherId)
*/
DatabaseAdapter.prototype.deleteTeacher = function(obj, callback) {
	var statements = [ 'delete from Teacher where teacherId = ?' ];
	var values = [[ obj.teacherId ]];
	this.executeSQL(statements, values, callback);
};
DatabaseAdapter.prototype.selectPositions = function(teacherId, callback) {
	// ????? What uses this????
};
/**
* Needs Position.positionId, which it autogenerates
*/
DatabaseAdapter.prototype.insertPosition = function(obj, callback) {
	var statements = [ 'insert into Position(teacherId, versionId, position) values (?,?,?)' ];
	var values = [[ obj.teacherId, obj.versionId, obj.position ]];
	this.executeSQL(statements, values, callback);
};
DatabaseAdapter.prototype.updatePosition = function(obj, callback) {
	var statements = [ 'update Position set position=? where positionId=?' ];
	var values = [[ obj.position, obj.positionId ]];
	this.executeSQL(statements, values, callback);	
};
DatabaseAdapter.prototype.deletePosition = function(obj, callback) {
	var statements = [ 'delete from Position where positionId=?' ];
	var values = [[ obj.positionId ]];
	this.executeSQL(statements, values, callback);
};
/**
* Initiate discourse and enter first message from student
*/
DatabaseAdapter.prototype.insertQuestion = function(obj, callback) {
	var statements = [ 
		'insert into Discourse(discourseId, versionId, status) values (?,?,"open")',
		'insert into Message(discourseId, reference, timestamp, message) values(?,?,?,?)'
	];
	var values = [
		[ obj.discourseId, obj.versionId ],
		[ obj.discourseId, obj.reference, this.getTimestamp(), obj.message ]
	];
	this.executeSQL(statements, values, callback);
};
DatabaseAdapter.prototype.updateQuestion = function(obj, callback) {
	var statements = [ 'update Message set reference=?, message=? where messageId=?' ];
	var values = [[ obj.reference, obj.message, obj.messageId ]];
	this.executeSQL(statements, values, callback);
};
/**
* Needs Discourse.discourseId primary key
* Needs Message.discourseId INDEX and on DELETE CASCADE
*/
DatabaseAdapter.prototype.deleteQuestion = function(obj, callback) {
	var statements = [ 'delete from Discourse where discourseId=?' ];
	var values = [[ obj.discourseId ]];
	this.executeSQL(statements, values, callback);
};
DatabaseAdapter.prototype.openQuestions = function(obj, callback) {
	var statement = 'select count(*), min(m.timestamp) from Discourse d, Message m where d.discourseId=m.discourseId' +
		' and d.status="open" and d.versionId=?';
	this.getSQL(statement, [ obj.versionId ], callback);
};
/**
* Because this method does a select and an update in a transaction, it seemed best to
* not use the helper methods.
*/
DatabaseAdapter.prototype.assignQuestion = function(obj, callback) {
	var that = this;
	this.db.run("begin immediate transaction", [], function(err) {
		var statement = 'select d.discourseId, m.reference, m.timestamp, m.message' +
			' from Discourse d, Message m where d.discourseId=m.discourseId' +
			' and d.versionId = ?' +
			' and d.status="open" order by m.timestamp limit 1';
		that.db.get(statement, obj.versionId, function(err, row) {
			if (err || row === undefined) {
				that.db.run("rollback transaction", [], function(rollErr) {
					callback(rollErr || err);
				});
			} else {
				var statement = 'update Discourse set status="assigned", teacherId=? where discourseId=?';
				that.db.run(statement, obj.teacherId, row.discourseId, function(err) {
					if (err) {
						that.db.run("rollback transaction", [], function(rollErr) {
							callback(rollErr || err);
						});
					} else {
						that.db.run("commit transaction", [], function(err) {
							callback(err, row);
						});
					}
				});
			}
		});
	});
};
DatabaseAdapter.prototype.returnQuestion = function(obj, callback) {
	var statements = [ 'update Discourse set status="open", teacherId=null where discourseId=?' ];
	this.executeSQL(statements, [[ obj.discourseId ]], callback);
};

DatabaseAdapter.prototype.insertAnswer = function(obj, callback) {
	var statements = [
		'insert into Message(discourseId, reference, timestamp, message) values (?,?,?,?)',
		'update Discourse set status="answered", teacherId=? where discourseId=?'
	];
	var values = [
		[ obj.discourseId, obj.reference, this.getTimestamp(), obj.message ],
		[ obj.teacherId, obj.discourseId ]
	];
	this.executeSQL(statements, values, callback);
};
DatabaseAdapter.prototype.updateAnswer = function(obj, callback) {
	var statements = [ 'update Message set reference=?, message=? where messageId=?' ];
	var values = [[ obj.reference, obj.message, obj.messageId ]];
	this.executeSQL(statements, values, callback);
};
DatabaseAdapter.prototype.deleteAnswer = function(obj, callback) {
	var that = this;
	this.db.get('select discourseId from Message where messageId=?', obj.messageId, function(err, row) {
		if (err) {
			callback(err);
		} else if (row) {
			var statements = [ 
				'delete from Message where messageId=?',
				'update Discourse set status="open", teacherId=null where discourseId=?'
			];
			var values = [
				[ obj.messageId ],
				[ row.discourseId ]
			];
			that.executeSQL(statements, values, callback);			
		} else {
			callback(); // No an error, but there were no rows.
		}
	});
};
/**
* This method is called by student to get answered questions, but something must
* set the status to sent. Is than another http transaction, Or should it be done here?
*
* This is returning the student's question as well as the answer, 
* because Message does not mark whose is whose.
*/
DatabaseAdapter.prototype.selectAnswers = function(obj, callback) {
	var statement = 'select t.pseudonym, m.reference, m.timestamp, m.message from Discourse d, Message m, Teacher t' +
		' where d.discourseId = m.discourseId and d.teacherId = t.teacherId and d.discourseId = ? and d.status = "answered"';
	this.db.all(statement, obj.discourseId, function(err, results) {
		callback(err, results);
	});
};
DatabaseAdapter.prototype.replaceDraft = function(obj, callback) {
	var statements = [ 'replace into Message(discourseId, reference, timestamp, message) values (?,?,?,?)' ];
	var values = [[ obj.discourseId, obj.reference, this.getTimestamp(), obj.message ]];
	this.executeSQL(statements, values, callback);
};
DatabaseAdapter.prototype.deleteDraft = function(obj, callback) {
	var statements = [ 'delete from Message where messageId=?' ];
	var values = [[ obj.messageId ]];
	this.executeSQL(statements, values, callback);
};
DatabaseAdapter.prototype.selectDraft = function(obj, callback) {
	var statement = 'select reference, message from Message where messageId=?';
	var values = [ obj.messageId ];
	this.selectSQL(statement, values, callback);
};
DatabaseAdapter.prototype.executeSQL = function(statements, values, callback) {
	// if statements length is not = values length it is an error
	var that = this;
	that.db.run("begin immediate transaction", [], function(err) {
		executeStatement(0);
	});
	
	function executeStatement(index) {
		if (index < statements.length) {
			that.db.run(statements[index], values[index], function(err) {
				if (err) {
					console.log('Has error ', err);
					that.db.run("rollback transaction", [], function(rollErr) {
						callback(rollErr || err);
					});
				} else {
					console.log('lastID', this.lastID, 'changes', this.changes);
					// Do I do something about ID or changes?
					executeStatement(index + 1);
				}
			});
		} else {
			that.db.run("commit transaction", [], function(err) {
				callback(err);
			});
		}
	}
};
DatabaseAdapter.prototype.querySQL = function(statement, values, callback) {
	this.db.all(statement, values, function(err, rows) {
		callback(err, rows);
	});
};
DatabaseAdapter.prototype.getSQL = function(statement, values, callback) {
	this.db.get(statement, values, function(err, row) {
		callback(err, row);
	});
};
DatabaseAdapter.prototype.getTimestamp = function() {
	var date = new Date();
	return(date.toISOString());
};

var database = new DatabaseAdapter({filename: './TestDatabase.db', verbose: true});
//database.create(function(err) { console.log('CREATE ERROR', err); });
var person1 = { teacherId: "ABCDE", fullname: "Gary Griswold", pseudonym: "Gary G", email: "gary@shortsands.com", phone: "513-508-6127", signature: 'XXXX',
	versionId: 'KJV' };
//database.insertTeacher(person1, function(err) { console.log('INSERT ERROR', err); });
var person1rev1 = { teacherId: "ABCDE", fullname: "Gary N Griswold", pseudonym: "Gary", email: "gary@shortsands.us", phone: "513"};
//database.updateTeacher(person1rev1, function(err) { console.log('UPDATE ERROR', err); });
var person1rev2 = { teacherId: "ABCDE" };
//database.deleteTeacher(person1rev2, function(err) { console.log('DELETE ERROR', err); });
var person1rev3 = { teacherId: "ABCDE", versionId: 'WEB', position: 'principal' };
//database.insertPosition(person1rev3, function(err) { console.log('INSERT POS ERROR', err); });
//database.deletePosition({positionId: 2}, function(err) { console.log('DELETE POS ERROR', err); });
var message1 = { discourseId: "KLMN", versionId: 'WEB', studentName: 'Bob Smith', reference: 'JHN:1:1', message: 'What does this mean' };
//database.insertQuestion(message1, function(err) { console.log('INSERT QUESTION', err); });
var message1rev1 = { reference: 'JHN:3', message: 'Now I understand', messageId: 3 };
//database.updateQuestion(message1rev1, function(err) { console.log('UPDATE QUESTION', err); });
var message1rev2 = { discourseId: "KLMN" };
//database.deleteQuestion(message1rev2, function(err) { console.log('DELETE QUESTION', err); });
//database.openQuestions({ versionId: 'WEB' }, function(err, row) { console.log('ERROR', err, ' ROW', row); });
database.assignQuestion({versionId: 'WEB', teacherId: 'ABCDE'}, function(err, row) { console.log('ERROR', err, ' ROW', row ); });
//database.returnQuestion({discourseId: 2}, function(err) { console.log('RETURN ERROR', err); });
var answer1 = { discourseId: 2, reference: 'JHN:3:16', message: 'This is it', teacherId: 'ABCDE' }
//database.insertAnswer(answer1, function(err) { console.log('INSERT ERR', err); });
var answer2 = { messageId: 4, reference: 'JHN:3:17', message: 'There is more' }
//database.updateAnswer(answer2, function(err) { console.log('UPDATE ERR', err); });
var answer3 = { messageId: 4 };
//database.deleteAnswer(answer3, function(err) { console.log('DELETE ERR', err); });
var answer4 = { discourseId: 2 };
//database.selectAnswers(answer4, function(err, results) { console.log('SELECT', err, results); });