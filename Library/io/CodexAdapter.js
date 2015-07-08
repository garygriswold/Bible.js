/**
* This class is the database adapter for the codex table
*/
function CodexAdapter(database) {
	this.database = database;
	this.className = 'CodexAdapter';
	Object.freeze(this);
}
CodexAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists codex', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop codex success', err);
			callback(err);
		}
	});
};
CodexAdapter.prototype.create = function(callback) {

};
CodexAdapter.prototype.load = function(array, callback) {

};
CodexAdapter.prototype.getChapter = function(values, callback) {

};