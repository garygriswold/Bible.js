"use strict";

module.exports = {
    playAudio: function (audioId, audioUrl, successCallback, errorCallback) {
	    console.log('**** INSIDE module.exports begin: ' + audioId + ' ' + audioUrl);
        cordova.exec(successCallback, errorCallback, "AudioPlayer", "playAudio", [audioId, audioUrl]);
    }
};