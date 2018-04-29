/**
 * This class accesses the device locale and language information using the globalization plugin
 * and the versions, platform and model of the device plugin, and the network status.
 */
var deviceSettingsPlatform = null;
var deviceSettingsModel = null;

var deviceSettings = {
	/* Deprecated, used only VersionsView */
    prefLanguage: function(callback) {
	    Utility.locale(function(results) {
			callback(results[0]);
	    });
    },
    locale: function(callback) {
	    Utility.locale(function(results) {
			var locale = (results[0].length > 0) ? results[0] : 'en-US';
			var language = (results.length > 0 && results[1].length > 0) ? results[1] : 'en';
			var script = (results.length > 1) ? results[2] : '';
			var country = (results.length > 2 && results[3].length > 0) ? results[3] : 'US';
			callback(locale, language, script, country); 
	    });    
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
    }
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
    // removed 4/29/2018
    //connectionType: function() {
    //    return(navigator.connection.type);
    //},
    //hasConnection: function() {
    //    var type = navigator.connection.type;
    //    return(type !== 'none' && type !== 'unknown'); // not sure of correct value for UNKNOWN
    //}
};