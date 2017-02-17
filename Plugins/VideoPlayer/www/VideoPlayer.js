"use strict";

module.exports = {
    present: function (videoUrl, seekSec, successCallback, errorCallback) {
	    console.log('**** INSIDE module.exports begin: ' + url + ' ' + seekSec);
        cordova.exec(successCallback, errorCallback, "VideoPlugin", "present", [videoUrl, seekSec]);
    }
};