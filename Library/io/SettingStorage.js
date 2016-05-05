/**
* This class replaces window.localStorage, because I had reliability problems with LocalStorage
* on ios Simulator.  I am guessing the problems were caused by the WKWebView plugin, but I don't really know.
*/
function SettingStorage() {
    this.className = 'SettingStorage';
    this.database = new DatabaseHelper('Settings.db', false);
    this.loadedVersions = null;
	Object.seal(this);
}
SettingStorage.prototype.create = function(callback) {
	var that = this;
	this.database.executeDDL('CREATE TABLE IF NOT EXISTS Settings(name TEXT PRIMARY KEY NOT NULL, value TEXT NULL)', function(err) {
		if (err instanceof IOError) {
			console.log('Error creating Settings', err);
		} else {
			that.database.executeDDL('CREATE TABLE IF NOT EXISTS Installed(version TEXT PRIMARY KEY NOT NULL, filename TEXT NOT NULL, timestamp TEXT NOT NULL)', function(err) {
				if (err instanceof IOError) {
					console.log('Error creating Installed', err);
				} else {
					callback();
				}
			});
		}
	});
};
/**
* Settings
*/
SettingStorage.prototype.getFontSize = function(callback) {
	this.getItem('fontSize', function(fontSize) {
		if (fontSize < 10 || fontSize > 36) fontSize = null; // Null will force calc of fontSize.
		callback(fontSize);
	});
};
SettingStorage.prototype.setFontSize = function(fontSize) {
	this.setItem('fontSize', fontSize);
};
SettingStorage.prototype.getMaxFontSize = function(callback) {
	this.getItem('maxFontSize', function(maxFontSize) {
		callback(maxFontSize);
	});
};
SettingStorage.prototype.setMaxFontSize = function(maxFontSize) {
	this.setItem('maxFontSize', maxFontSize);	
};
SettingStorage.prototype.getCurrentVersion = function(callback) {
	this.getItem('version', function(filename) {
		callback(filename);
	});
};
SettingStorage.prototype.setCurrentVersion = function(filename) {
	this.setItem('version', filename);
};
SettingStorage.prototype.getItem = function(name, callback) {
	this.database.select('SELECT value FROM Settings WHERE name=?', [name], function(results) {
		if (results instanceof IOError) {
			console.log('GetItem', name, JSON.stringify(results));
			callback();
		} else {
			var value = (results.rows.length > 0) ? results.rows.item(0).value : null;
        	console.log('GetItem', name, value);
			callback(value);
		}
	});
};
SettingStorage.prototype.setItem = function(name, value) {
    this.database.executeDML('REPLACE INTO Settings(name, value) VALUES (?,?)', [name, value], function(results) {
	   if (results instanceof IOError) {
		   console.log('SetItem', name, value, JSON.stringify(results));
	   } else {
		   console.log('SetItem', name, value);
	   }
    });
};
/**
* Versions
*/
/** Before calling hasVersion one must call getVersions, which creates a map of available versions
* And getVersions must be called a few ms before any call to hasVersion to make sure result is available.
*/
SettingStorage.prototype.hasVersion = function(version) {
	return(this.loadedVersions[version]);
};
SettingStorage.prototype.getVersions = function() {
	var that = this;
	console.log('GetVersions');
	this.database.select('SELECT version, filename FROM Installed', [], function(results) {
		if (results instanceof IOError) {
			console.log('GetVersions error', JSON.stringify(results));
		} else {
			console.log('GetVersions, rowCount=', results.rows.length);
        	that.loadedVersions = {};
        	for (var i=0; i<results.rows.length; i++) {
	        	var row = results.rows.item(i);
	        	that.loadedVersions[row.version] = row.filename;
        	}
		}
	});
};
SettingStorage.prototype.setVersion = function(version, filename) {
	console.log('SetVersion', version, filename);
	var now = new Date();
	this.database.executeDML('REPLACE INTO Installed(version, filename, timestamp) VALUES (?,?,?)', [version, filename, now.toISOString()], function(results) {
		if (results instanceof IOError) {
			console.log('SetVersion error', JSON.stringify(results));
		} else {
			console.log('SetVersion success', results.rowsAffected);
		}
	});
};
