/**
* This class encapsulates the Cordova FileTransfer plugin for file download
* It is a simple plugin, but encapsulated here in order to make it easy to change
* the implementation.
*
* 'persistent' will store the file in 'Documents' in Android and 'Library' in iOS
* 'LocalDatabase' is the file under Library where the database is expected.
*/
function FileDownloader(database, locale, currVersion) {
	this.host = 's3.amazonaws.com';
	this.database = database;
	var parts = locale.split('-');
	this.countryCode = parts.pop();
	console.log('Country Code', this.countryCode);
	this.currVersion = currVersion;
	if (deviceSettings.platform() === 'ios') {
		this.downloadPath = cordova.file.tempDirectory;
		this.finalPath = cordova.file.applicationStorageDirectory + 'Library/LocalDatabase/';
	} else {
		this.downloadPath = cordova.file.cacheDirectory;
		this.finalPath = cordova.file.applicationStorageDirectory + 'databases/';
	}
	Object.seal(this);
}
FileDownloader.prototype.download = function(bibleVersion, callback) {
	if (this.host.indexOf('shortsands') > -1) {
		this._downloadShortSands(bibleVersion, callback);
	} else if (this.host.indexOf('cloudfront') > -1) {
		this._downloadCloudfront(bibleVersion, callback);
	} else if (this.host.indexOf('amazonaws.com') > -1) {
		this._downloadAWSS3(bibleVersion, callback);
	} else {
		console.log('ERROR: cannot download from host=', this.host);
		callback();
	}
};
FileDownloader.prototype._downloadShortSands = function(bibleVersion, callback) {
	var that = this;
	var bibleVersionZip = bibleVersion + '.zip';
	var tempPath = this.downloadPath + bibleVersionZip;
	var uri = encodeURI('http://' + this.host + ':8080/book/');
	var remotePath = uri + bibleVersionZip;
	console.log('shortsands download from', remotePath, ' to ', tempPath);
	var datetime = new Date().toISOString();
	var encrypted = CryptoJS.AES.encrypt(datetime, CREDENTIAL.key);
	this._getLocale(function(locale) {
		var options = { 
			headers: {
				'Authorization': 'Signature  ' + CREDENTIAL.id + '  ' + CREDENTIAL.version + '  ' + encrypted,
				'x-time': datetime,
				'x-locale': locale,
				'x-referer-version': that.currVersion
			}
		};
		that._performDownload(remotePath, tempPath, true, options, callback);
	});
};
FileDownloader.prototype._downloadCloudfront = function(bibleVersion, callback) {
	var that = this;
	var tempPath = this.downloadPath + bibleVersion + '.zip';
	this.database.selectURLCloudfront(bibleVersion, function(remotePath) {
		console.log('cloudfront download from', remotePath, ' to ', tempPath);
		that._getLocale(function(locale) {
			var options = { 
				headers: {
					'Cookie': locale + ';' + that.currVersion,
					'Connection': 'close'
				}
			};
			that._performDownload(remotePath, tempPath, false, options, callback);
		});
	});
};
FileDownloader.prototype._downloadAWSS3 = function(bibleVersion, callback) {
	var that = this;
	var tempPath = this.downloadPath + bibleVersion + '.zip';
	this.database.selectURLS3(bibleVersion, this.countryCode, function(remotePath) {
		console.log('aws s3 download from', remotePath, ' to ', tempPath);
		that._getLocale(function(locale) {
			var options = { 
				headers: {
					'Connection': 'close'
				}
			};
			remotePath = remotePath.replace('?', '?X-Locale=' + locale + '&');
			that._performDownload(remotePath, tempPath, false, options, callback);
		});
	});
};
FileDownloader.prototype._getLocale = function(callback) {
	preferredLanguage(function(pLocale) {
		localeName(function(locale) {
			callback(pLocale + ',' + locale);
		});
	});
	function preferredLanguage(callback) {
		navigator.globalization.getPreferredLanguage(
	    	function(locale) { callback(locale.value); },
			function() { callback(''); }
		);
	}
	function localeName(callback) {
		navigator.globalization.getLocaleName(
	    	function(locale) { callback(locale.value); },
			function() { callback(''); }
		);
	}
};
FileDownloader.prototype._performDownload = function(remotePath, tempPath, trustAllHosts, options, callback) {
	var that = this;
	var fileTransfer = new FileTransfer();
	fileTransfer.download(remotePath, tempPath, onDownSuccess, onDownError, trustAllHosts, options);

	function onDownSuccess(entry) {
		console.log("download complete: ", JSON.stringify(entry));
		zip.unzip(tempPath, that.finalPath, function(resultCode) {
	    	if (resultCode == 0) {
	    		console.log('ZIP done', resultCode);
	    		callback();		    	
	    	} else {
		    	callback(new IOError({code: 'unzip failed', message: entry.nativeURL}));
	    	}
	    	that.clearTempDir();
		});
	}
	function onDownError(error) {
		console.log('ERROR File Download', JSON.stringify(error));
		callback(new IOError({ code: error.code, message: error.source}));
	}
};
FileDownloader.prototype.clearTempDir = function() {
	window.resolveLocalFileSystemURL(this.downloadPath, function(dirEntry) {
		var dirReader = dirEntry.createReader();
		dirReader.readEntries(function(files) {
			removeFiles(files);
		});
	});
	function removeFiles(files) {
		var file = files.pop();
		if (file) {
			file.remove(function() {
				console.log('Deleted temp file', file.name);
				removeFiles(files);
			},
			function(error) {
				console.log('Error Deleting temp file', file.name, JSON.stringify(error));
				removeFiles(files);
			});
		}
	}
};
