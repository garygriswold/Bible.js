/*
DatabaseHelper
  line 7 Utility.openDatabase(dbname, isCopyDatabase, function(error) {}) returns error, if occur, else null
  line 14 Utility.queryJS(dbname, statement, values, function(error, results) {}) returns error, if occurs
  line 23 Utility.executeJS(dbname, statement, values, function(error, rowCount) {}) returns error, if occurs
  line 32 Utility.bulkExecuteJS(dbname, statement, array, function(error, rowCount) {}) returns error, if occurs
  line 41 Utility.executeJS(dbname, statement, [], function(error, rowCount) {}) returns error, if occurs
  line 50 Utility.closeDatabase(dbname, function() {}) no error can occur

AppUpdater
  line 127 Utility.listDB(function(files) {}) returns [], if error occurs
  line 181 Utility.deleteDB(file, function(error) {}) returns error, if occurs, else null
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
		var resultSet = JSON.parse(results);
		if (assert((resultSet.length > 10 && resultSet.length < 30), "Query 2 should have many rows")) {
			var database = 'Versions.db';
			var statement = 'select * from Identity where versionCode = ?';
			var values = ['ERV-ENG'];
			callNative('Sqlite', 'queryJS', 'queryJSHandler3', [database, statement, values]);
		}
	}
}
function queryJSHandler3(error, results) {
	if (assert((error == null), "Query 3 should succeed")) {
		var resultSet = JSON.parse(results);
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
	if (assert((error), "execute should produce an error")) {
		var database = 'Versions.db';
		var statement = 'CREATE TABLE TEST1(abc TEXT, def INT)';
		var values = [];
		callNative('Sqlite', 'executeJS', 'executeJSHandler9', [database, 'DROP TABLE IF EXISTS TEST1', []]);
		callNative('Sqlite', 'executeJS', 'executeJSHandler2', [database, statement, values]);
	}
}
function executeJSHandler9(error, rowCount) {
	
}
function executeJSHandler2(error, rowCount) {
	if (!assert(error, error)) {
		if (assert((rowCount == 0), "rowcount should be zero")) {
			var database = 'Versions.db';
			var statement = 'INSERT INTO TEST1 VALUES (?, ?)';
			var values = [['abc', 1], ['def', 2], ['ghi', 3]];
			callNative('Sqlite', 'bulkExecuteJS', 'bulkExecuteJSHandler', [database, statement, values]);
		}
	}
}
function bulkExecuteJSHandler(error, rowCount) {
	log(error);
	if (!assert(error, error)) {
		if (assert((rowCount == 3), "rowcount should be 3")) {
			callNative('Sqlite', 'closeDB', 'closeDBHandler1', ['NoDB']);
		}
	}
}
function closeDBHandler1() {
	callNative('Sqlite', 'executeJS', 'dropTableHandler', ['Versions.db', 'DROP TABLE TEST1', []]);
}
function dropTableHandler(error, rowCount) {
	if (!assert(error, error)) {
		callNative('Sqlite', 'closeDB', 'closeDBHandler2', ['Versions.db']);
	}
}
function closeDBHandler2(error) {
	//if (assert((error == null), "CloseDB error should be null")) {
	callNative('Sqlite', 'openDB', 'openDBHandler9', ['Temp.db', false]);
	callNative('Sqlite', 'listDB', 'listDBHandler', []);
	//}
}
function openDBHandler9(error) {
	
}
function listDBHandler(files) {
	log(files);
	var filesArray = JSON.parse(files);
	if (assert(filesArray, 'There should be a files result')) {
		if (assert(filesArray.length > 1), "There should be multiple files") {
			var file = filesArray[0];
			if (assert((file == 'Temp.db'), 'The first file should be Temp.db')) {
				callNative('Sqlite', 'closeDB', 'closeDBHandler99', ['Temp.db']);
				callNative('Sqlite', 'deleteDB', 'deleteDBHandler', ['Temp.db']);
			}
		}
	}
}
function closeDBHandler99() {
	
}
function deleteDBHandler(error) {
	if (assert((error == null), error)) {
		log('Sqlite Test Done');
	}
}
