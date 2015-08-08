/**
* This class is a facade over the database that is used to store bible text, concordance,
* table of contents, history and questions.
*
* This file is the DeviceDatabaseNative file, which implements the interface by Nathan Anderson
* https://github.com/nathanaela/nativescript-sqlite
*/

var IOError = require('./IOError');
var ChaptersAdapter = require('./ChaptersAdapter');

function DeviceDatabase(code) {
	this.code = code;
    this.className = 'DeviceDatabaseNative';
    this.database = null;
    this.chapters = new ChaptersAdapter(this);
//    this.verses = new VersesAdapter(this);
//    this.tableContents = new TableContentsAdapter(this);
//    this.concordance = new ConcordanceAdapter(this);
//    this.styleIndex = new StyleIndexAdapter(this);
//    this.styleUse = new StyleUseAdapter(this);
//    this.history = new HistoryAdapter(this);
//    this.questions = new QuestionsAdapter(this);
    Object.seal(this);
}
DeviceDatabase.prototype.open = function(callback) {
    var that = this;
    // We need to refine the path to be a no-cache path
    // We need to copy the database from Resources if not present in Documents/Library
    // Should we change the interface to have an open command so that it can have a callback
    var Sqlite = require('nativesqlite');
    var promise = new Sqlite(this.code, function(err, db) {
        if (err) { 
            console.error("We failed to open database", err);
            callback(new IOError(err));
            // callback IOError
        } else {
            // This should ALWAYS be true, db object is open in the "Callback" if no errors occurred
            console.log("Are we open yet (Inside Callback)? ", db.isOpen() ? "Yes" : "No"); // Yes
            that.database = db;
            console.log('set database');
            that.database.resultType = Sqlite.RESULTASOBJECT;
            console.log('set result type');
            callback();
            console.log('after open callback');
        }
    });
}
DeviceDatabase.prototype.select = function(statement, values, callback) {
    this.database.all(statement, values, function(err, resultSet) {
        if (err) {
            callback(new IOError(err));
        } else {
            console.log("Result set is:", resultSet);
            callback(resultSet);
        }
    });
};
DeviceDatabase.prototype.get = function(statement, values, callback) {
    this.database.get(statement, values, function(err, row) {
        console.log('ERROR AFTER GET', JSON.stringify(err));
        if (err) {
            callback(new IOError(err));
        } else {
            console.log("Row is:", row);
            callback(row);
        }
    });
};
DeviceDatabase.prototype.executeDML = function(statement, values, callback) {
    this.database.execSQL(statement, [], function(err, count) {
        if (err) {
            callback(new IOError(err));
        } else {
            console.log("Update Count:", count);
            callback(count);
        }
    });
};
DeviceDatabase.prototype.bulkExecuteDML = function(statement, array, callback) {
    // Not implemented on Native
};
DeviceDatabase.prototype.executeDDL = function(statement, callback) {
    this.database.execSQL(statement, [], function(err, whatIsIt) {
        if (err) {
            callback(new IOError(err));
        } else {
            console.log("What is it:", id);
            callback(whatIsIt);
        }
    });
};
DeviceDatabase.prototype.close = function() {
    this.database.close();
};
module.exports = DeviceDatabase;
