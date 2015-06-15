/*
 * Please see the included README.md file for license terms and conditions.
 */


// This file is a suggested starting place for your code.
// It is completely optional and not required.
// Note the reference that includes it in the index.html file.


/*jslint browser:true, devel:true, white:true, vars:true */
/*global $:false, intel:false app:false, dev:false, cordova:false */


// For improved debugging and maintenance of your app, it is highly
// recommended that you separate your JavaScript from your HTML files.
// Use the addEventListener() method to associate events with DOM elements.
// For example:

// var el ;
// el = document.getElementById("id_myButton") ;
// el.addEventListener("click", myEventHandler, false) ;



// The function below is an example of the best place to "start" your app.
// It calls the standard Cordova "hide splashscreen" function. You can add
// other code to it or add additional functions that are triggered by the same
// event. The app.Ready event used here is created by the init-dev.js file.
// It serves as a unifier for a variety of "ready" events. See the init-dev.js
// file for more details. If you prefer the Cordova deviceready event, you can
// use that in addition to, or instead of this event.

// NOTE: change "dev.LOG" in "init-dev.js" to "true" to enable some console.log
// messages that can help you debug Cordova app initialization issues.
"use strict";
function onAppReady() {
//    if( navigator.splashscreen && navigator.splashscreen.hide ) {   // Cordova API detected
//        navigator.splashscreen.hide() ;
//    }
	console.log('DEVICE IS READY **');
	//var bibleApp = new AppViewController('WEB'); // Global root of the application
	//bibleApp.begin('QuestionsView')
	//bibleApp.begin('HistoryView');
	//bibleApp.begin();
    
    var fs = new DeviceFileSystem('document');
    fs.getPersistent(function(fileSystem) {
        window.alert('inside callback of get persistent');
        console.log('inside callback for getPersistent');
        console.log('found fs ', JSON.stringify(fileSystem));
        console.log('after');
    });

//    console.log('before new file reader');
//	var reader = new LocalFileReader('document');
//    console.log('after new file reader');
//    for (var prop in reader) {
//        console.log(prop, ' = ', reader.prop);
//    }
//    var filepath = 'concordance.json';
//	reader.readTextFile(filepath, function(result) {
//		console.log(result);
//	});
}
document.addEventListener("app.Ready", onAppReady, false) ;

function DeviceFileSystem(location) {
    this.location = location;
    this.persistentFileSystem;
    Object.seal(this);
}
DeviceFileSystem.prototype.getPersistent = function(callback) {
	var that = this;
	if (this.persistentFileSystem) {
        console.log('is true');
        callback(this.persistentFileSystem);
    } else {
        var allocate = 1 * 1024 * 1024 * 1024;
		window.requestFileSystem(LocalFileSystem.PERSISTENT, allocate, successCallback, failureCallback);
	}

	function successCallback(fileSystem) {
        //console.log('success ', fileSystem);
		that.persistentFileSystem = fileSystem;
		callback(that.persistentFileSystem);
	}
	function failureCallback(error) {
        console.log('error ', error);
		console.log('Error', error, error.code);
		callback(null);
	}    
};
    

function LocalFileReader(location) {
	this.location = location;
//	this.filepath = '';
//	this.successCallback = '';
//	this.failureCallback = '';
	this.persistentFileSystem = null;
	Object.seal(this);
}
LocalFileReader.prototype.readTextFile = function(filepath, callback) {
	this.getPersistentFileSystem(function(fileSystem) {
        console.log('filesystem', fileSystem, JSON.stringify(fileSystem));
		window.alert('name: ' + fileSystem.root.name);
		window.alert('root: ' + fileSystem.root.fullPath);
		window.alert('native: ' + fileSystem.root.nativeURL);
		//window.alert('inside access success ' + bytes);
		//console.log('inside access success reading: ' + filepath);
	});
};


