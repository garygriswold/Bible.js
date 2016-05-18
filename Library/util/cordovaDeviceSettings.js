/**
 * This class accesses the device locale and language information using the globalization plugin
 * and the versions, platform and model of the device plugin, and the network status.
 */
var deviceSettings = {
    prefLanguage: function(callback) {
        navigator.globalization.getPreferredLanguage(onSuccess, onError);

        function onSuccess(pref) {
            callback(pref.value);
        }
        function onError() {
            callback('en-US');
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