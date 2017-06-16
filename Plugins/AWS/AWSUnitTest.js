/**
 * This test file must be copied into the www/js folder of the application.
 * An entry for it should be added to index.html
 * It can be invoked from js/index.js
 * To make this test work, one must take note of the location of the Documents directory
 * and move the needed file or files to it.
 */
"use strict";
function AWSUnitTest(endpoint) {
	AWS.initializeRegion(endpoint, function(done) {
		console.log("initializeRegion " + endpoint + " " + done);
	});
}

AWSUnitTest.prototype.testEcho = function() {
	console.log('ECHO 0 TEST ' + 'Hello');
	
	AWS.echo1("Hello World 1", function(response) {
		console.log('ECHO 1 TEST ' + response);	
	});
	
	AWS.echo2("Hello World 22", function(response) {
		console.log('ECHO 2 TEST ' + response);
	});
	
	AWS.echo3("Hello World 333", function(response) {
		console.log('ECHO 333 TEST ' + response);
	});
};

AWSUnitTest.prototype.testPresign = function() {
	console.log("inside testPresign " + new Date().getTime());
	AWS.preSignedUrlGET("shortsands-xx", "WEB-xx.db.zip", 3600, function(url) {
		console.log("preSignedUrlGET " + url + "  " + new Date().getTime());
	});
	
	AWS.preSignedUrlPUT("shortsands-yy", "WEB-yy.db.zip", 3600, "text/plain", function(url) {
		console.log("preSignedUrlPUT " + url + "  " + new Date().getTime());
	});		
};

AWSUnitTest.prototype.testDownloadText = function() {
	console.log("Inside test downloadText");

	// Download an existing text file
	AWS.downloadText("shortsands", "hello1", function(text) {
		console.log("downloadText " + text);
	});

	// Attempt to download a non-existing key
	AWS.downloadText("shortsands", "hello1-xxxx", function(text) {
		console.log("downloadText non existing key " + text);
	});
	
	// Attempt to download a non-existing bucket
	AWS.downloadText("shortsands-xxx", "hello1", function(text) {
		console.log("downloadText non existing bucket " + text);
	});
	
	// Attempt to download a null bucket.  This fails miserable, nothing returns
	AWS.downloadText(null, "hello1", function(text) {
		console.log("downloadText null bucket " + text);
	});

	// Attempt to download a empty bucket.  This fails miserable, nothing returns
	AWS.downloadText("", "hello1", function(text) {
		console.log("downloadText empty string bucket " + text);
	});
};

AWSUnitTest.prototype.testTextDownUp = function() {
	
	AWS.downloadText("shortsands", "hello1", function(text) {
		console.log("Downloaded " + text);
		AWS.uploadText("shortsands", "hello1upload", text, function(done) {
			console.log("Uploaded " + done);
			console.log("Compare uploaded file to original");
		});
	});
};

AWSUnitTest.prototype.testDataDownUp = function() {
	AWS.downloadData("shortsands", "EmmaFirstLostTooth.mp3", function(data) {
		console.log("Downloaded ?" );
		AWS.uploadData("shortsands", "EmmaFirstLostToothUpload.mp3", data, "audio/mp3", function(done) {
			console.log("Uploaded " + done);
			console.log("Compare uploaded file to original");
		});
	});
};

AWSUnitTest.prototype.testDownloadFile = function() {
	AWS.downloadFile("shortsands", "hello1", "/Documents/hello.txt", function(done) {
		console.log("This should succeed." + done);
		if (done) {
			console.log("download file OK");
			AWS.uploadFile("shortsands", "hello_upload", "/Documents/hello.txt", "plain.txt", function(done2) {
				console.log("upload done " + done2);
			});
		}
	});
};

AWSUnitTest.prototype.testDownloadFileError = function() {
	AWS.downloadFile("shortsands", "hello1", "/NonExistentDir/hello-bad.txt", function(done) {
		console.log("This should produce error, because it cannot store file." + done);
	});
};

AWSUnitTest.prototype.testDownloadNonFileError = function() {
	AWS.downloadFile("shortsands", "hello1", "/NonExistentDir/hello-bad.txt", function(done) {
		console.log("This should produce error, because it cannot find object." + done);
	});
};

AWSUnitTest.prototype.testUploadFileError = function() {
	AWS.uploadFile("shortsands", "hello1Up", "/ThereIsNoFile/hello.txt", "text/plain", function(done) {
		console.log("This should produce an err, becuase there is no file. " + done);
	});
};

AWSUnitTest.prototype.testFileDownUp = function() {
	var path = "/Documents/NMV.db.zip";
	AWS.downloadFile("shortsands", "NMV.db.zip", path, function(done) {
		if (done) {
			console.log("download file OK");
			AWS.uploadFile("shortsands", "NMVupload.db.zip", path, "application/zip", function(done2) {
				console.log("upload done " + done2);
			});
		}
	});	
};

AWSUnitTest.prototype.testDownloadZipFile = function() {
	AWS.downloadZipFile("shortsands", "WEB.db.zip", "/Documents/WEB.db", function(done) {
		console.log("download and unzip should succeed, verify file " + done);
	});
};

AWSUnitTest.prototype.testDownloadNonZipFile = function() {	
	AWS.downloadZipFile("shortsands", "hello1", "/Documents/hello1", function(done) {
		console.log("download zip should fail, because WEB-XX.db is not in zip file.");
	});	
};

AWSUnitTest.prototype.testDownloadNonExistantZipFile = function() {
	AWS.downloadZipFile("shortsands-XXX", "WEB.db.zip", "/Documents/WEB-ERR1.db", function(done) {
		console.log("download from non-existing bucket should fail. " + done);	
	});	
};

AWSUnitTest.prototype.testDownloadZipFileXX = function() {

	/*
	AWS.downloadZipFile("shortsands", "XXXX.zip", "/Documents/WEB-ERR2.db", function(done) {
		console.log("download non-existing item should fail. " + done);
	});
	*/
	/*
	AWS.downloadZipFile("shortsands", "WEB.db.zip", "/XXXX/WEB-ERR3.db", function(done) {
		console.log("download zip to non-existing path " + done);
	});
	*/
	/*

	*/
};