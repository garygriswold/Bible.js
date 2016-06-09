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
function FileMover(settingStorage) {
	this.settingStorage = settingStorage;
	Object.seal(this);
}
FileMover.prototype.copyFiles = function(callback) {
	var that = this;
	var sourceDir = null;
	var targetDir = null;
	var sourceDirEntry = null;
	var targetDirEntry = null;
	this.settingStorage.getAppVersion(function(appVersion) {
		try {
			if (BuildInfo.version === appVersion) {
				callback();
			} else {
				sourceDir = cordova.file.applicationDirectory + 'www/';
				if (deviceSettings.platform() === 'ios') {
					targetDir = cordova.file.applicationStorageDirectory + 'Library/LocalDatabase/';
				} else {
					targetDir = cordova.file.applicationStorageDirectory + 'databases/';
				}
				readDirectories(sourceDir, targetDir, callback);
			}
		} catch(err) {
			sourceDir = 'www/';
			targetDir = '../../../Library/Application Support/BibleAppNW/databases/file__0/';
			//readDirectories(sourceDir, targetDir, callback); window.resolve... does not work for node-webkit
			callback();
		}
	});
	
	function readDirectories(sourceDir, targetDir, callback) {
		getDirEntry(sourceDir, function(dirEntry) {
			sourceDirEntry = dirEntry;
			getFiles(dirEntry, function(sourceDirMap, sourceDirArray) {
				getDirEntry(targetDir, function(dirEntry) {
					targetDirEntry = dirEntry;
					getFiles(dirEntry, function(targetDirMap, targetDirArray) {
						doRemoves(0, sourceDirArray, targetDirMap, callback);
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
		if (index >= Object.keys(sourceFiles).length) {
			that.settingStorage.setAppVersion(BuildInfo.version);
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
				doRemoves(index + 1, sourceFiles, targetFiles, callback);
			}
		}
	}
};

