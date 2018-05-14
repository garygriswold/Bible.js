/**
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
  alert(locale);
  if (assert((locale == "en-US"), 'Utility', 'locale', 'should be en-US')) {
    callNative('Utility', 'platform', 'platformHandler', []);
  }
}
function platformHandler(platform) {
  alert(platform);
   if (assert((platform == "iOS"), 'Utility', 'platform', 'should be ios')) {
    callNative('Utility', 'modelName', 'modelNameHandler', []);
  }
}
function modelNameHandler(model) {
  alert(model);
  if (assert((model == "iPhone"), 'Utility', 'modelName', 'should be ios')) {
  	callNative('Utility', 'hideKeyboard', 'hideKeyboardHandler', []);
  }
}
function hideKeyboardHandler(hidden) {
	if (assert(hidden, 'Utility', 'hideKeyboard', 'should be true') {
		console.log('Done with utility test');
	}
}

