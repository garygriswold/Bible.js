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
	console.log("INSIDE echo1");
	callback(message);	
};

exports.echo2 = function(message, callback) {
	console.log("INSIDE echo2");
	exec(callback, function(error) {
		console.log("ERROR in echo2 " + error);
		callback(error);
	}, "AWS", "echo2", [message]);	
};

exports.echo3 = function(message, callback) {
	console.log("INSIDE echo3");
	exec(callback, function(error) {
		console.log("ERROR in echo3 " + error);
		callback(error);
	}, "AWS", "echo3", [message]);	
};

//// This is not used yet
exports.initialize = function(callback) {
	exec(function() {
		callback(true);
	}, function(error) {
		console.log("ERROR: AWS.initialize " + error);
		callback(false);
	}, "AWS", "initialize", []);
};

exports.preSignedUrlGET = function(s3Bucket, s3Key, expires, callback) {
    exec(callback, function(error) {
	    console.log("ERROR: AWS.preSignedUrlGET " + error);
	    callback(null);
    }, "AWS", "preSignedUrlGET", [s3Bucket, s3Key, expires]);
};

exports.preSignedUrlPUT = function(s3Bucket, s3Key, expires, contentType, callback) {
    exec(callback, function(error) {
	    console.log("ERROR: AWS.preSignedUrlPUT " + error);
	    callback(null);		    
    }, "AWS", "preSignedUrlPUT", [s3Bucket, s3Key, expires, contentType]);
};

exports.zip = function(sourceFile, targetDir, callback) {
    exec(function() { 
	    callback(true); 
	}, function(error) {
	    console.log("ERROR: AWS.zip " + error);
	    callback(false);
    }, "AWS", "zip", [sourceFile, targetDir]);
};

exports.unzip = function(sourceFile, targetDir, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
	    console.log("ERROR: AWS.unzip " + error);
	    callback(false);		    
    }, "AWS", "unzip", [sourceFile, targetDir]);
};

exports.downloadText = function(s3Bucket, s3Key, callback) {
    exec(callback, function(error) {
	    console.log("ERROR: AWS.downloadText " + error);
	    callback(null);			    
    }, "AWS", "downloadText", [s3Bucket, s3Key]);
};

exports.downloadData = function(s3Bucket, s3Key, callback) {
    exec(callback, function(error) {
	    console.log("ERROR: AWS.downloadData " + error);
	    callback(null);			    
    }, "AWS", "downloadData", [s3Bucket, s3Key]);
};

exports.downloadFile = function(s3Bucket, s3Key, filePath, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
	    console.log("ERROR: AWS.downloadFile " + error);
	    callback(false);			    
    }, "AWS", "downloadFile", [s3Bucket, s3Key, filePath]);
};

exports.downloadZipFile = function(s3Bucket, s3Key, filePath, callback) {
    exec(function() {
	    callback(true);
	},  function(error) {
	    console.log("ERROR: AWS.downloadZipFile " + error);
	    callback(false);			    
    }, "AWS", "downloadZipFile", [s3Bucket, s3Key, filePath]);
};

exports.uploadVideoAnalytics = function(sessionId, timestamp, data, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
	    console.log("ERROR: AWS.uploadVideoAnalytics " + error);
	    callback(false);				
	}, "AWS", "uploadVideoAnalytics", [sessionId, timestamp, data]);
};

exports.uploadText = function(s3Bucket, s3Key, data, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
	    console.log("ERROR: AWS.uploadText " + error);
	    callback(false);		
	}, "AWS", "uploadText", [s3Bucket, s3Key, data]);
};

exports.uploadData = function(s3Bucket, s3Key, data, contentType, callback) {
    exec(function() {
	    callback(true);
	}, function(error) {
	    console.log("ERROR: AWS.uploadData " + error);
	    callback(false);			
	}, "AWS", "uploadData", [s3Bucket, s3Key, data, contentType]);
};

exports.uploadFile = function(s3Bucket, s3Key, filePath, contentType, callback) {
    exec(function() {
	    callback(true);
    }, function(error) {
	    console.log("ERROR: AWS.uploadFile " + error);
	    callback(false);		    
    }, "AWS", "uploadFile", [s3Bucket, s3Key, filePath, contentType]);
};
