"use strict";

exports.findAudioVersion = function(version, silCode, callback) {
    cordova.exec(callback, function(error) {
	    AudioPlayer.logError("findAudioVersion", error, [version, silCode]);
	    callback();
    }, "AudioPlayer", "findAudioVersion", [version, silCode]);
};

//exports.findAudioBook = function(bookId, callback) {
//    exec(callback, function(error) {
//	    AudioPlayer.logError("findAudioBook", error, [bookId]);
//	    callback();
//    }, "AudioPlayer", "findAudioVersion", [bookId]);
//};

exports.present = function (bookId, chapter, callback) {
	cordova.exec(callback, function(error) {
		AudioPlayer.logError("present", error, [bookId, chapter]);
		callback();
	}, "AudioPlayer", "present", [bookId, chapter]);
};

/** Deprecated, but still for Android 2/18 */
exports.oldPresent = function (versionCode, silLang, bookId, chapter, successCallback, errorCallback) {
	console.log('**** INSIDE module.exports begin: ' + versionCode + ' ' + bookId + ' ' + chapter);
	cordova.exec(successCallback, errorCallback, "AudioPlayer", "present", [versionCode, silLang, bookId, chapter, "mp3"]);
};

/**
* When written the plugin does not return errors, but this is written to handle them
* just in case that is changed.
*/
exports.logError = function(method, error, params) {
	var msg = ["\nERROR: AudioPlayer."];
	msg.push(method);
	for (i=0; i<params.length; i++) {
		msg.push(" " + params[i]);
	}
	msg.push(" -> " + error);
	console.log(msg.join(""));	
};

//func present(view: UIView, version: String, silLang: String, book: String, chapter: String, fileType: String)
