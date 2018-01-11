/**
 * This class accesses the device locale and language information using the globalization plugin
 * and the versions, platform and model of the device plugin, and the network status.
 */
var deviceSettingsPlatform = null;
var deviceSettingsModel = null;

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
    loadDeviceSettings: function() {
		Utility.platform(function(platform) {
			deviceSettingsPlatform = platform.toLowerCase();
		});
		Utility.modelName(function(model) {
			deviceSettingsModel = model;
		});
    },
    platform: function() {
        return(deviceSettingsPlatform);
    },
    model: function() {
        return(deviceSettingsModel);
    },
    // removed 1/10/2018
    //uuid: function() {
    //    return(device.uuid);
    //},
    //osVersion: function() {
    //    return(device.version);
    //},
    //cordovaVersion: function() {
    //    return(device.cordova);
    //},
    connectionType: function() {
        return(navigator.connection.type);
    },
    hasConnection: function() {
        var type = navigator.connection.type;
        return(type !== 'none' && type !== 'unknown'); // not sure of correct value for UNKNOWN
    }
};