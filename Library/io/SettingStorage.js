/**
* This class replaces window.localStorage, because I had reliability problems with LocalStorage
* on ios Simulator.  I am guessing the problems were caused by the WKWebView plugin, but I don't really know.
*/
function SettingStorage() {
    this.className = 'SettingStorage';
    this.database = new DatabaseHelper('Settings.db', false);
	Object.seal(this);
}
SettingStorage.prototype.create = function(callback) {
	var that = this;
	this.database.executeDDL('CREATE TABLE IF NOT EXISTS Settings(name TEXT PRIMARY KEY NOT NULL, value TEXT NULL)', function(err) {
		if (err instanceof IOError) {
			console.log('Error creating Settings', err);
		} else {
			var statement = 'CREATE TABLE IF NOT EXISTS Installed(' +
					' version TEXT PRIMARY KEY NOT NULL,' +
					' filename TEXT NOT NULL,' +
					' timestamp TEXT NOT NULL,' +
					' bibleVersion TEXT NOT NULL)';
			that.database.executeDDL(statement, function(err) {
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
SettingStorage.prototype.getAppVersion = function(callback) {
	this.getItem('appVersion', function(version) {
		callback(version);
	});
};
SettingStorage.prototype.setAppVersion = function(appVersion) {
	this.setItem('appVersion', appVersion);
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
SettingStorage.prototype.selectSettings = function(callback) {
	this.database.select('SELECT name, value FROM Settings', [], function(results) {
		if (results instanceof IOError) {
			console.log('Select Settings', JSON.stringify(results));
		} else {
			var map = {};
			for (var i=0; i<results.rows.length; i++) {
	        	var row = results.rows.item(i);
	   			map[row.name] = row.value;     	
        	}
        	callback(map);
		}
	})	
};
SettingStorage.prototype.getInstalledVersions = function(callback) {
	var loadedVersions = {};
	console.log('GetVersions');
	this.database.select('SELECT version, filename, bibleVersion FROM Installed', [], function(results) {
		if (results instanceof IOError) {
			console.log('GetInstalledVersions error', JSON.stringify(results));
		} else {
			console.log('GetVersions, rowCount=', results.rows.length);
        	for (var i=0; i<results.rows.length; i++) {
	        	var row = results.rows.item(i);
	        	loadedVersions[row.version] = {versionCode: row.version, filename: row.filename, bibleVersion: row.bibleVersion };
        	}
		}
		callback(loadedVersions);
	});
};
SettingStorage.prototype.getInstalledVersion = function(versionCode, callback) {
	console.log('GetVersion', versionCode);
	this.database.select('SELECT version, filename, bibleVersion FROM Installed WHERE version=?', [versionCode], function(results) {
		if (results instanceof IOError) {
			console.log('GetInstalledVersion error', JSON.stringify(results));
			callback();
		} else if (results.rows.length === 0) {
			callback();
		} else {
			var row = results.rows.item(0);
			callback({versionCode: row.version, filename: row.filename, bibleVersion: row.bibleVersion});
		}
	});
};
SettingStorage.prototype.setInstalledVersion = function(version, filename, bibleVersion) {
	console.log('SetInstalledVersion', version, filename);
	var now = new Date();
	this.database.executeDML('REPLACE INTO Installed(version, filename, timestamp, bibleVersion) VALUES (?,?,?,?)', 
							[version, filename, now.toISOString(), bibleVersion], function(results) {
		if (results instanceof IOError) {
			console.log('SetVersion error', JSON.stringify(results));
		} else {
			console.log('SetVersion success, rows=', results);
		}
	});
};
SettingStorage.prototype.removeInstalledVersion = function(version, callback) {
	console.log('REMOVE INSTALLED VERSION', version);
	this.database.executeDML('DELETE FROM Installed WHERE version=?', [version], function(results) {
		if (results instanceof IOError) {
			console.log('RemoveInstalledVersion Error', JSON.stringify(results));
		}
		callback();
	});
};
SettingStorage.prototype.bulkReplaceInstalledVersions = function(versions, callback) {
	var that = this;
	this.database.bulkExecuteDML('REPLACE INTO Installed(version, filename, timestamp, bibleVersion) VALUES (?,?,?,?)', versions, function(results) {
		if (results instanceof IOError) {
			console.log('ERROR: Replace All Installed', JSON.stringify(results));
		} else {
			console.log('Replace All Installed', results);
		}
		callback();
	});
};

