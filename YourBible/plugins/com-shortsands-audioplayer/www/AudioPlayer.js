"use strict";

module.exports = {
    present: function (versionCode, silLang, bookId, chapter, successCallback, errorCallback) {
	    console.log('**** INSIDE module.exports begin: ' + versionCode + ' ' + bookId + ' ' + chapter);
        cordova.exec(successCallback, errorCallback, "AudioPlayer", "present", [versionCode, silLang, bookId, chapter, "mp3"]);
    }
};

//func present(view: UIView, version: String, silLang: String, book: String, chapter: String, fileType: String)
