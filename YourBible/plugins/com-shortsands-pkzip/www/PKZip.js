/**
* A consistent interface pattern is applied here.
* 1. Each native method can return success or error.
* 2. The errors are output to the console.log here
* 3. Methods that return data when there is a success
* will return a null when there is an error.
* 4. Native methods that return no data when there is a success
* will return true here and false if there was an error.
*/
"use strict";
var exec = require('cordova/exec');

exports.echo1 = function(message, callback) {
	console.log("PKZip.echo1 " + message);
	callback(message);	
};

exports.echo2 = function(message, callback) {
	console.log("INSIDE echo2");
	exec(callback, function(error) {
		PKZip.logError("echo2", error, message, null, null);
		callback(error);
	}, "PKZip", "echo2", [message]);	
};

exports.echo3 = function(message, callback) {
	console.log("INSIDE echo3");
	exec(callback, function(error) {
		PKZip.logError("echo3", error, message, null, null);
		callback(error);
	}, "PKZip", "echo3", [message]);	
};

exports.zip = function(sourceFile, targetFile, callback) {
    exec(function() { 
	    callback(true); 
	}, function(error) {
	    console.log("ERROR: PKZip.zip " + sourceFile + " " + error);
	    callback(false);
    }, "PKZip", "zip", [sourceFile, targetFile]);
};

exports.unzip = function(sourceFile, targetDir, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
	    console.log("ERROR: PKZip.unzip " + sourceFile + " " + error);
	    callback(false);		    
    }, "PKZip", "unzip", [sourceFile, targetDir]);
};

exports.logError = function(method, error, s3Bucket, s3Key, filePath) {
	var msg = ["\nERROR: PKZip."];
	msg.push(method);
	if (s3Bucket) msg.push(" " + s3Bucket);
	if (s3Key) msg.push("." + s3Key);
	if (filePath) msg.push(" " + filePath);
	msg.push(" -> " + error);
	console.log(msg.join(""));	
};
