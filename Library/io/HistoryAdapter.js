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
			console.log('drop history success', err);
			callback(err);
		}
	});
};
HistoryAdapter.prototype.create = function(callback) {

};
HistoryAdapter.prototype.select = function(values, callback) {

};
HistoryAdapter.prototype.insert = function(values, callback) {

};
HistoryAdapter.prototype.delete = function(values, callback) {

};