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
	this.uri = encodeURI('http://' + host + ':' + port + '/down/');
	this.basePath = 'cdvfile://localhost/persistent/';
}
FileDownloader.prototype.download = function(bibleVersion, callback) {
	var remotePath = this.uri + bibleVersion;
	//if (device === 'ios') {
		var filePath = this.basePath + '../LocalDatabase/' + bibleVersion + '.sqlite';
	//} else {
	//	filePath = this.basePath + filename;
	//}
	console.log('download to', filePath);
    this.fileTransfer.download(remotePath, filePath, onSuccess, onError, true, {});

    function onSuccess(entry) {
    	console.log("download complete: ", JSON(entry));//.toURL());
       	//callback(entry.toURL());
       	callback(entry);   	
    }
    function onError(error) {
    	console.log("download error source " + error.source);
      	console.log("download error target " + error.target);
       	console.log("download error code" + error.code);
       	callback(new IOError({ code: error.code, message: error.source}));   	
    }
    //	function(entry) {
    //    	console.log("download complete: ", JSON(entry));//.toURL());
    //    	//callback(entry.toURL());
    //    	callback(entry);
    //   	},
    //   	function(error) {
    //    	console.log("download error source " + error.source);
    //       	console.log("download error target " + error.target);
    //       	console.log("download error code" + error.code);
    //       	callback(new IOError({ code: error.code, message: error.source}));
	//	},
    //	true,
    //    {
    //    	// some kind of header is needed.
    //    	headers: {"Authorization": "Basic dGVzdHVzZXJuYW1lOnRlc3RwYXNzd29yZA==" }
    //    }
	//);
};