/**
* This class is the database adapter for the styleUse table
*/
function StyleUseAdapter(database) {
	this.database = database;
	this.className = 'StyleUseAdapter';
	Object.freeze(this);
}
StyleUseAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists styleUse', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop styleUse success', err);
			callback(err);
		}
	});
};
StyleUseAdapter.prototype.create = function(callback) {

};
StyleUseAdapter.prototype.load = function(array, callback) {

};