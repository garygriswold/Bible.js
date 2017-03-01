"use strict";

module.exports = {
    showVideo: function (videoId, videoUrl, successCallback, errorCallback) {
	    console.log('**** INSIDE module.exports begin: ' + videoId + ' ' + videoUrl);
        cordova.exec(successCallback, errorCallback, "VideoPlayer", "showVideo", [videoId, videoUrl]);
    }
};