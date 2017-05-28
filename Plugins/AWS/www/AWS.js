"use strict";
/**
* A consistent interface pattern is applied here.
* 1. Each native method can return success or error.
* 2. The errors are output to the console.log here
* 3. Methods that return data when there is a success
* will return a null when there is an error.
* 4. Native methods that return no data when there is a success
* will return true here and false if there was an error.
*/
//module.exports = {
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

/*
var AWS = {
	echo1: function(message, callback) {
		console.log("INSIDE echo1");
		callback(message);	
	},
	echo2: function(message, callback) {
		console.log("INSIDE echo2");
		exec(callback, function(error) {
			console.log("ERROR in echo2 " + error);
			callback(error);
		}, "AwsS3Plugin", "echo2", [message]);	
	},
//	initialize: function(callback) {
//		cordova.exec(function() {
//			callback(true);
//		}, function(error) {
//			console.log("ERROR: AWS.initialize " + error);
//			callback(false);
//		}, "AwsS3Plugin", "initialize", []);
//	},
    preSignedUrlGET: function(s3Bucket, s3Key, expires, callback) {
	    cordova.exec(callback, function(error) {
		    console.log("ERROR: AWS.preSignedUrlGET " + error);
		    callback(null);
	    }, "AwsS3Plugin", "preSignedUrlGET", [s3Bucket, s3Key, expires]);
    },
    preSignedUrlPUT: function(s3Bucket, s3Key, expires, contentType, callback) {
	    cordova.exec(callback, function(error) {
		    console.log("ERROR: AWS.preSignedUrlPUT " + error);
		    callback(null);		    
	    }, "AwsS3Plugin", "preSignedUrlPUT", [s3Bucket, s3Key, expires, contentType]);
    },
    zip: function(sourceFile, targetDir, callback) {
	    cordova.exec(function() { 
		    callback(true); 
		}, function(error) {
		    console.log("ERROR: AWS.zip " + error);
		    callback(false);
	    }, "AwsS3Plugin", "zip", [sourceFile, targetDir]);
    },
    unzip: function(sourceFile, targetDir, callback) {
	    cordova.exec(function() {
		    callback(true);
		}, function(error) {
		    console.log("ERROR: AWS.unzip " + error);
		    callback(false);		    
	    }, "AwsS3Plugin", "unzip", [sourceFile, targetDir]);
    },
    downloadText: function(s3Bucket, s3Key, callback) {
	    cordova.exec(callback, function(error) {
		    console.log("ERROR: AWS.downloadText " + error);
		    callback(null);			    
	    }, "AwsS3Plugin", "downloadText", [s3Bucket, s3Key]);
    },
    downloadData: function(s3Bucket, s3Key, callback) {
	    cordova.exec(callback, function(error) {
		    console.log("ERROR: AWS.downloadData " + error);
		    callback(null);			    
	    }, "AwsS3Plugin", "downloadData", [s3Bucket, s3Key]);
    },
    downloadFile: function(s3Bucket, s3Key, filePath, callback) {
	    cordova.exec(function() {
		    callback(true);
		}, function(error) {
		    console.log("ERROR: AWS.downloadFile " + error);
		    callback(false);			    
	    }, "AwsS3Plugin", "downloadFile", [s3Bucket, s3Key, filePath]);
    },
    downloadZipFile: function(s3Bucket, s3Key, filePath, callback) {
	    cordova.exec(function() {
		    callback(true);
		},  function(error) {
		    console.log("ERROR: AWS.downloadZipFile " + error);
		    callback(false);			    
	    }, "AwsS3Plugin", "downloadZipFile", [s3Bucket, s3Key, filePath]);
    },
    uploadVideoAnalytics: function(sessionId, timestamp, data, callback) {
	    cordova.exec(function() {
		    callback(true);
		}, function(error) {
		    console.log("ERROR: AWS.uploadVideoAnalytics " + error);
		    callback(false);				
		}, "AwsS3Plugin", "uploadVideoAnalytics", [sessionId, timestamp, data]);
    },
    uploadText: function(s3Bucket, s3Key, data, callback) {
	    cordova.exec(function() {
		    callback(true);
		}, function(error) {
		    console.log("ERROR: AWS.uploadText " + error);
		    callback(false);		
		}, "AwsS3Plugin", "uploadText", [s3Bucket, s3Key, data]);
    },
    uploadData: function(s3Bucket, s3Key, data, callback) {
	    cordova.exec(function() {
		    callback(true);
		}, function(error) {
		    console.log("ERROR: AWS.uploadData " + error);
		    callback(false);			
		}, "AwsS3Plugin", "uploadData", [s3Bucket, s3Key, data]);
    },
    uploadFile: function(s3Bucket, s3Key, filePath, callback) {
	    cordova.exec(function() {
		    callback(true);
	    }, function(error) {
		    console.log("ERROR: AWS.uploadFile " + error);
		    callback(false);		    
	    }, "AwsS3Plugin", "uploadFile", [s3Bucket, s3Key, filePath]);
    }
};

module.exports = AWS;

*/