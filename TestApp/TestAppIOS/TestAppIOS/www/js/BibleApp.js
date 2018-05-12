"use strict";
function assert(condition, plugin, method, message) {
	if (!condition) {
		var message = plugin + '.' + method + " failed: " + message;
		alert(message);
		return false;
	} else {
		return true;
	}
}  /*
  HeaderView
    line 108 AudioPlayer.findAudioVersion(versionCode, silCode, function(bookList) {})

  AppInitializer
    line 114 AudioPlayer.isPlaying(function(playing) {})
    line 126 AudioPlayer.present(ref.book, ref.chapter, function() {}) return required
    line 139 AudioPlayer.stop(function() {})
  *//*
AppInitializer
  line 27 AWS.initializeRegion(function(done) {})

FileDownloader
  line 21 AWS.downloadZipFile(s3Bucket, s3Key, filePath, function(error) {})
*//*
DatabaseHelper
  line 7 Utility.openDatabase(dbname, isCopyDatabase, function(error) {})
  line 14 Utility.queryJS(dbname, statement, values, function(error, results) {})
  line 23 Utility.executeJS(dbname, statement, values, function(error, rowCount) {})
  line 32 Utility.bulkExecuteJS(dbname, statement, array, function(error, rowCount) {})
  line 41 Utility.executeJS(dbname, statement, [], function(error, rowCount) {})
  line 50 Utility.closeDatabase(dbname, function(error) {})
*//**
cordovaDeviceSettings
  line 11 Utility.locale(function(results) {})
  line 16 Utility.locale(function(results) {})
  line 25 Utility.platform(function(platform) {})
  line 28 Utility.modelName(function(model) {})

AppUpdater
  line 127 Utility.listDB(function(files) {})
  line 181 Utility.deleteDB(file, function(error) {})

SearchView
  line 86 Utility.hideKeyboard(function(hidden) {})
*/
function testUtility() {
	var e = document.getElementById("locale");
	e.innerHTML = "inside testUtility";
	callNative('Utility', 'locale', 'localeHandler', []);
}
function localeHandler(locale) {
  alert(locale);
  if (assert((locale == "en-US"), 'Utility', 'locale', 'should be en-US')) {
    callNative('Utility', 'platform', 'platformHandler', []);
  }
}
function platformHandler(platform) {
  alert(platform);
   if (assert((platform == "iOS"), 'Utility', 'platform', 'should be ios')) {
    callNative('Utility', 'modelName', 'modelNameHandler', []);
  }
}
function modelNameHandler(model) {
  alert(model);
  if (assert((model == "iPhone"), 'Utility', 'modelName', 'should be ios')) {

  }
}

 /*
 VideoListView
   line 105 VideoPlayer.showVideo(mediaSource, videoId, languageId, silCode, videoUrl, function() {})
 *//*
* This must be called with a String plugin name, String method name,
* String handler (function) name, and a parameter array.  The items
* in the array can be any String, number, or boolean.
*/
function callNative(plugin, method, handler, parameters) {
	var message = {plugin: plugin, method: method, handler: handler, parameters: parameters };
	window.webkit.messageHandlers.callNative.postMessage(message);
}
