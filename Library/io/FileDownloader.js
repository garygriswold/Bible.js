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
	this.basePath = 'cdvfile://localhost/persistent/';
}
FileDownloader.prototype.download = function(bibleVersion, callback) {
	var remotePath = this.uri + bibleVersion;
	var filePath = this.basePath + '../LocalDatabase/' + bibleVersion;
	console.log('download from', remotePath, ' to', filePath);
    this.fileTransfer.download(remotePath, filePath, onDownSuccess, onDownError, true, {});

    function onDownSuccess(entry) {
    	console.log("download complete: ", JSON.stringify(entry));
       	callback(entry);   	
    }
    function onDownError(error) {
    	console.log("download error source " + error.source);
      	console.log("download error target " + error.target);
       	console.log("download error code" + error.code);
       	callback(new IOError({ code: error.code, message: error.source}));   	
    }
};