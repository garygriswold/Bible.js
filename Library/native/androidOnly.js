/**
* This file makes the actual native call for Android
*/
function callNativeForOS(callbackId, plugin, method, parameters) {
	var params = JSON.stringify(parameters);
	callAndroid.jsHandler(callbackId, plugin, method, params);
}

