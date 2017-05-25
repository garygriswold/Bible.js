"use strict";

module.exports = {
	// callback(err, signedURL)
    preSignedUrlGET: function(s3Bucket, s3Key, expires, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "preSignedUrlGET", 
	    			[s3Bucket, s3Key, expires]);
    },
    // callback(err, signedURL)
    preSignedUrlPUT: function(s3Bucket, s3Key, expires, contentType, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "preSignedUrlPUT", 
	    			[s3Bucket, s3Key, expries, contentType]);
    },
    // callback(err)
    zip: function(sourceFile, targetDir, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "zip"
	    			[sourceFile, targetDir]);
    },
    // callback(err)
    unzip: function(sourceFile, targetDir, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "unzip",
	    			[sourceFile, targetDir]);
    },
    // callback(err, String)
    downloadText: function(s3Bucket, s3Key, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "downloadText",
	    			[s3Bucket, s3Key]);
    },
    // callback(err, bytes?) not sure about data structure to use in JS
    downloadData: function(s3Bucket, s3Key, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "downloadData",
	    			[s3Bucket, s3Key])
    },
    // callback(err)
    downloadFile: function(s3Bucket, s3Key, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "downloadFile",
	    			[s3Bucket, s3Key, filePath]);
    },
    // callback(err)
    downloadZipFile: function(s3Bucket, s3Key, filePath, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "downloadZipFile",
	    			[s3Bucket, s3Key, filepath]);
    },
    // callback(err)
    uploadAnalytics: function(sessionId, timestamp, data, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "uploadAnalytics",
	    			[s3Bucket, s3Key, data]);
    },
    // callback(err)
    uploadText: function(s3Bucket, s3Key, data, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "uploadText",
	    			[s3Bucket, s3Key, data]);
    },
    // callback(err)
    uploadData: function(s3Bucket, s3Key, data, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "uploadData",
	    			[s3Bucket, s3Key, data]);
    },
    // callback(err)
    uploadFile: function(s3Bucket, s3Key, filePath, callback) {
	    cordova.exec(callback, errorCall(err) {}, "AwsS3", "uploadFile",
	    			[s3Bucket, s3Key, filePath]);
    }
};