/**
* This class encapsulates the Cordova FileTransfer plugin for file download
* It is a simple plugin, but encapsulated here in order to make it easy to change
* the implementation.
*
* 'persistent' will store the file in 'Documents' in Android and 'Library' in iOS
* 'LocalDatabase' is the file under Library where the database is expected.
*/
function FileDownloader(host, port, database, currVersion) {
	this.host = host;
	this.port = port;
	this.database = database;
	this.currVersion = currVersion;
	this.downloadPath = 'cdvfile://localhost/temporary/';
	if (deviceSettings.platform() === 'ios') {
		this.finalPath = 'cdvfile://localhost/persistent/../LocalDatabase/';
	} else {
		this.finalPath = '/data/data/com.shortsands.yourbible/databases/';
	}
	Object.seal(this);
}
FileDownloader.prototype.download = function(bibleVersion, callback) {
	if (this.host.indexOf('shortsands') > -1) {
		this._downloadShortSands(bibleVersion, callback);
	} else if (this.host.indexOf('cloudfront') > -1) {
		this._downloadCloudfront(bibleVersion, callback);
	} else {
		console.log('ERROR: cannot download from host=', this.host);
		callback();
	}
};
FileDownloader.prototype._downloadShortSands = function(bibleVersion, callback) {
	var that = this;
	var bibleVersionZip = bibleVersion + '.zip';
	var tempPath = this.downloadPath + bibleVersionZip;
	var uri = encodeURI('http://' + this.host + ':' + this.port + '/book/');
	var remotePath = uri + bibleVersionZip;
	console.log('download from', remotePath, ' to ', tempPath);
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
	var bibleVersionZip = bibleVersion + '.zip';
	var tempPath = this.downloadPath + bibleVersionZip;
	this.database.selectURL(bibleVersion, function(remotePath) {
		console.log('download from', remotePath, ' to ', tempPath);
		that._getLocale(function(locale) {
			var options = { 
				headers: {
					'x-locale': locale,
					'x-referer-version': that.currVersion,
					'Connection': 'close'
				}
			};
			that._performDownload(remotePath, tempPath, true, options, callback);
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
		});
	}
	function onDownError(error) {
		callback(new IOError({ code: error.code, message: error.source}));
	}
};
