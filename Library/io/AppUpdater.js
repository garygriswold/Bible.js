/**
* This class first checks to see if the App is a first install or update.
* It finds if it is a new install by looking for tables in the Settings DB.
* It finds if it is an update by checking the App version number against a copy of the
* App version number stored in the Settings database.  If the versions are
* the same, it is not an update and nothing further needs to be done by this class.
*
* If it is a new install, it finds the Bibles stored in www, and stores their
* identity and bibleVersion in the Installed table of the Settings database.
*
* When it is an update, it first removes the Versions.db from the storageDirectory
* so that opening it will cause the new version from www to be used.
*
* When it is an update, it compares the version number of each installed Bible
* with the current version number for that Bible per the Versions.Identity table.
* When there is a new version, it deletes the current one so that it will be downloaded again.
*
* By deleting the files from the databases directory, it ensures that when one
* of those deleted databases is opened, the DatabaseHelper class will first copy
* the database from the www directory to the databases directory.
*
* NOTE: There is a simpler way of doing this that should be used if this one
* runs into problems.  This solution is as follows:
* Select fils from www and storage to find databases to create two maps
* Buildmap: {versionCode: {versionCode, filename, bibleVersion, location}..}
* Open each database in www and storage to get the version from the Identity table
* Compare the identity in version with the actual identity
* Remove all obsolete files from storage
* Perform a bulk update of Installed with the results
*/
function AppUpdater(settingStorage) {
	this.settingStorage = settingStorage;
	Object.seal(this);
}
AppUpdater.prototype.doUpdate = function(callback) {
	var that = this;
	if (typeof(cordova) !== 'undefined') {
		checkIfInstall(function(isInstall) {
			console.log('Check if Install', isInstall);
			if (isInstall) {
				createTables(function() {
					var database = new VersionsAdapter();
					database.selectInstalledBibleVersions(function(bibleVersionList) {
						that.settingStorage.bulkReplaceInstalledVersions(bibleVersionList, function() {
							updateVersion();
							//dumpSettingsDB(function() {
								callback();
							//});
						});
					});
				});
			} else {
				checkIfUpdate(function(isUpdate) {
					console.log('Check if Update', isUpdate);
					if (isUpdate) {
						getStorageFiles(function(fileMap) {
							var versionsDB = fileMap['Versions.db'];
							removeFile(versionsDB, function() {
								version16xTableUpdate(function() {
									var database = new VersionsAdapter();
									database.selectAllBibleVersions(function(bibleVersionMap) {
										identifyObsolete(bibleVersionMap, function(wwwObsolete, downloadedObsolete) {
											removeWwwObsoleteFiles(fileMap, wwwObsolete, function() {
												database.selectInstalledBibleVersions(function(bibleVersionList) {
													that.settingStorage.bulkReplaceInstalledVersions(bibleVersionList, function() {
														updateInstalled(downloadedObsolete, function() {
															updateVersion();
															//dumpSettingsDB(function() {
																callback();
															//});							
														});
													});
												});
											});
										});
									});
								});
							});
						});
					} else {
						callback();
					}	
				});
			}
		});
	} else {
		checkIfInstall(function(isInstall) {
			if (isInstall) {
				createTables(function() {
					callback();
				});
			} else {
				callback();
			}			
		});
	}
	
	function checkIfInstall(callback) {
		var doFullInstall = false;
		var statement = 'SELECT count(*) AS count FROM sqlite_master WHERE type="table" AND name IN ("Settings", "Installed", "History", "Questions")';
		that.settingStorage.database.select(statement, [], function(results) {
			if (results instanceof IOError) {
				console.log('SELECT sqlite_master ERROR', JSON.stringify(results));
				callback(true);
			} else {
				var num = results.rows.item(0).count;
				console.log('found tables', num);
				callback(num !== 4);
			}
		});
	}
	
	function checkIfUpdate(callback) {
		that.settingStorage.getAppVersion(function(appVersion) {
			callback(BibleAppConfig.versionCode !== appVersion);
		});
	}
	
	function createTables(callback) {
		that.settingStorage.create(function() {
			var history = new HistoryAdapter(that.settingStorage.database);
			history.create(function(){});
			var questions = new QuestionsAdapter(that.settingStorage.database);
			questions.create(function(){});
			callback();
		});
	}
	
	function getStorageFiles(callback) {
		if (deviceSettings.platform() === 'ios') {
			var path = cordova.file.applicationStorageDirectory + 'Library/LocalDatabase/';
		} else {
			path = cordova.file.applicationStorageDirectory + 'databases/';
		}
		getFiles(path, function(fileMap) {
			callback(fileMap);
		});	
	}
	
	function getFiles(filePath, callback) {
		var dirMap = {};
		window.resolveLocalFileSystemURL(filePath, function(dirEntry) {
			if (dirEntry) {
				var dirReader = dirEntry.createReader();
				dirReader.readEntries(function(results) {
					for (var i=0; i<results.length; i++) {
						var file = results[i];
						var filename = file.name;
						var fileType = filename.substr(filename.length -3, 3);
						if (fileType === '.db') {
							dirMap[filename] = file;
						}
					}
					callback(dirMap);
				});
			} else {
				callback(dirMap);
			}
		},
		function(fileError) {
			console.log('RESOLVE ERROR', filePath, JSON.stringify(fileError));
			callback(dirMap);
		});
	}
	
	function version16xTableUpdate(callback) {
		// This code was added for version 1.6.x
		that.settingStorage.database.select('PRAGMA table_info(Installed)', [], function(results) {
			if (results instanceof IOError) {
				console.log('ERROR', JSON.stringify(results), 'AppUpdater.table_info');
				callback();/// do what
			} else {
				var numCol = results.rows.length;
				console.log('num columns found', numCol);
				if (numCol < 3) {
					that.settingStorage.database.executeDML('ALTER TABLE Installed ADD COLUMN bibleVersion TEXT', [], function(results) {
						if (results instanceof IOError) {
							console.log('ERROR', JSON.stringify(results), 'AppUpdater.alterTable');
							callback();
						} else {
							that.settingStorage.database.executeDML('UPDATE Installed SET bibleVersion=?', [1.1], function(results) {
								if (results instanceof IOError) {
									console.log('ERROR', JSON.stringify(results), 'AppUpdater.updateInstalled');
								}
								callback();
							});
						}
					});
				} else {
					callback();
				}
			}
		});		
	}
	/**
	* There are two kinds of obsolete that this function finds: downloadedObsolete, and wwwObsolete.
	*/
	function identifyObsolete(bibleVersionMap, callback) {
		var wwwObsolete = [];
		var downloadedObsolete = [];
		that.settingStorage.getInstalledVersions(function(installedVersions) {
			var installedList = Object.keys(installedVersions);
			for (var i=0; i<installedList.length; i++) {
				var versionCode = installedList[i];
				var installedBible = installedVersions[versionCode];
				var currBible = bibleVersionMap[versionCode];
				if (installedBible.bibleVersion !== currBible.bibleVersion) {
					if (currBible.installed === null) {
						downloadedObsolete.push(currBible);
					} else {
						wwwObsolete.push(currBible);
					}
				}
			}
			//console.log('WWW OBSOLETE', wwwObsolete.slice());
			//console.log('DOWNLOAD OBSOLETE', downloadedObsolete.slice());
			callback(wwwObsolete, downloadedObsolete);
		});
	}
	
	function removeWwwObsoleteFiles(fileMap, obsoleteList, callback) {
		var obsolete = obsoleteList.shift();
		if (obsolete) {
			console.log('Remove File', obsolete.filename);
			var file = fileMap[obsolete.filename];
			removeFile(file, function() {
				removeWwwObsoleteFiles(fileMap, obsoleteList, callback);
			});
		} else {
			callback();
		}
	}
	
	function updateInstalled(obsoleteVersions, callback) {
		var obsolete = obsoleteVersions.shift();
		if (obsolete) {
			that.settingStorage.removeInstalledVersion(obsolete.versionCode, function(results) {
				//if (results instanceof IOError) {
				//	console.log('ERROR', JSON.stringify(results), 'AppUpdater.updateInstalled');
				//}
				updateInstalled(obsoleteVersions, callback);
			});
		} else {
			callback();
		}
	}
	
	function removeFile(file, callback) {
		if (file) {
			file.remove(function() {
				console.log('REMOVE FROM /databases SUCCESS', file.name);
				callback();
			}, 
			function(fileError) {
				console.log('REMOVE ERROR', file.name, JSON.stringify(fileError));
				callback();
			});
		} else {
			callback();
		}
	}
	
	function dumpSettingsDB(callback) {
		that.settingStorage.selectSettings(function(settingsMap) {
			console.log('SHOW SETTINGS', JSON.stringify(settingsMap));
			that.settingStorage.getInstalledVersions(function(installedMap) {
				var keys = Object.keys(installedMap);
				for (var i=0; i<keys.length; i++) {
					var installed = installedMap[keys[i]];
					console.log('INSTALLED', installed.filename, installed.bibleVersion);
				}
				getStorageFiles(function(fileMap) {
					console.log('LIST STORAGE FILES', Object.keys(fileMap));
					callback();
				});
			});
		});
	}
	
	function updateVersion() {
		that.settingStorage.setAppVersion(BibleAppConfig.versionCode);
	}
};
