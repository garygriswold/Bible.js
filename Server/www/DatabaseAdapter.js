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
	if (options.verbose) {
		this.db.on('trace', function(sql) {
			console.log('DO ', sql);
		});
		this.db.on('profile', function(sql, ms) {
			console.log(ms, 'DONE', sql);
		});
	}
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
			' versionId text NOT NULL,' + // may reference a Version table
			' teacherId text REFERENCES Teacher(teacherId) ON DELETE CASCADE NOT NULL,' +
			' position text check(position in ("teacher", "principal", "super", "removed")) NOT NULL,' +
			' PRIMARY KEY(versionId, teacherId))',
			
		'CREATE INDEX PositionTeacherId ON Position(teacherId)',
		
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
	this.executeSQL(statements, values, 0, callback);
	
	// Message primary key could be discourseId + timestamp
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
	this.executeSQL(statements, values, 2, callback);
};
/**
* Needs primary key Teacher.teacherId
* If I need to update individual fields, then I will need to change this to generate SQL
*/
DatabaseAdapter.prototype.updateTeacher = function(obj, callback) {
	var statements = [ 'update Teacher set fullname=?, pseudonym=? where teacherId=?' ];
	var values = [[ obj.fullname, obj.pseudonym, obj.teacherId ]];
	this.executeSQL(statements, values, 1, callback);
};
/**
* Needs primary key Teacher.teacherId
* Requires Position.teacherId to be on delete cascade
* Needs index on Position(teacherId)
*/
DatabaseAdapter.prototype.deleteTeacher = function(obj, callback) {
	var statements = [ 'delete from Teacher where teacherId = ?' ];
	var values = [[ obj.teacherId ]];
	this.executeSQL(statements, values, 1, callback);
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
	this.executeSQL(statements, values, 1, callback);
};
DatabaseAdapter.prototype.updatePosition = function(obj, callback) {
	var statements = [ 'update Position set position=? where teacherId=? and versionId=?' ];
	var values = [[ obj.position, obj.teacherId, obj.versionId ]];
	this.executeSQL(statements, values, 1, callback);	
};
DatabaseAdapter.prototype.deletePosition = function(obj, callback) {
	var statements = [ 'delete from Position where teacherId=? and versionId=?' ];
	var values = [[ obj.teacherId, obj.versionId ]];
	this.executeSQL(statements, values, 1, callback);
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
	this.executeSQL(statements, values, 2, callback);
};
DatabaseAdapter.prototype.updateQuestion = function(obj, callback) {
	var statements = [ 'update Message set reference=?, message=? where messageId=?' ];
	var values = [[ obj.reference, obj.message, obj.messageId ]];
	this.executeSQL(statements, values, 1, callback);
};
/**
* Needs Discourse.discourseId primary key
* Needs Message.discourseId INDEX and on DELETE CASCADE
*/
DatabaseAdapter.prototype.deleteQuestion = function(obj, callback) {
	var statements = [ 'delete from Discourse where discourseId=?' ];
	var values = [[ obj.discourseId ]];
	this.executeSQL(statements, values, 1, callback);
};
DatabaseAdapter.prototype.openQuestionCount = function(obj, callback) {
	var statement = 'select count(*) as count, min(m.timestamp) as timestamp from Discourse d, Message m where d.discourseId=m.discourseId' +
		' and d.status="open" and d.versionId=?';
	this.db.get(statement, obj.versionId, callback);
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
			if (err) {
				that.db.run("rollback transaction", [], function(rollErr) {
					callback(err);
				});
			} else if (row === undefined) {
				that.db.run("rollback transaction", [], function(rollErr) {
					callback(new Error('There are no questions to assign.'));
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
/**
* This function is called to return an assignment if one exists for the teacher, or none.
*/
DatabaseAdapter.prototype.getAssignment = function(obj, callback) {
	var statement = 'SELECT d.discourseId, d.versionId, m.messageId, m.reference, m.timestamp, m.message' +
			' FROM Discourse d JOIN Message m ON d.discourseId=m.discourseId' +
			' WHERE d.teacherId = ?' +
			' AND d.status = "assigned"' +
			' ORDER BY m.timestamp'; // keep question row before answer row
	this.db.all(statement, obj.teacherId, callback);
};
DatabaseAdapter.prototype.returnQuestion = function(obj, callback) {
	var statements = [ 'update Discourse set status="open", teacherId=null where discourseId=?' ];
	this.executeSQL(statements, [[ obj.discourseId ]], 1, callback);
};

DatabaseAdapter.prototype.insertAnswer = function(obj, callback) {
	var statements = [
		'insert into Message(discourseId, reference, timestamp, message) values (?,?,?,?)',
		'update Discourse set status="answered", teacherId=? where discourseId=? and status="assigned"'
	];
	var values = [
		[ obj.discourseId, obj.reference, this.getTimestamp(), obj.message ],
		[ obj.teacherId, obj.discourseId ]
	];
	this.executeSQL(statements, values, 2, callback);
};
DatabaseAdapter.prototype.updateAnswer = function(obj, callback) {
	var statements = [ 'update Message set reference=?, message=? where messageId=?' ];
	var values = [[ obj.reference, obj.message, obj.messageId ]];
	this.executeSQL(statements, values, 1, callback);
};
DatabaseAdapter.prototype.deleteAnswer = function(obj, callback) {
	var that = this;
	this.db.get('select discourseId from Message where messageId=?', obj.messageId, function(err, row) {
		if (err) {
			callback(err);
		} else if (row === undefined) {
			callback(new Error("expected=1  actual=0"));
		} else {
			var statements = [ 
				'delete from Message where messageId=?',
				'update Discourse set status="open", teacherId=null where discourseId=?'
			];
			var values = [
				[ obj.messageId ],
				[ row.discourseId ]
			];
			that.executeSQL(statements, values, 2, callback);			
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
DatabaseAdapter.prototype.selectAnswer = function(obj, callback) {
	var statement = 'select t.pseudonym, m.reference, m.timestamp, m.message from Discourse d, Message m, Teacher t' +
		' where d.discourseId = m.discourseId and d.teacherId = t.teacherId and d.discourseId = ? and d.status = "answered"';
	this.db.all(statement, obj.discourseId, callback);
};
DatabaseAdapter.prototype.insertDraft = function(obj, callback) {
	var statements = [ 'insert into Message(discourseId, reference, timestamp, message) values (?,?,?,?)' ];
	var values = [[ obj.discourseId, obj.reference, this.getTimestamp(), obj.message ]];
	this.executeSQL(statements, values, 1, callback);
};
DatabaseAdapter.prototype.updateDraft = function(obj, callback) {
	var statements = [ 'update Message set reference=?, timestamp=?, message=? where messageId=?' ];
	var values = [[ obj.reference, this.getTimestamp(), obj.message, obj.messageId ]];
	this.executeSQL(statements, values, 1, callback);
};
DatabaseAdapter.prototype.deleteDraft = function(obj, callback) {
	var statements = [ 'delete from Message where messageId=?' ];
	var values = [[ obj.messageId ]];
	this.executeSQL(statements, values, 1, callback);
};
DatabaseAdapter.prototype.selectDraft = function(obj, callback) {
	var statement = 'select reference, message from Message where messageId=?';
	this.db.get(statement, obj.messageId, callback);
};
DatabaseAdapter.prototype.executeSQL = function(statements, values, affectedRows, callback) {
	if (statements.length !== values.length) {
		callback(new Error('Incorrect number of value array, expected=' + statements.length + ', found=' + values.length));
	} else {
		var rowCount = 0;
		var lastID = null;
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
						rowCount += this.changes;
						lastID = this.lastID || lastID;
						console.log('lastID', this.lastID, 'changes', this.changes);
						executeStatement(index + 1);
					}
				});
			} else {
				if (affectedRows >= 0 && affectedRows !== rowCount) {
					var err = new Error('expected=' + affectedRows + '  actual=' + rowCount);
					that.db.run("rollback transaction", [], function(rollErr) {
						callback(rollErr || err);
					});
				} else {
					that.db.run("commit transaction", [], function(err) {
						callback(err, {rowCount: rowCount, lastID: lastID});
					});
				}
			}
		}
	}
};
DatabaseAdapter.prototype.getTimestamp = function() {
	var date = new Date();
	return(date.toISOString());
};

//var database = new DatabaseAdapter({filename: './TestDatabase.db', verbose: true});
//database.create(function(err) { console.log('CREATE ERROR', err); });

module.exports = DatabaseAdapter;