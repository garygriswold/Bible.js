/**
* This database adapter is different from the others in this package.  It accesses
* not the Bible, but a different database, which contains a catalog of versions of the Bible.
*
* The App selects from, but never modifies this data.
*/
function VersionsAdapter() {
    this.className = 'VersionsAdapter';
	this.database = new DatabaseHelper('Versions.db', true);
	Object.seal(this);
}
VersionsAdapter.prototype.selectCountries = function(callback) {
	var statement = 'SELECT countryCode, localName, primLanguage, flagIcon FROM Country ORDER BY localName';
	this.database.select(statement, null, function(results) {
		if (results instanceof IOError) {
			callback(results)
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
VersionsAdapter.prototype.selectVersions = function(countryCode, primLanguage, callback) {
	var statement = 'SELECT cv.versionCode, cv.localLanguageName, cv.localVersionName, t1.translated as scope, v.filename, o.ownerName,' +
		' o.ownerURL, v.copyrightYear' +
		' FROM CountryVersion cv' +
		' JOIN Version v ON cv.versionCode=v.versionCode' +
		' JOIN Owner o ON v.ownerCode=o.ownerCode' +
		' LEFT OUTER JOIN TextTranslation t1 ON t1.silCode=? AND t1.word=v.scope' +
		' WHERE cv.countryCode = ?' +
		' AND v.filename is NOT NULL' +
		' AND length(v.filename) > 3' +
		' ORDER BY cv.localLanguageName, cv.localVersionName';
	this.database.select(statement, [primLanguage, countryCode], function(results) {
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
	var statement = 'SELECT v.versionCode, v.silCode, v.isQaActive, v.copyrightYear, v.introduction,' +
		' cv.localLanguageName, cv.localVersionName, o.ownerCode, o.ownerName, o.ownerURL' +
		' FROM CountryVersion cv' +
		' JOIN Version v ON cv.versionCode=v.versionCode' +
		' JOIN Owner o ON v.ownerCode=o.ownerCode' +
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
VersionsAdapter.prototype.close = function() {
	this.database.close();		
};

