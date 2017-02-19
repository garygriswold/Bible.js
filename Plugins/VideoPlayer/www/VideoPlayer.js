"use strict";

module.exports = {
    present: function (videoUrl, seekSec, successCallback, errorCallback) {
	    console.log('**** INSIDE module.exports begin: ' + videoUrl + ' ' + seekSec);
        cordova.exec(successCallback, errorCallback, "VideoPlayer", "present", [videoUrl, seekSec]);
    }
};