/**
* This class encapsulates the WebSQL function calls, and exposes a rather generic SQL
* interface so that WebSQL could be easily replaced if necessary.
*/
function DatabaseHelper(dbname, isCopyDatabase) {
	this.dbname = dbname;
	Utility.openDatabase(dbname, isCopyDatabase, function(error) {
		// The error has already been reported in JS glue layer
		// All subsequent access to database will fail, because it is not open.
	});
	Object.seal(this);
}
DatabaseHelper.prototype.select = function(statement, values, callback) {
	console.log("SQL: " + statement + " " + values.join(","));
	Utility.queryJS(this.dbname, statement, values, function(error, results) {
		if (error) {
			callback(new IOError(error));
		} else {
			callback(new ResultSet(results));
		}
	});
};
DatabaseHelper.prototype.executeDML = function(statement, values, callback) {
	Utility.executeJS(this.dbname, statement, values, function(error, rowCount) {
		if (error) {
			callback(new IOError(error));
		} else {
			callback(rowCount);
		}
	});
};
DatabaseHelper.prototype.manyExecuteDML = function(statement, array, callback) {
	var that = this;
	var totalRowCount = 0;
	executeOne(0);
	
	function executeOne(index) {
		if (index < array.length) {
			that.executeDML(statement, array[index], function(error, rowCount) {
				if (results instanceof IOError) {
					callback(results);
				} else {
					totalRowCount += rowCount;
					executeOne(index + 1);
				}
			});
		} else {
			callback(array.length);
		}
	}	
};
DatabaseHelper.prototype.bulkExecuteDML = function(statement, array, callback) {
	var that = this;
    var totalRowCount = 0;
    Utility.executeJS(this.dbname, "BEGIN", [], function(error) {
	    if (error) {
			callback(totalRowCount);
		} else {
	    	executeOne(0);
	    }
    });
    
    function executeOne(index) {
	    if (index < array.length) {
		    Utility.executeJS(that.dbname, statement, array[index], function(error, rowCount) {
			    if (error) {
				    rollback(callback);
			    } else {
				    totalRowCount += rowCount;
				    executeOne(index + 1);
			    }
		    });
	    } else {
		    Utility.executeJS(that.dbname, "COMMIT", [], function(error) {
			    if (error) {
				    rollback(callback);
			    } else {
				    callback(totalRowCount);
			    }
		    });
	    }
    }
    
    function rollback(callback) {
	    Utility.executeJS(that.dbname, "ROLLBACK", [], function(error) {
		    if (error) {
			    callback(new IOError(error));
		    } else {
			    callback(0);
		    }
	    });
    }
};
DatabaseHelper.prototype.executeDDL = function(statement, callback) {
	Utility.executeJS(this.dbname, statement, [], function(error, rowCount) {
		if (error) {
			callback(new IOError(error));
		} else {
			callback(rowCount);
		}
	});
};
DatabaseHelper.prototype.close = function() {
	Utility.closeDatabase(this.dbname, function(error) {
		// The error has already been logged in the JS glue layer
	});
};
/** A smoke test is needed before a database is opened. */
/** A second more though test is needed after a database is opened.*/
DatabaseHelper.prototype.smokeTest = function(callback) {
    var statement = 'select count(*) from tableContents';
    this.select(statement, [], function(results) {
        if (results instanceof IOError) {
            console.log('found Error', JSON.stringify(results));
            callback(false);
        } else if (results.rows.length === 0) {
            callback(false);
        } else {
            var row = results.rows.item(0);
            console.log('found', JSON.stringify(row));
            var count = row['count(*)'];
            console.log('count=', count);
            callback(count > 0);
        }
    });
};

function ResultSet(results) {
	this.rows = new RowItems(results);
}
function RowItems(results) {
	this.rows = JSON.parse(results);
	console.log("RESULTS: " + JSON.stringify(this.rows));
	this.length = this.rows.length;
	console.log("LENGTH: " + this.length);
}
RowItems.prototype.item = function(index) {
	return(this.rows[index]);
};

