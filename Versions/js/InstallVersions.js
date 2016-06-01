/**
* InstallVersions prepares the App for a specific store, placing in the
* App those versions that are intended for that store.  And updating
* the Settings table with those installed versions.
*/
function InstallVersions(options) {
	var sqlite3 = (options.verbose) ? require('sqlite3').verbose() : require('sqlite3');
	this.db = new sqlite3.Database(options.filename);
	if (options.verbose) {
		this.db.on('trace', function(sql) {
			console.log('DO ', sql);
		});
		this.db.on('profile', function(sql, ms) {
			console.log(ms, 'DONE', sql);
		});
	}
	this.db.run("PRAGMA foreign_keys = ON");
	this.fs = require('fs');
	this.initSettingsJS = [];
	Object.freeze(this);
}
InstallVersions.prototype.install = function(locale, callback) {
	var that = this;
	var hasDefaultVersion = null;
	var statement = 'SELECT v.versionCode, v.silCode, v.versionAbbr, v.localVersionName, v.filename, s.defaultVersion' +
			' FROM Version v JOIN StoreVersion s ON s.versionCode = v.versionCode' +
			' WHERE s.storeLocale = ? AND s.endDate IS NULL';
	this.db.all(statement, [locale], function(err, results) {
		if (err) {
			that.error('Error in select join StoreVersion, Version', err);
		}
		if (results.length === 0) {
			that.error('There are no versions for locale', locale);
		}
		processRow(results, 0);
	});
		
	function processRow(results, index) {
		if (index < results.length) {
			var row = results[index];
			console.log(row);
			if (row.defaultVersion === 'T') {
				hasDefaultVersion = row.filename;
				that.initSettingsJS.unshift('\tthis.setCurrentVersion("' + row.filename + '");');
			}
			that.initSettingsJS.push('\tthis.setVersion("' + row.versionCode + '", "' + row.filename + '");');
			that.copyFile('../../DBL/5ready/' + row.filename, '../YourBible/www/', function() {
				console.log('Finished copy', row.filename);
				processRow(results, index + 1);
			});
		} else {
			if (hasDefaultVersion == null) {
				that.error('InstallVersions.processRow', 'No defaultVersion');
			}
			that.initSettingsJS.unshift('SettingStorage.prototype.initSettings = function() {');
			that.initSettingsJS.push('\treturn("' + hasDefaultVersion + '");');
			that.initSettingsJS.push('};\n');
			that.fs.writeFile('../YourBible/www/js/SettingStorageInitSettings.js', that.initSettingsJS.join('\n'), {encoding: 'utf8'}, function(err) {
				if (err) {
					that.error('InstallVersion.writeFile', err);
				} else {
					callback();
				}
			});
		}
	}
};
InstallVersions.prototype.copyFile = function(source, target, callback) {
	var that = this;
	const proc = require('child_process');
	proc.exec('cp ' + source + ' ' + target, function(error, stdout, stderr) {
		if (error != null) {
			that.error('Copy File Error', error);
		}
		if (stderr != null && stderr.length > 0) {
			that.error('Copy File StdError', stderr);
		}
    	callback();
	});
};
InstallVersions.prototype.error = function(message, err) {
	console.log(message, err);
	process.exit(1);	
};


if (process.argv.length < 3) {
	console.log('Usage: InstallVersions.sh  LOCALE (e.g. en or es, etc)');
	process.exit(1);
}
var database = new InstallVersions({filename: './Versions.db', verbose: true});
database.install(process.argv[2], function() {
	console.log('INSTALL VERSIONS COMPLETED SUCESSFULLY');
});

module.exports = InstallVersions;
