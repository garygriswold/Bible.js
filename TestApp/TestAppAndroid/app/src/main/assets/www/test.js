

function displayLocale() {
    //console.log("Inside displayLocal");
	callNative('Utility', 'getLocale', 'displayLocaleSuccess', []);
	//displayLocaleSuccess("xx_XX");
}
function displayLocaleSuccess(locale) {
	var element = document.getElementById("locale");
	element.innerHTML = locale;	
}
function callNative(plugin, method, handler, parameters) {
    // ios
	//var message = {plugin: plugin, method: method, handler: handler, parameters: parameters };
	//window.webkit.messageHandlers.callNative.postMessage(message);

	// android
	callAndroid.jsHandler(plugin, method, handler);//, parameters);
}

