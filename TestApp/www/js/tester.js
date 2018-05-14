function assert(condition, plugin, method, message) {
	if (!condition) {
		var out = plugin + '.' + method + " failed: " + message;
		var response = document.getElementById("response");
		response.innerHTML = out;
		return false;
	} else {
		return true;
	}
}
function log(message) {
	var locale = document.getElementById('locale');
	locale.innerHTML = message;
}