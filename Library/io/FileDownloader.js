/**
* This class encapsulates the Cordova FileTransfer plugin for file download
* It is a simple plugin, but encapsulated here in order to make it easy to change
* the implementation.
*
* 'persistent' will store the file in 'Documents' in Android and 'Library' in iOS
* 'LocalDatabase' is the file under Library where the database is expected.
*/
function FileDownloader(host, port) {
	this.fileTransfer = new FileTransfer();
	this.uri = encodeURI('http://' + host + ':' + port + '/book/');
	this.downloadPath = 'cdvfile://localhost/temporary/';
	if (deviceSettings.platform() === 'ios') {
		this.finalPath = 'cdvfile://localhost/persistent/../LocalDatabase/';
	} else {
		this.finalPath = '/data/data/com.shortsands.yourbible/databases/';
	}
}
FileDownloader.prototype.download = function(bibleVersion, callback) {
	var that = this;
	var bibleVersionZip = bibleVersion + '.zip';
	var remotePath = this.uri + bibleVersionZip;
	var tempPath = this.downloadPath + bibleVersionZip;
	console.log('download from', remotePath, ' to', tempPath);
    this.fileTransfer.download(remotePath, tempPath, onDownSuccess, onDownError, true, {});

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