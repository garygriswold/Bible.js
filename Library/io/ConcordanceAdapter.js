/**
* This class is the database adapter for the concordance table
*/
function ConcordanceAdapter(database) {
	this.database = database;
	this.className = 'ConcordanceAdapter';
	Object.freeze(this);
}
ConcordanceAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists concordance', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop concordance success', err);
			callback(err);
		}
	});
};
ConcordanceAdapter.prototype.create = function(callback) {

};
ConcordanceAdapter.prototype.load = function(array, callback) {

};
ConcordanceAdapter.prototype.select = function(values, callback) {

};