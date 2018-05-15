"use strict";
function assert(condition, plugin, method, message) {
	if (!condition) {
		var out = plugin + '.' + method + " failed: " + message;
		var response = document.getElementById("response");
		response.innerHTML = out;
		return false;
	} else {
		return true;
	}
}
function log(message) {
	var locale = document.getElementById('locale');
	locale.innerHTML = message;
}/**
cordovaDeviceSettings
  line 11 Utility.locale(function(results) {}) no error possible, should return null if it did happen
  line 16 Utility.locale(function(results) {}) no error possible, should return null if it did happen
  line 25 Utility.platform(function(platform) {}) no error possible, should return null if it did happen
  line 28 Utility.modelName(function(model) {}) no error possible, should return null if it did happen

SearchView
  line 86 Utility.hideKeyboard(function(hidden) {}) if error, returns false
*/
function testUtility() {
	var e = document.getElementById("locale");
	e.innerHTML = "inside testUtility";
	callNative('Utility', 'locale', 'localeHandler', []);
}
function localeHandler(locale) {
  var loc = JSON.parse(locale);
  if (assert((loc.length == 4), 'Utility', 'locale', 'should be 4 element')) {
	  if (assert((loc[0] == "en_US"), 'Utility', 'locale', 'first part should be en_USx')) {
	  	callNative('Utility', 'platform', 'platformHandler', []);
	  }
  }
}
function platformHandler(platform) {
   if (assert((platform == "iOS"), 'Utility', 'platform', 'should be ios')) {
    callNative('Utility', 'modelName', 'modelNameHandler', []);
  }
}
function modelNameHandler(model) {
  if (assert((model.substr(0,6) == "iPhone"), 'Utility', 'modelName', 'should be ios')) {
  	callNative('Utility', 'hideKeyboard', 'hideKeyboardHandler', []);
  }
}
function hideKeyboardHandler(hidden) {
	if (assert((hidden === true), 'Utility', 'hideKeyboard', 'should be true')) {
		log('Done with utility test');
	}
}

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
		if (assert((rowCount === 0), "rowcount should be zero")) {
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
	callNative('Sqlite', 'openDB', 'openDBHandler9', ['Temp.db', false]);
	callNative('Sqlite', 'listDB', 'listDBHandler', []);
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
/*
AppInitializer
  line 27 AWS.initializeRegion(function(done) {}) return false, if error occurs DEPRECATED

FileDownloader
  line 21 AWS.downloadZipFile(s3Bucket, s3Key, filePath, function(error) {}) returns error, if occurs, else null
*/
function testAWS() {
	var region = 'TEST';
	var bucket = 'nonehere';
	var key = 'nonehere';
	var filename = 'nonehere';
	callNative('AWS', 'downloadZipFile', 'downloadZipHandler1', [region, bucket, key, filename]);
}
function downloadZipHandler1(error) {
	log(error);
	if (assert(error, "Download should fail for non-existing object.")) {
		var region = 'TEST';
		var bucket = 'shortsands';
		var key = 'ERV-ENG.db.zip';
		var filename = 'ERV-ENG.db';
		callNative('AWS', 'downloadZipFile', 'downloadZipHandler2', [region, bucket, key, filename]);
	}
}
function downloadZipHandler2(error) {
	//log(error);
	if (!assert(error, error)) {
		log("AWS Test did succeed");
	}
} /*
 VideoListView
   line 105 VideoPlayer.showVideo(mediaSource, videoId, languageId, silCode, videoUrl, function() {}) if error, return error
 */
 function testVideoPlayer() {
	 var mediaSource = 'FCBH';
	 var videoId = 'myvideoId';
	 var languageId = 'ENG';
	 var silCode = 'eng';
	 var videoUrl = 'https://whatever';
	 var parameters = [mediaSource, videoId, languageId, silCode, videoUrl];
	 callNative('VideoPlayer', 'showVideo', 'showVideoHandler1', parameters);
 }
 function showVideoHandler1(nothing) {
	 log(nothing);
	 if (assert((nothing == null), "video should return nothing")) {
		 var mediaSource = "JFP";
		 var videoId = 'Jesus';
		 var languageId = '528';
		 var silCode = 'eng';
		 var videoUrl = 'https://arc.gt/j67rz?apiSessionId=5a8b6c35e31419.49477826';
		 //var videoUrl = 'https://player.vimeo.com/external/157336122.m3u8?s=861d8aca0bddff67874ef38116d3bf5027474858';
		 var parameters = [mediaSource, videoId, languageId, silCode, videoUrl];
		 callNative('VideoPlayer', 'showVideo', 'showVideoHandler2', parameters);		 
	 }
 }
 function showVideoHandler2(nothing) {
	 if (assert((nothing == null), "video should succeed, but return nothing")) {
		 console.log('VideoPlayer test is complete.');
	 }
 }