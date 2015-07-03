/**
* This class is a facade over the database that is used to store bible text, concordance,
* table of contents, history and questions.  At this writing, it is a facade over a
* Web SQL Sqlite3 database, but it intended to hide all database API specifics
* from the rest of the application so that a different database can be put in its
* place, if that becomes advisable.
* Gary Griswold, July 2, 2015
*/
function DeviceDatabase(code, name) {
	this.code = code;
	this.name = name;
	var size = 30 * 1024 * 1024;
	this.db = window.openDatabase(this.code, "1.0", this.name, size);
	this.concordance = new DeviceCollection('concordance');
	// access database
	// this should access a database, or create
	// if it does not exist.  It should create all tables and all indexes
	// unless index creation is postponed until all data is loaded.
	Object.seal(this);
}
DeviceDatabase.prototype.open = function(callback) {
    this.db.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
        tx.executeSql('create table if not exists concordance(word text, referenceList text)');
 		//tx.executeSql('.databases', [], function(tx, results) {
 		//	var len = results.rows.length;
 		//	for (var i=0; i<len; i++) {
 		//		console.log('found', results.rows.item(i));
 		//	}
 		//});
    }
    function onTranError(err) {
        console.log('tran error', JSON.stringify(err));
        callback(err);
    }
    function onTranSuccess() {
        console.log('transaction completed');
        callback(null);
    }
};
DeviceDatabase.prototype.drop = function(callback) {
	// This should drop the specific database
};
DeviceDatabase.prototype.index = function() {
	// This should index all of the tables.  It is called after tables are loaded.
};



/* 
Lawnchair:
keys(callback)
save(obj, callback)
batch(array, callback)
get(key|array, callback)
exists(key, callback)
each(callback)
all(callback)
remove(key|array, callback)
*/