/**
* This file makes the actual native call for iOS
*/
function callNativeForOS(callbackId, plugin, method, parameters) {
	var message = {plugin: plugin, method: method, parameters: parameters, callbackId: callbackId};
	window.webkit.messageHandlers.callNative.postMessage(message);
}
	
