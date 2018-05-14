"use strict";
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
}/**
cordovaDeviceSettings
  line 11 Utility.locale(function(results) {}) no error possible, should return null if it did happen
  line 16 Utility.locale(function(results) {}) no error possible, should return null if it did happen
  line 25 Utility.platform(function(platform) {}) no error possible, should return null if it did happen
  line 28 Utility.modelName(function(model) {}) no error possible, should return null if it did happen

SearchView
  line 86 Utility.hideKeyboard(function(hidden) {}) if error, returns false
*/
function testUtility() {
	var e = document.getElementById("locale");
	e.innerHTML = "inside testUtility";
	callNative('Utility', 'locale', 'localeHandler', []);
}
function localeHandler(locale) {
  var loc = JSON.parse(locale);
  if (assert((loc.length == 4), 'Utility', 'locale', 'should be 4 element')) {
	  if (assert((loc[0] == "en_US"), 'Utility', 'locale', 'first part should be en_USx')) {
	  	callNative('Utility', 'platform', 'platformHandler', []);
	  }
  }
}
function platformHandler(platform) {
   if (assert((platform == "iOS"), 'Utility', 'platform', 'should be ios')) {
    callNative('Utility', 'modelName', 'modelNameHandler', []);
  }
}
function modelNameHandler(model) {
  if (assert((model.substr(0,6) == "iPhone"), 'Utility', 'modelName', 'should be ios')) {
  	callNative('Utility', 'hideKeyboard', 'hideKeyboardHandler', []);
  }
}
function hideKeyboardHandler(hidden) {
	if (assert((hidden == true), 'Utility', 'hideKeyboard', 'should be true')) {
		log('Done with utility test');
	}
}

/*
* This must be called with a String plugin name, String method name,
* String handler (function) name, and a parameter array.  The items
* in the array can be any String, number, or boolean.
*/
function callNative(plugin, method, handler, parameters) {
	callAndroid.jsHandler(plugin, method, handler, parameters);
}
