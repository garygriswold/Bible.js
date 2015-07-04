/**
* This class is a facade over a collection in a database.  
* At this writing, it is a facade over a Web SQL Sqlite3 database, 
* but it intended to hide all database API specifics
* from the rest of the application so that a different database can be put in its
* place, if that becomes advisable.
* Gary Griswold, July 2, 2015
*/
function DeviceCollection(database, table) {
	this.database = database;
	this.table = table;
	Object.freeze(this);
}
DeviceCollection.prototype.load = function(names, array, callback) {
	var that = this;
	if (names && array && array.length > 0) {
		this.database.transaction(onTranStart, onTranError, onTranSuccess);
	}
    function onTranStart(tx) {
  		var statement = that.insertStatement(names);
  		console.log(statement);
  		for (var i=0; i<array.length; i++) {
        	tx.executeSql(statement, array[i]);
        }
    }
    function onTranError(err) {
        console.log('load tran error', JSON.stringify(err));
        callback(err);
    }
    function onTranSuccess() {
        console.log('load transaction completed');
        callback();
    }
};
DeviceCollection.prototype.insert = function(row, callback) {
	var that = this;
	if (row) {
		this.database.transaction(onTranStart, onTranError, onTranSuccess);
	}
    function onTranStart(tx) {
    	var names = Object.keys(row);
		var statement = that.insertStatement(names);
		var values = that.valuesToArray(names, row);
  		console.log(statement);
        tx.executeSql(statement, values);
    }
    function onTranError(err) {
        console.log('insert tran error', JSON.stringify(err));
        callback(err);
    }
    function onTranSuccess() {
        console.log('insert transaction completed');
        callback();
    }
};
DeviceCollection.prototype.insertStatement = function(names) {
	var sql = [ 'insert into ', this.table, ' (' ];
	for (var i=0; i<names.length; i++) {
		if (i > 0) {
			sql.push(', ');
		}
		sql.push(names[i]);
	}
	sql.push(') values (');
	for (var i=0; i<names.length; i++) {
		if (i > 0) {
			sql.push(',');
		}
		sql.push('?');
	}
	sql.push(')');
	return(sql.join(''));
};
DeviceCollection.prototype.update = function(key, row, callback) {
	// This should create an update statement from the element names 
};
DeviceCollection.prototype.replace = function(key, row, callback) {
	//This differs from insert and update in that it does not care whether
	// the row already exists.
};
DeviceCollection.prototype.delete = function(key, callback) {
	// This should delete the row for the key specified in the row object
};
DeviceCollection.prototype.get = function(key, callback) {
	// This should get the single row, which satisfies that fields in key object
};
DeviceCollection.prototype.find = function(condition, projection, callback) {
	// This should return a result set of rows
};
DeviceCollection.prototype.valuesToArray = function(names, row) {
	var values = [ names.length ];
	for (var i=0; i<names.length; i++) {
		values[i] = row[names[i]];
	}
	return(values);
};