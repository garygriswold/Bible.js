/*
* This must be called with a String plugin name, String method name,
* handler is an anonymous function, and a parameter array.  The items
* in the array can be any String, number, or boolean.
*/
var pluginCallCount = 0;
var pluginCallMap = {};

/**
* This method is called by Javascript code to call Native functions
* handler is normally an anonymous function that will receive the results.
*/
function callNative(plugin, method, parameters, rtnType, handler) {
	var callbackId = plugin + "." + method + "." + pluginCallCount++;
	pluginCallMap[callbackId] = {handler: handler, rtnType: rtnType};
	var message = {plugin: plugin, method: method, parameters: parameters, callbackId: callbackId};
	window.webkit.messageHandlers.callNative.postMessage(message);
}

function handleNative(callbackId, isJson, error, results) {
	log(callbackId);
	var callObj = pluginCallMap[callbackId];
	delete pluginCallMap[callbackId];
	
	var rtnType = callObj.rtnType;
	var handler = callObj.handler;
	
	if (rtnType === "N") {
		handler();
	} else if (rtnType === "E") {
		handler(error);
	} else if (rtnType === "S") {
		if (isJson > 0) {
			handler(JSON.parse(results));
		} else {
			handler(results);
		}
	} else {
		if (isJson > 0) {
			handler(error, JSON.parse(results));
		} else {
			handler(error, results);
		}
	}
}


