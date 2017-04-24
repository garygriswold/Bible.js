/**
 * This class accesses the device locale and language information using the globalization plugin
 * and the versions, platform and model of the device plugin, and the network status.
 */
var deviceSettings = {
	/* Deprecated, use locale is Used in AppInitializer and VersionsView */
    prefLanguage: function(callback) {
        navigator.globalization.getPreferredLanguage(onSuccess, onError);

        function onSuccess(pref) {
            callback(pref.value);
        }
        function onError() {
            callback('en-US');
        }
    },
    locale: function(callback) {
        navigator.globalization.getPreferredLanguage(onSuccess, onError);

        function onSuccess(pref) {
	        var parts = pref.value.split('-');
	        var lang = parts[0];
	     	var script = (parts.length > 2) ? parts[1] : null;
	        var cnty = (parts.length > 1) ? parts.pop() : 'US';

            callback(pref.value, lang, script, cnty);
        }
        function onError() {
            callback('en-US', 'en', null, 'US');
        }	    
    },
    platform: function() {
        return((device.platform) ? device.platform.toLowerCase() : null);
    },
    model: function() {
        return(device.model);
    },
    uuid: function() {
        return(device.uuid);
    },
    osVersion: function() {
        return(device.version);
    },
    cordovaVersion: function() {
        return(device.cordova);
    },
    connectionType: function() {
        return(navigator.connection.type);
    },
    hasConnection: function() {
        var type = navigator.connection.type;
        return(type !== 'none' && type !== 'unknown'); // not sure of correct value for UNKNOWN
    }
};