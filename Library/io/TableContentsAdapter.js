/**
* This class is the database adapter for the tableContents table
*/
function TableContentsAdapter(database) {
	this.database = database;
	this.className = 'TableContentsAdapter';
	Object.freeze(this);
}
TableContentsAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists tableContents', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop tableContents success', err);
			callback(err);
		}
	});
};
TableContentsAdapter.prototype.create = function(callback) {

};
TableContentsAdapter.prototype.load = function(array, callback) {

};
TableContentsAdapter.prototype.select = function(values, callback) {

};