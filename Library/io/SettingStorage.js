/**
* This class replaces window.localStorage, because I had reliability problems with LocalStorage
* on ios Simulator.  I am guessing the problems were caused by the WKWebView plugin, but I don't really know.
*/
function SettingStorage() {
    this.className = 'SettingStorage';
    if (window.sqlitePlugin === undefined) {
        console.log('opening SettingsStorage Database, stores in Cache');
        this.database = window.openDatabase('Settings.db', '1.0', 'Settings.db', 1024 * 1024);
    } else {
        console.log('opening SQLitePlugin SettingsStorage Database, stores in Documents with no cloud');
        this.database = window.sqlitePlugin.openDatabase({name: 'Settings.db', location: 2, createFromLocation: 1});
    }
    this.loadedVersions = null;
	Object.seal(this);
}
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
SettingStorage.prototype.getCurrentVersion = function(callback) {
	this.getItem('version', function(filename) {
		callback(filename);
	});
};
SettingStorage.prototype.setCurrentVersion = function(version) {
	this.setItem('version', version);
};
SettingStorage.prototype.getItem = function(name, callback) {
    this.database.readTransaction(function(tx) {
        tx.executeSql('SELECT value FROM Settings WHERE name=?', [name],
        function(tx, results) {
        	//console.log('GetItem, rowCount=', results.rows.length);
        	var value = (results.rows.length > 0) ? results.rows.item(0).value : null;
        	console.log('GetItem', name, value);
			callback(value);
        },
        function(tx, err) {
        	console.log('GetItem', name, JSON.stringify(err));
			callback();        
        });
    });
};
SettingStorage.prototype.setItem = function(name, value) {
    this.database.transaction(function(tx) {
        tx.executeSql('REPLACE INTO Settings(name, value) VALUES (?,?)', [name, value], 
        function(tx, results) {
	        console.log('SetItem', name, value);
	  	},
	  	function(tx, err) {
		  	console.log('SetItem', name, value, JSON.stringify(err));
	  	});
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
    this.database.readTransaction(function(tx) {
        tx.executeSql('SELECT version, filename FROM Installed', [],
        function(tx, results) {
        	console.log('GetVersions, rowCount=', results.rows.length);
        	that.loadedVersions = {};
        	for (var i=0; i<results.rows.length; i++) {
	        	var row = results.rows.item(i);
	        	that.loadedVersions[row.version] = row.filename;
        	}
        },
        function(tx, err) {
        	console.log('select error', JSON.stringify(err));     
        });
    });
};
SettingStorage.prototype.setVersion = function(version, filename) {
	console.log('SetVersion', version, filename);
	var now = new Date();
    this.database.transaction(function(tx) {
        tx.executeSql('REPLACE INTO Installed(version, filename, timestamp) VALUES (?,?,?)', [version, filename, now.toISOString()], 
        function(tx, results) {
	        console.log('SetVersion success', results.rowsAffected);
	  	},
	  	function(tx, err) {
		  	console.log('SetVersion error', JSON.stringify(err));
	  	});
    });
};
