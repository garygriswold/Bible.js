

function displayLocale() {
	callNative('Utility', 'getLocale', 'displayLocaleSuccess', []);
}
function displayLocaleSuccess(locale) {
	var element = document.getElementById("locale");
	element.innerHTML = locale;	
}
function callNative(plugin, method, handler, parameters) {
	var message = {plugin: plugin, method: method, handler: handler, parameters: parameters };
	window.webkit.messageHandlers.callNative.postMessage(message);
}

