/**
* This database adapter is different from the others in this package.  It accesses
* not the Bible, but a different database, which contains a catalog of versions of the Bible.
*
* The App selects from, but never modifies this data.
*/
function VersionsAdapter() {
    this.className = 'VersionsAdapter';
	this.database = new DatabaseHelper('Versions.db', true);
	this.translation = null;
	Object.seal(this);
}
VersionsAdapter.prototype.buildTranslateMap = function(locale, callback) {
	if (this.translation == null) {
		this.translation = {};
		var that = this;
		var locales = findLocales(locale);
		selectLocale(locales.pop());
	}
	
	function selectLocale(oneLocale) {
		// terminate once there are translation items, or there no more locales to process.
		if (that.translation.length > 10 || oneLocale == null) {
			callback(that.translation);
		} else {
			var statement = 'SELECT source, translated FROM Translation WHERE target = ?';
			that.database.select(statement, [oneLocale], function(results) {
				if (results instanceof IOError) {
					console.log('VersionsAdapter.BuildTranslationMap', results);
					callback(results);
				} else {
					for (var i=0; i<results.rows.length; i++) {
						var row = results.rows.item(i);
						that.translation[row.source] = row.translated;
					}
					selectLocale(locales.pop());
				}
			});
		}
	}
	
	function findLocales(locale) {
		var locales = [];
		var parts = locale.split('-');
		locales.push(parts[0]);
		locales.push('en');
		return(locales);
	}
};
VersionsAdapter.prototype.selectCountries = function(callback) {
	var statement = 'SELECT countryCode, primLanguage, localCountryName FROM Country ORDER BY localCountryName';
	this.database.select(statement, null, function(results) {
		if (results instanceof IOError) {
			callback(results)
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				if (row.countryCode === 'WORLD') {
					array.unshift(row);
				} else {
					array.push(row);
				}
			}
			callback(array);
		}
	});
};
VersionsAdapter.prototype.selectVersions = function(countryCode, callback) {
	var statement =	'SELECT v.versionCode, l.localLanguageName, l.langCode, l.direction, v.localVersionName, v.versionAbbr,' +
		' v.copyright, v.filename, o.localOwnerName, o.ownerURL' +
		' FROM Version v' + 
		' JOIN Owner o ON v.ownerCode = o.ownerCode' +
		' JOIN Language l ON v.silCode = l.silCode' +
		' JOIN CountryVersion cv ON v.versionCode = cv.versionCode' +
		' WHERE cv.countryCode = ?'
	this.database.select(statement, [countryCode], function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else {
			var array = [];
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				array.push(row);
			}
			callback(array);
		}
	});
};
VersionsAdapter.prototype.selectVersionByFilename = function(versionFile, callback) {
	var statement = 'SELECT v.versionCode, v.silCode, v.hasHistory, v.isQaActive, v.copyright, v.introduction,' +
		' l.localLanguageName, l.langCode, l.direction, v.localVersionName, v.versionAbbr, o.ownerCode, o.localOwnerName, o.ownerURL' +
		' FROM Version v' +
		' JOIN Owner o ON v.ownerCode = o.ownerCode' +
		' JOIN Language l ON v.silCode = l.silCode' +
		' WHERE v.filename = ?';
	this.database.select(statement, [versionFile], function(results) {
		if (results instanceof IOError) {
			callback(results);
		} if (results.rows.length === 0) {
			callback(new IOError('No version found'));
		} else {
			callback(results.rows.item(0));
		}
	});
};
VersionsAdapter.prototype.defaultVersion = function(lang, callback) {
	var statement = 'SELECT v.filename' +
			' FROM Version v JOIN InstalledVersion s ON s.versionCode = v.versionCode' +
			' WHERE s.endDate IS NULL' +
			' AND s.localeDefault = ?';
	this.database.select(statement, [lang], function(results) {
		if (results instanceof IOError) {
			callback(results);
		} else if (results.rows.length === 0) {
			callback('WEB.db');
		} else {
			callback(results.rows.item(0).filename);
		}
	});
};
VersionsAdapter.prototype.close = function() {
	this.database.close();		
};

