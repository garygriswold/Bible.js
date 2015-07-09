/**
* This class is the database adapter for the history table
*/
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
HistoryAdapter.prototype.select = function(values, callback) {
};
HistoryAdapter.prototype.insert = function(values, callback) {

};
HistoryAdapter.prototype.delete = function(values, callback) {

};