"use strict";

module.exports = {
	showVideo: function(mediaSource, videoId, languageId, silLang, videoUrl, successCallback, errorCallback) {
	    console.log('**** INSIDE module.exports begin: ' + videoId + ' ' + videoUrl);
        cordova.exec(successCallback, errorCallback, "VideoPlayer", "showVideo", [mediaSource, videoId, languageId, silLang, videoUrl]);
    }
};
