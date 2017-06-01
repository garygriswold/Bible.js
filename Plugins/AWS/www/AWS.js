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
	console.log("AWS.echo1 " + message);
	callback(message);	
};

exports.echo2 = function(message, callback) {
	console.log("INSIDE echo2");
	exec(callback, function(error) {
		AWS.logError("echo2", error, message, null, null);
		callback(error);
	}, "AWS", "echo2", [message]);	
};

exports.echo3 = function(message, callback) {
	console.log("INSIDE echo3");
	exec(callback, function(error) {
		AWS.logError("echo3", error, message, null, null);
		callback(error);
	}, "AWS", "echo3", [message]);	
};

exports.initialize = function(regionName, callback) {
	exec(function() {
		callback(true);
	}, function(error) {
		console.log("ERROR: AWS.initialize " + error);
		callback(false);
	}, "AWS", "initialize", [regionName]);
};

exports.preSignedUrlGET = function(s3Bucket, s3Key, expires, callback) {
    exec(callback, function(error) {
	    AWS.logError("preSignedUrlGET", error, s3Bucket, s3Key, null);
	    callback(null);
    }, "AWS", "preSignedUrlGET", [s3Bucket, s3Key, expires]);
};

exports.preSignedUrlPUT = function(s3Bucket, s3Key, expires, contentType, callback) {
    exec(callback, function(error) {
	    AWS.logError("preSignedUrlPUT", error, s3Bucket, s3Key, null);
	    callback(null);		    
    }, "AWS", "preSignedUrlPUT", [s3Bucket, s3Key, expires, contentType]);
};

exports.downloadText = function(s3Bucket, s3Key, callback) {
    exec(callback, function(error) {
		AWS.logError("downloadText", error, s3Bucket, s3Key, null);
	    callback(null);			    
    }, "AWS", "downloadText", [s3Bucket, s3Key]);
};

exports.downloadData = function(s3Bucket, s3Key, callback) {
    exec(callback, function(error) {
	    AWS.logError("downloadData", error, s3Bucket, s3Key, null);
	    callback(null);			    
    }, "AWS", "downloadData", [s3Bucket, s3Key]);
};

exports.downloadFile = function(s3Bucket, s3Key, filePath, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
		AWS.logError("downloadFile", error, s3Bucket, s3Key, filePath);
	    callback(false);			    
    }, "AWS", "downloadFile", [s3Bucket, s3Key, filePath]);
};

exports.downloadZipFile = function(s3Bucket, s3Key, filePath, callback) {
    exec(function() {
	    callback(true);
	},  function(error) {
		AWS.logError("downloadZipFile", error, s3Bucket, s3Key, filePath);
	    callback(false);			    
    }, "AWS", "downloadZipFile", [s3Bucket, s3Key, filePath]);
};

exports.uploadVideoAnalytics = function(sessionId, timestamp, data, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
		AWS.logError("uploadVideoAnalytics", error, sessionId, timestamp, null);
	    callback(false);				
	}, "AWS", "uploadVideoAnalytics", [sessionId, timestamp, data]);
};

exports.uploadText = function(s3Bucket, s3Key, data, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
		AWS.logError("uploadText", error, s3Bucket, s3Key, null);
	    callback(false);		
	}, "AWS", "uploadText", [s3Bucket, s3Key, data]);
};

exports.uploadData = function(s3Bucket, s3Key, data, contentType, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
		AWS.logError("uploadData", error, s3Bucket, s3Key, null);
	    callback(false);			
	}, "AWS", "uploadData", [s3Bucket, s3Key, data, contentType]);
};

exports.uploadFile = function(s3Bucket, s3Key, filePath, contentType, callback) {
    exec(function() {
	    callback(true);
    }, function(error) {
	    AWS.logError("uploadFile", error, s3Bucket, s3Key, filePath);
	    callback(false);		    
    }, "AWS", "uploadFile", [s3Bucket, s3Key, filePath, contentType]);
};

exports.zip = function(sourceFile, targetFile, callback) {
    exec(function() { 
	    callback(true); 
	}, function(error) {
	    console.log("ERROR: AWS.zip " + sourceFile + " " + error);
	    callback(false);
    }, "AWS", "zip", [sourceFile, targetFile]);
};

exports.unzip = function(sourceFile, targetDir, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
	    console.log("ERROR: AWS.unzip " + sourceFile + " " + error);
	    callback(false);		    
    }, "AWS", "unzip", [sourceFile, targetDir]);
};

exports.logError = function(method, error, s3Bucket, s3Key, filePath) {
	var msg = ["\nERROR: AWS."];
	msg.push(method);
	if (s3Bucket) msg.push(" " + s3Bucket);
	if (s3Key) msg.push("." + s3Key);
	if (filePath) msg.push(" " + filePath);
	msg.push(" -> " + error);
	console.log(msg.join(""));	
};
