/*
DatabaseHelper
  line 7 Utility.openDatabase(dbname, isCopyDatabase, function(error) {})
  line 14 Utility.queryJS(dbname, statement, values, function(error, results) {})
  line 23 Utility.executeJS(dbname, statement, values, function(error, rowCount) {})
  line 32 Utility.bulkExecuteJS(dbname, statement, array, function(error, rowCount) {})
  line 41 Utility.executeJS(dbname, statement, [], function(error, rowCount) {})
  line 50 Utility.closeDatabase(dbname, function(error) {})

AppUpdater
  line 127 Utility.listDB(function(files) {})
  line 181 Utility.deleteDB(file, function(error) {})
*/
function testSqlite() {
	callNative('Sqlite', 'openDB', 'openDBHandler', ['Versions.db', true]);
}
function openDBHandler(error) {
	if (assert((error == null), "openDB should return true")) {
		var database = 'Versions.db';
		var statement = 'select count(*) from bob';
		var values = [];
		callNative('Sqlite', 'queryJS', 'queryJSHandler1', [database, statement, values]);
	}
}
function queryJSHandler1(error, results) {
	if (assert(error, "Query should produce an error")) {
		var database = 'Versions.db';
		var statement = 'select * from Identity';
		var values = [];
		callNative('Sqlite', 'queryJS', 'queryJSHandler2', [database, statement, values]);
	}
}
function queryJSHandler2(error, results) {
	if (assert((error == null), "Query 2 should succeed")) {
		var resultSet = JSONParse(results);
		if (assert((results.length > 10 && results.length < 30), "Query 2 should have many rows")) {
			var database = 'Versions.db';
			var statement = 'select * from Identity where versionCode = ?';
			var values = ['ERV-ENG'];
			callNative('Sqlite', 'queryJS', 'queryJSHandler3', [database, statement, values]);
		}
	}
}
function queryJSHandler3(error, results) {
	if (assert((error == null), "Query 3 should succeed")) {
		var resultSet = JSONParse(results);
		if (assert((resultSet.length == 1), "Query 3 should return 1 row.")) {
			var row = resultSet[0];
			if (assert((row.filename == "ERV-ENG.db"), "Query 3 should have filename ERV-ENG.db")) {
			var database = 'Versions.db';
			var statement = 'INSERT INTO NoTable VALUES (?)';
			var values = ['ERV-ENG'];				
				callNative('Sqlite', 'executeJS', 'executeJSHandler1', [database, statement, values]);
			}
		}
	}
}
function executeJSHandler1(error, rowCount) {
	if (assert(error, "execute should produce an error")) {
		var database = 'Versions.db';
		var statement = 'CREATE TABLE TEST1(abc TEXT, def INT)';
		var values = [];		
		callNative('Sqlite', 'executeJS', 'executeJSHandler2', []);
	}
}
function executeJSHandler2(error, rowCount) {
	if (!assert(error, error)) {
		if (assert((rowCount == 1), "rowcount should be 1 or zero")) {
			var database = 'Versions.db';
			var statement 'INSERT INTO TEST1 VALUES (?, ?)';
			var values = [['abc', 1], ['def', 2], ['ghi', 3]];
			callNative('Sqlite', 'bulkExecuteJS', 'bulkExecuteJSHandler', [database, statement, values]);
		}
	}
}
function executeBulkExecuteJSHandler(error, rowCount) {
	if (!assert(error, error)) {
		if (assert((rowCount == 3), "rowcount should be 3")) {
			callNative('Sqlite', 'closeDB', 'closeDBHandler1', ['NoDB']);
		}
	}
}
function closeDBHandler1(error) {
	if (assert(error, 'close should fail db does not exists')) {
		callNative('Sqlite', 'executeJS', 'dropTableHandler', ['Versions.db', 'DROP TABLE TEST1', []]);
	}
}
function dropTableHandler(error, rowCount) {
	if (!assert(error, error)) {
		callNative('Sqlite', 'closeDB', 'closeDBHandler2', ['Versions.db']);
	}
}
function closeDBHandler2(error) {
	if (assert((error == null), "CloseDB error should be null")) {
		callNative('Sqlite', 'listDB', 'listDBHandler', []);
	}
}
function listDBHandler(files) {
	if (assert(files, 'There should be a files result')) {
		if (assert(files.length > 1), "There should be multiple files");
			var file = files[1];
			if (assert((file == 'Temp.db'), 'The second file should be Temp.db')) {
				callNative('Sqlite', 'deleteDB', 'deleteDBHandler', ['Temp.db'])l
			}
		}
	}
}
function deleteDBHandler(error) {
	if (!assert(error, error)) {
		console.log('Sqlite Test Done');
	}
}
