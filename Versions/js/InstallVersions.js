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
	Object.freeze(this);
}
InstallVersions.prototype.install = function(callback) {
	var that = this;
	var defaultVersion = null;
	var initSettingsJS = ['SettingStorage.prototype.initSettings = function() {\n'];
	var defaultSettingsJS = ['SettingStorage.prototype.defaultVersion = function(lang) {\n'];
	defaultSettingsJS.push('\tswitch(lang) {\n');
	
	var statement = 'SELECT v.versionCode, v.filename, s.localeDefault' +
			' FROM Version v JOIN InstalledVersion s ON s.versionCode = v.versionCode' +
			' WHERE s.endDate IS NULL';
	this.db.all(statement, [], function(err, results) {
		if (err) {
			that.error('Error in select join InstalledVersion, Version', err);
		}
		if (results.length === 0) {
			that.error('There are no installed versions', locale);
		}
		processRow(results, 0);
	});
		
	function processRow(results, index) {
		if (index < results.length) {
			var row = results[index];
			console.log(row);
			if (row.localeDefault) {
				defaultSettingsJS.push('\t\tcase "', row.localeDefault, '": return("', row.filename, '");\n');
				if (row.localeDefault === 'en') {
					defaultVersion = row.filename;
				}
			}
			initSettingsJS.push('\tthis.setVersion("' + row.versionCode + '", "' + row.filename + '");\n');
			that.copyFile('../../DBL/5ready/' + row.filename, '../YourBible/www/', function() {
				console.log('Finished copy', row.filename);
				processRow(results, index + 1);
			});
		} else {
			initSettingsJS.push('};\n');
			if (defaultVersion == null) {
				this.error('There is no default version for English');
			}
			defaultSettingsJS.push('\t\tdefault: return("', defaultVersion, '");\n');
			defaultSettingsJS.push('\t}\n');
			defaultSettingsJS.push('};\n');
			var generatedJS = initSettingsJS.join('') + defaultSettingsJS.join('');
			that.fs.writeFile('../YourBible/www/js/SettingStorageInitSettings.js', generatedJS, {encoding: 'utf8'}, function(err) {
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


var database = new InstallVersions({filename: './Versions.db', verbose: true});
database.install(function() {
	console.log('INSTALL VERSIONS COMPLETED SUCESSFULLY');
});

module.exports = InstallVersions;
