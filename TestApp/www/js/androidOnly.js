/**
* This file makes the actual native call for Android
*/
function callNativeForOS(callbackId, plugin, method, parameters) {
	callAndroid.jsHandler(callbackId, plugin, method, parameters);
}

