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
	callNative('Utility', 'locale', [], "S", function(locale) {
		if (assert((locale.length == 4), 'Utility', 'locale', 'should be 4 element')) {
			if (assert((locale[0] == "en_US"), 'Utility', 'locale', 'first part should be en_USx')) {
				testPlatform();
			}
		}	
	});
}
function testPlatform() {
	callNative('Utility', 'platform', [], "S", function(platform) {
		if (assert((platform == "iOS" || platform == "Android"), 'Utility', 'platform', 'should be iOS and Android')) {
	    	testModelName();
		}		
	});
}
function testModelName() {
	callNative('Utility', 'modelName', [], "S", function(model) {
		var parts = model.split(' ');
		if (assert((parts[0] == "iPhone" || parts[0] == "Android"), 'Utility', 'modelName', model)) {
			testHideKeyboard();
		}
	});
}
function testHideKeyboard() {
  	callNative('Utility', 'hideKeyboard', [], "S", function(hidden) {
		if (assert((hidden === true), 'Utility', 'hideKeyboard', 'should be true')) {
			testModelType();
		}	  	
  	});
}
function testModelType() {
	callNative('Utility', 'modelType', [], "S", function(model) {
		log('Done with utility test');
	});
}


