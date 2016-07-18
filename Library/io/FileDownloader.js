/**
* This class encapsulates the Cordova FileTransfer plugin for file download
* It is a simple plugin, but encapsulated here in order to make it easy to change
* the implementation.
*
* 'persistent' will store the file in 'Documents' in Android and 'Library' in iOS
* 'LocalDatabase' is the file under Library where the database is expected.
*/
function FileDownloader(host, port, currVersion) {
	this.fileTransfer = new FileTransfer();
	this.uri = encodeURI('http://' + host + ':' + port + '/book/');
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
	var that = this;
	var bibleVersionZip = bibleVersion + '.zip';
	var remotePath = this.uri + bibleVersionZip;
	var tempPath = this.downloadPath + bibleVersionZip;
	console.log('download from', remotePath, ' to ', tempPath);
	var datetime = new Date().toISOString();
	var encrypted = CryptoJS.AES.encrypt(datetime, CREDENTIAL.key);
	getLocale(function(locale) {
		var options = { 
			headers: {
				'Authorization': 'Signature  ' + CREDENTIAL.id + '  ' + CREDENTIAL.version + '  ' + encrypted,
				'x-time': datetime,
				'x-locale': locale,
				'x-referer-version': that.currVersion
			}
		};
	    that.fileTransfer.download(remotePath, tempPath, onDownSuccess, onDownError, true, options);
	});
    
    function getLocale(callback) {
		preferredLanguage(function(pLocale) {
			localeName(function(locale) {
				callback(pLocale + ',' + locale);
			});
		});
	}
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
