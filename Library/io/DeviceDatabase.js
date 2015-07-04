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
	this.concordance = new DeviceCollection(this.db, 'concordance');
	Object.freeze(this);
}
DeviceDatabase.prototype.create = function(callback) {
    this.db.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
    	tx.executeSql('drop table if exists concordance');
    	var concordSQL = 'create table if not exists concordance' +
    		'(word text primary key, refCount integer, refList text)';
        tx.executeSql(concordSQL);
    }
    function onTranError(err) {
        console.log('tran error', JSON.stringify(err));
        callback(err);
    }
    function onTranSuccess() {
        console.log('transaction completed');
        callback();
    }
};
DeviceDatabase.prototype.drop = function(callback) {
	this.db.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
    	tx.executeSql('drop table if exists concordance');
    }
    function onTranError(err) {
        console.log('drop tran error', JSON.stringify(err));
        callback(err);
    }
    function onTranSuccess() {
        console.log('drop transaction completed');
        callback();
    }
};
DeviceDatabase.prototype.index = function() {
	// This should index all of the tables.  It is called after tables are loaded.
};

