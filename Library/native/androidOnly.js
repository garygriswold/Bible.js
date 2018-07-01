/**
* This file makes the actual native call for Android
*/
function callNativeForOS(callbackId, plugin, method, parameters) {
	var params = JSON.stringify(parameters);
	callAndroid.jsHandler(callbackId, plugin, method, params);
}

var console = {
    log: function(a, b, c, d) {
	    var params = JSON.stringify(arguments);
	    callAndroid.jsHandler(null, "console", "log", params);
	},
	logOne: function(a) {
	    var params = JSON.stringify(a);
	    callAndroid.jsHandler(null, "console", "log", a);
	}
}

