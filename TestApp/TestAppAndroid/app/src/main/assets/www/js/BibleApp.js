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
	callNative('Utility', 'locale', [], "S", function(locale) {
		if (assert((locale.length == 4), 'Utility', 'locale', 'should be 4 element')) {
			if (assert((locale[0] == "en_US"), 'Utility', 'locale', 'first part should be en_USx')) {
				testPlatform();
			}
		}	
	});
}
function testPlatform() {
	callNative('Utility', 'platform', [], "S", function(platform) {
		if (assert((platform == "iOS"), 'Utility', 'platform', 'should be ios')) {
	    	testModelName();
		}		
	});
}
function testModelName() {
	callNative('Utility', 'modelName', [], "S", function(model) {
		if (assert((model.substr(0,6) == "iPhone"), 'Utility', 'modelName', 'should be iPhone')) {
			testHideKeyboard();
		}
	});
}
function testHideKeyboard() {
  	callNative('Utility', 'hideKeyboard', [], "S", function(hidden) {
		if (assert((hidden === true), 'Utility', 'hideKeyboard', 'should be true')) {
			testModelType();
		}	  	
  	});
}
function testModelType() {
	callNative('Utility', 'modelType', [], "S", function(model) {
		log('Done with utility test');
	});
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
	callNative('AWS', 'downloadZipFile', [region, bucket, key, filename], "E", function(error) {
		if (assert(error, "Download should fail for non-existing object.")) {
			testDownloadZip2();
		}
	});
}
function testDownloadZip2() {
	var region = 'TEST';
	var bucket = 'shortsands';
	var key = 'ERV-ENG.db.zip';
	var filename = 'ERV-ENG.db';
	callNative('AWS', 'downloadZipFile', [region, bucket, key, filename], "E", function(error) {
		if (!assert(error, error)) {
			log("AWS Test did succeed");
		}
	});
}
  /*
  HeaderView
    line 108 AudioPlayer.findAudioVersion(versionCode, silCode, function(bookList) {}) if error, return "" 

  AppInitializer
    line 114 AudioPlayer.isPlaying(function(playing) {}) if error, return "F"
    line 126 AudioPlayer.present(ref.book, ref.chapter, function() {}) return required, error not returned
    line 139 AudioPlayer.stop(function() {}) error not returned
  */
 function testAudioPlayer() {
	 callNative('AudioPlayer', 'isPlaying', 'isPlayingHandler', []);
 }
 function isPlayingHandler(playing) {
	 if (assert((playing === "F"), "It is be playing is false")) {
		 callNative('AudioPlayer', 'findAudioVersion', 'findVersionHandler', ['versionxx', 'silCode']);
	 }
 }
 function findVersionHandler(bookList) {
	 if (assert((bookList === ""), "BookList must not be null")) {
		 callNative('AudioPlayer', 'findAudioVersion', 'findVersionHandler2', ['WEB', 'eng']);
	}
}
function findVersionHandler2(bookList) {
	log(typeof bookList);
	 if (assert(bookList.length > 100), "BookList must be a string of books") {
		 var books = bookList.split(',');
		 log(typeof books);
		 if (assert((books.length > 20), "BookList must be a comma separated list")) {
			 var book = "JHN";
			 var chapter = 3;
			 callNative('AudioPlayer', 'present', 'presentHandler', [book, chapter]);
		 }
	 }
 }
 function presentHandler(nothing) {
	 log(nothing);
	 if (assert((nothing == null), "present should return nothing")) {
		 callNative('AudioPlayer', 'stop', 'stopHandler', []);
	 }
 }
 function stopHandler(nothing) {
	 if (assert((nothing == null), "stop should return nothing")) {
		 log('AudioPlayer test is complete');
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
 }/*
* This must be called with a String plugin name, String method name,
* String handler (function) name, and a parameter array.  The items
* in the array can be any String, number, or boolean.
*/
function callNative(plugin, method, handler, parameters) {
	callAndroid.jsHandler(plugin, method, handler, parameters);
}
