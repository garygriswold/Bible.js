function assert(condition, plugin, method, message) {
	if (!condition) {
		var message = plugin + '.' + method + " failed: " + message;
		alert(message);
		return false;
	} else {
		return true;
	}
}