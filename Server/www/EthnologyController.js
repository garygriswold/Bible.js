/**
* This class provides information about related languages.
* It is given information about the user's country, and preferred language.
* Using this information, it provides a list of available translations,
* which might interest the user.
*/
"use strict";
function EthnologyController() {
	// The constructor should have handle for connection to the Enthology database
	// Or, it should load data to be accessed live, not sure
}
EthnologyController.prototype.availVersions = function(locale) {
	var parts = locale.split(/[_-]/);
	var lang = parts[0];
	var ctry = (parts.length > 1) ? parts[1] : null;
	var vary = (parts.length > 2) ? parts[2] : null;
	console.log('LOCALE', lang, ctry, vary);
	return([ "WEB.bible1", "KJV.bible1" ]);
};

module.exports.EthnologyController = EthnologyController;