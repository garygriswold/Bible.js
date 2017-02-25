"use strict";

module.exports = {
    present: function (videoId, videoUrl, successCallback, errorCallback) {
	    console.log('**** INSIDE module.exports begin: ' + videoId + ' ' + videoUrl);
        cordova.exec(successCallback, errorCallback, "VideoPlayer", "present", [videoId, videoUrl]);
    }
};