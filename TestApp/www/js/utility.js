/**
cordovaDeviceSettings
  line 11 Utility.locale(function(results) {})
  line 16 Utility.locale(function(results) {})
  line 25 Utility.platform(function(platform) {})
  line 28 Utility.modelName(function(model) {})

AppUpdater
  line 127 Utility.listDB(function(files) {})
  line 181 Utility.deleteDB(file, function(error) {})

SearchView
  line 86 Utility.hideKeyboard(function(hidden) {})
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

  }
}

