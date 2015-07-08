/**
* This class is the database adapter for the styleIndex table
*/
function StyleIndexAdapter(database) {
	this.database = database;
	this.className = 'StyleIndexAdapter';
	Object.freeze(this);
}
StyleIndexAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists styleIndex', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop styleIndex success', err);
			callback(err);
		}
	});
};
StyleIndexAdapter.prototype.create = function(callback) {

};
StyleIndexAdapter.prototype.load = function(array, callback) {

};