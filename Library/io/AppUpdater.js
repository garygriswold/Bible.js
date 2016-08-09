/**
* This class first checks to see if the App is a first install or update.
* It does this by checking the App version number against a copy of the
* App version number stored in the Settings database.  If the versions are
* the same, it is not an update and nothing further needs to be done by this class.
*
* Next this class gets a list of all the database (.db) files in the www
* directory and a map of all the database files in the databases directory.
* For every database present in the www directory, it deletes the corresponding
* file in the databases directory.
*
* By deleting the files from the databases directory, it ensures that when one
* of those deleted databases is opened, the DatabaseHelper class will first copy
* the database from the www directory to the databases directory.
*/
function AppUpdater(settingStorage) {
	this.settingStorage = settingStorage;
	Object.seal(this);
}
AppUpdater.prototype.doUpdate = function(callback) {
	var that = this;
	this.checkIfInstall(function(isInstall) {
		console.log('Check if Install', isInstall);
		if (isInstall) {
			that.createTables(function() {
				that.moveFiles(function() {
					callback();
				});
			});
		} else {
			that.checkIfUpdate(function(isUpdate) {
				console.log('Check if Update', isUpdate);
				if (isUpdate) {
					that.moveFiles(function() {
						callback();
					});
				} else {
					callback();
				}
			});
		}
	});
};
AppUpdater.prototype.checkIfInstall = function(callback) {
	var that = this;
	var doFullInstall = false;
	var statement = 'SELECT count(*) AS count FROM sqlite_master WHERE type="table" AND name IN ("Settings", "Installed", "History", "Questions")';
	var db = this.settingStorage.database;
	db.select(statement, [], function(results) {
		if (results instanceof IOError) {
			console.log('SELECT sqlite_master ERROR', JSON.stringify(results));
			callback(true);
		} else {
			var num = results.rows.item(0).count;
			console.log('found tables', num);
			callback(num !== 4);
		}
	});
};
AppUpdater.prototype.checkIfUpdate = function(callback) {
	this.settingStorage.getAppVersion(function(appVersion) {
		callback(BuildInfo.version !== appVersion);
	});
};
AppUpdater.prototype.createTables = function(callback) {
	var that = this;
	this.settingStorage.create(function() {
		var history = new HistoryAdapter(that.settingStorage.database);
		history.create(function(){});
		var questions = new QuestionsAdapter(that.settingStorage.database);
		questions.create(function(){});
		callback();
	});
};
AppUpdater.prototype.moveFiles = function(callback) {
	var that = this;
	var sourceDir = null;
	var targetDir = null;
	var sourceDirEntry = null;
	var targetDirEntry = null;
	try {
		sourceDir = cordova.file.applicationDirectory + 'www/';
		if (deviceSettings.platform() === 'ios') {
			targetDir = cordova.file.applicationStorageDirectory + 'Library/LocalDatabase/';
		} else {
			targetDir = cordova.file.applicationStorageDirectory + 'databases/';
		}
		readDirectories(sourceDir, targetDir, callback);
	} catch(err) {
		sourceDir = 'www/';
		targetDir = '../../../Library/Application Support/BibleAppNW/databases/file__0/';
		console.log('Unable to AppUpdater.moveFiles in BibleAppNW');
		//readDirectories(sourceDir, targetDir, callback); window.resolve... does not work for node-webkit
		callback();
	}

	function readDirectories(sourceDir, targetDir, callback) {
		getDirEntry(sourceDir, function(dirEntry) {
			sourceDirEntry = dirEntry;
			getFiles(dirEntry, function(sourceDirMap, sourceDirArray) {
				getDirEntry(targetDir, function(dirEntry) {
					targetDirEntry = dirEntry;
					getFiles(dirEntry, function(targetDirMap, targetDirArray) {
						doRemoves(0, sourceDirArray, targetDirMap, function() {
							updateSettings(Object.keys(sourceDirMap), Object.keys(targetDirMap));
							callback();
						});
					});
				});
			});
		});
	}
	
	function getDirEntry(filePath, callback) {
		window.resolveLocalFileSystemURL(filePath, function(dirEntry) {
			callback(dirEntry);
		},
		function(fileError) {
			console.log('RESOLVE ERROR', filePath, JSON.stringify(fileError));
			callback();
		});
	}
	
	function getFiles(dirEntry, callback) {
		var dirMap = {};
		var dirArray = [];
		if (dirEntry) {
			var dirReader = dirEntry.createReader();
			dirReader.readEntries (function(results) {
				for (var i=0; i<results.length; i++) {
					var file = results[i];
					var filename = file.name;
					var fileType = filename.substr(filename.length -3, 3);
					if (fileType === '.db') {
						dirMap[filename] = file;
						dirArray.push(file);
					}
				}
				callback(dirMap, dirArray);
			});
		} else {
			callback(dirMap, dirArray);
		}	
	}
	
	function doRemoves(index, sourceFiles, targetFiles, callback) {
		if (index >= sourceFiles.length) {
			that.updateVersion();
			callback();
		} else {
			var source = sourceFiles[index];
			console.log('CHECK FOR REMOVE FROM /databases', source.name);
			var target = targetFiles[source.name];
			if (target) {
				target.remove(function() {
					console.log('REMOVE FROM /databases SUCCESS', target.name);
					doRemoves(index + 1, sourceFiles, targetFiles, callback);
				}, 
				function(fileError) {
					console.log('REMOVE ERROR', target.name, JSON.stringify(fileError));
					doRemoves(index + 1, sourceFiles, targetFiles, callback);
				});
			} else {
				console.log('REMOVE SKIPPED nothing to remove', source.name);
				doRemoves(index + 1, sourceFiles, targetFiles, callback);
			}
		}
	}
	
	function updateSettings(sourceFiles, targetFiles) {
		var files = sourceFiles.concat(targetFiles);
		var replace = {};
		var now = new Date().toISOString();
		for (var i=0; i<files.length; i++) {
			var filename = files[i];
			var version = filename.split('.')[0];
			var nameEnd = (filename.length > 7) ? filename.substr(filename.length - 7) : '';
			if (version !== 'Settings' && version !== 'Versions' && nameEnd !== 'User.db') {
				replace[version] = [version, filename, now];
				console.log('SET INSTALLED', version, filename);
			}			
		}
		var values = objectValues(replace);
		that.settingStorage.bulkReplaceVersions(values, now);
	}
	
	function objectValues(map) {
		var values = [];
		var keys = Object.keys(map);
		for (var i=0; i<keys.length; i++) {
			var key = keys[i];
			values.push(map[key]);
		}
		return(values);
	}
};
AppUpdater.prototype.updateVersion = function() {
	this.settingStorage.setAppVersion(BuildInfo.version);
};

