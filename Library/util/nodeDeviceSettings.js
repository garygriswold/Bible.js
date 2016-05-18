/**
 * This is the Node/WebKit standin for the Device and Globalization and Connection
 * Cordova plugins.
 */
var deviceSettings = {
	prefLanguage: function(callback) {
		callback('es-ES');
    },
    platform: function() {
        return('node');
    }
};