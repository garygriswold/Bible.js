/**
* This class is the database adapter for the history table
*/
var MAX_HISTORY = 20;

function HistoryAdapter(database) {
	this.database = database;
	this.className = 'HistoryAdapter';
	Object.freeze(this);
}
HistoryAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists history', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop history success');
			callback();
		}
	});
};
HistoryAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists history(' +
		'timestamp text not null primary key, ' +
		'book text not null, ' +
		'chapter integer not null, ' +
		'verse integer null, ' +
		'source text not null, ' +
		'search text null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create history success');
			callback();
		}
	});
};
HistoryAdapter.prototype.selectAll = function(callback) {
	var statement = 'select timestamp, book, chapter, verse, source, search ' +
		'from history order by timestamp desc limit ?';
	this.database.select(statement, [ MAX_HISTORY ], function(results) {
		if (results instanceof IOError) {
			callback();
		} else {
			callback(results);
		}
	});
};
HistoryAdapter.prototype.replace = function(values, callback) {
	var statement = 'replace into history(timestamp, book, chapter, verse, source, search) ' +
		'values (?,?,?,?,?,?)';
	this.database.executeDML(statement, values, function(count) {
		if (count instanceof IOError) {
			console.log('replace error', JSON.stringify(count));
			callback();
		} else {
			callback(count);
		}
	});
};
HistoryAdapter.prototype.delete = function(values, callback) {
	// Will be needed to prevent growth of history
};