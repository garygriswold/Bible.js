/**
* This class is a facade over a collection in a database.  
* At this writing, it is a facade over a Web SQL Sqlite3 database, 
* but it intended to hide all database API specifics
* from the rest of the application so that a different database can be put in its
* place, if that becomes advisable.
* Gary Griswold, July 2, 2015
*/
function DeviceCollection(table) {

}
DeviceDatabase.prototype.load = function(array, callback) {
	// This might just iterate over the collection and call insert
	// for each row.
};
DeviceDatabase.prototype.insert = function(row, callback) {
	// This should have the sql for an insert statement for each table
	// It could have variants that use a different table name
	// row is a single object of name/value pairs that translate into
	// a sql insert statement
};
DeviceDatabase.prototype.update = function(key, row, callback) {
	// This should create an update statement from the element names 
};
DeviceDatabase.prototype.replace = function(key, row, callback) {
	//This differs from insert and update in that it does not care whether
	// the row already exists.
};
DeviceDatabase.prototype.delete = function(key, callback) {
	// This should delete the row for the key specified in the row object
};
DeviceDatabase.prototype.get = function(key, callback) {
	// This should get the single row, which satisfies that fields in key object
};
DeviceDatabase.prototype.find = function(condition, projection, callback) {
	// This should return a result set of rows
};