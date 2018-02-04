"use strict";

module.exports = {
    playAudio: function (versionCode, bookId, chapter, successCallback, errorCallback) {
	    console.log('**** INSIDE module.exports begin: ' + versionCode + ' ' + bookId + ' ' + chapter);
        cordova.exec(successCallback, errorCallback, "AudioPlayer", "playAudio", [versionCode, bookId, chapter]);
    }
};
