/**
* This class is the file reader to be used with the Cordova file plugin.
*
* *** This class is not finished.
*/
function FileReader() {
	this.location = '';
	this.filepath = '';
	this.successCallback = '';
	this.failureCallback = '';
	Object.seal(this);
}
FileReader.prototype.readTextFile = function(location, filepath, successCallback, failureCallback) {
	var bytes = 1024 * 1024 * 10;
	var filepath = this.filepath;
	window.requestFileSystem(LocalFileSystem.PERSISTENT, bytes, onAccessReqSuccess, onAccessError);

	function onAccessReqSuccess(fileSystem) {
		window.alert('name: ' + fileSystem.root.name);
		window.alert('root: ' + fileSystem.root.fullPath);
		window.alert('native: ' + fileSystem.root.nativeURL);
		window.alert('inside access success ' + bytes);
		console.log('inside access success reading: ' + filepath);

		fileSystem.root.getFile(filepath, { create:false }, onGetFileSuccess, onGetFileError);

		/*function onWriteFileSuccess(file) {
			window.alert('created file ' + file.name);
			file.createWriter(onSuccess2, onError2);

			function onSuccess2(writer) {
				writer.onabort = function(e) {
					console.log("Write aborted");
				};
				writer.onwritestart = function(e) {
					console.log("Write start");
				};
				writer.onwrite = function(e) {
					console.log("Write completed");
				};
				writer.onwriteend = function(e) {
					console.log("Write end");
				};
				writer.onerror = function(e) {
					console.error("Write error");
					console.error(JSON.stringify(e));
				};
				writer.write("This file created Example 10.1");
			};
			function onError2(err) {
				window.alert('write err ' + err.code);
			};
		};
		function onWriteFileError(err) {
			window.alert('inside write file err ' + err.code);
		};*/
		function onGetFileSuccess(file) {
			//window.alert('fullpath ' + file.fullPath);
			//window.alert('isfile ' + file.isFile);
			//window.alert('url ' + file.nativeURL);

			file.getMetadata(onMetaDataSuccess, onMetaDataError);
			function onMetaDataSuccess(metadata) {
				//window.alert(JSON.stringify(metadata));
			};
			function onMetaDataError(err) {
				//window.alert(JSON.stringify(err));
			};

			var reader = new FileReader();
			var keys = Object.keys(reader);
			//window.alert(keys);
			for (var i=0; i<keys.length; i++) {
			//	window.alert(keys[i] + ': ' + reader[keys[i]]);
			}

			reader.onloadstart = function(evt) {
				//console.log('read file started');
				window.alert('start read ' + JSON.stringify(evt));
			};
			reader.onloadend = function(evt) {
				window.alert('done' + reader.result);
				console.log('read file ended');
				var result = JSON.stringify(evt);
				window.alert(result.substring(0,100));
				console.log(evt.target.result);
			};
			//reader.onloaderror = function(event) {
			//	console.log('error: ' + event.code);
			//};
			reader.readAsText(file, 'utf-8');
			//window.alert('after readAsText');
		};
		function onGetFileError(err) {
			window.alert('error ' + err.code);
		};
	};
	function onAccessError(err) {
		window.alert('inside access error');
	};
};


