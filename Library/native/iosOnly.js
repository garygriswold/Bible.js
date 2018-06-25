/**
* This file makes the actual native call for iOS
*/
function callNativeForOS(callbackId, plugin, method, parameters) {
	var message = {plugin: plugin, method: method, parameters: parameters, callbackId: callbackId};
	window.webkit.messageHandlers.callNative.postMessage(message);
}

var console = {
    log: function(a, b, c, d) {
	    window.webkit.messageHandlers.callNative.postMessage([a,b,c,d]);
	},
	logOne: function(a) {
		window.webkit.messageHandlers.callNative.postMessage(JSON.stringify(a));
	}
}

	
