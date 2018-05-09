

function displayLocale() {
    var message = {'command': 'getLocale', 'handler': 'displayLocaleSuccess' };
    window.webkit.messageHandlers.callNative.postMessage(message);
}
function displayLocaleSuccess(locale) {
	var element = document.getElementById("locale");
	element.innerHTML = locale;	
}
