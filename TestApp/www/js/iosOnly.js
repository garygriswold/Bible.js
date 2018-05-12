/*
* This must be called with a String plugin name, String method name,
* String handler (function) name, and a parameter array.  The items
* in the array can be any String, number, or boolean.
*/
function callNative(plugin, method, handler, parameters) {
	var message = {plugin: plugin, method: method, handler: handler, parameters: parameters };
	window.webkit.messageHandlers.callNative.postMessage(message);
}
