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
	callNative('Sqlite', 'openDB', ['Versions.db', true], "E", function(error) {
		if (assert((error === null), "openDB should return true")) {
			testQueryJS();
		}
	});
}
function testQueryJS() {
	var database = 'Versions.db';
	var statement = 'select count(*) from bob';
	var values = [];
	callNative('Sqlite', 'queryJS', [database, statement, values], "ES", function(error, results) {
		if (assert(error, "Query should produce an error")) {
			testQueryJS2();
		}
	});
}
function testQueryJS2() {
	var database = 'Versions.db';
	var statement = 'select * from Identity';
	var values = [];
	callNative('Sqlite', 'queryJS', [database, statement, values], "ES", function(error, results) {
		if (assert((error == null), "Query 2 should succeed")) {
			if (assert((results.length > 10 && results.length < 30), "Query 2 should have many rows")) {
				testQueryJS3();
			}
		}
	});
}
function testQueryJS3() {
	var database = 'Versions.db';
	var statement = 'select * from Identity where versionCode = ?';
	var values = ['ERV-ENG'];
	callNative('Sqlite', 'queryJS', [database, statement, values], "ES", function(error, results) {
		if (assert((error == null), "Query 3 should succeed")) {
			if (assert((results.length == 1), "Query 3 should return 1 row.")) {
				var row = results[0];
				if (assert((row.filename == "ERV-ENG.db"), "Query 3 should have filename ERV-ENG.db")) {
					testExecuteJS1();
				}
			}
		}	
	});
}
function testExecuteJS1() {
	var database = 'Versions.db';
	var statement = 'INSERT INTO NoTable VALUES (?)';
	var values = ['ERV-ENG'];				
	callNative('Sqlite', 'executeJS', [database, statement, values], "ES", function(error, rowCount) {
		if (assert((error), "execute should produce an error")) {
			testExecuteJS2();
		}	
	});
}
function testExecuteJS2() {
	var database = 'Versions.db';
	var statement = 'CREATE TABLE TEST1(abc TEXT, def INT)';
	var values = [];
	callNative('Sqlite', 'executeJS', [database, 'DROP TABLE IF EXISTS TEST1', values], "ES", function(error, rowCount) {
		callNative('Sqlite', 'executeJS', [database, statement, values], "ES", function(error, rowCount) {
			if (!assert(error, error)) {
				if (assert((rowCount === 0), "rowcount should be zero")) {
					testExecuteBulkJS1();
				}
			}
		});
	});
	
}

function testExecuteBulkJS1() {
	var database = 'Versions.db';
	var statement = 'INSERT INTO TEST1 VALUES (?, ?)';
	var values = [['abc', 1], ['def', 2], ['ghi', 3]];
	callNative('Sqlite', 'bulkExecuteJS', [database, statement, values], "ES", function(error, rowCount) {
		if (!assert(error, error)) {
			if (assert((rowCount == 3), "rowcount should be 3")) {
				testCloseDB();
			}
		}	
	});
}
function testCloseDB() {
	callNative('Sqlite', 'closeDB', ['NoDB'], "E", function(error) {
		testCloseDB2();
	});
}
function testCloseDB2() {
	callNative('Sqlite', 'closeDB', ['Versions.db'], "E", function(error) {
		testListDB();
	});
}
function testListDB() {
	callNative('Sqlite', 'openDB', ['Temp.db', false], "E", function(error) {
		callNative('Sqlite', 'listDB', [], "S", function(results) {
			if (assert(results, 'There should be a files result')) {
				if (assert(results.length > 1), "There should be multiple files") {
					var file = results[0];
					if (assert((file == 'Temp.db'), 'The first file should be Temp.db')) {
						testDeleteDb();
					}
				}
			}
		});
	});
}
function testDeleteDb() {
	callNative('Sqlite', 'closeDB', ['Temp.db'], "E", function(error) {
		callNative('Sqlite', 'deleteDB', ['Temp.db'], "E", function(error) {
			if (assert((error == null), error)) {
				log('Sqlite Test Done');
			}
		});
	});
}
