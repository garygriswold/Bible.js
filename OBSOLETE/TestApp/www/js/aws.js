/*
AppInitializer
  line 27 AWS.initializeRegion(function(done) {}) return false, if error occurs DEPRECATED

FileDownloader
  line 21 AWS.downloadZipFile(s3Bucket, s3Key, filePath, function(error) {}) returns error, if occurs, else null
*/
function testAWS() {
	var region = 'TEST';
	var bucket = 'nonehere';
	var key = 'nonehere';
	var filename = 'nonehere';
	callNative('AWS', 'downloadZipFile', [region, bucket, key, filename], "E", function(error) {
		if (assert(error, "Download should fail for non-existing object.")) {
			testDownloadZip2();
		}
	});
}
function testDownloadZip2() {
	var region = 'TEST';
	var bucket = 'shortsands';
	var key = 'ERV-ENG.db.zip';
	var filename = 'ERV-ENG.db';
	callNative('AWS', 'downloadZipFile', [region, bucket, key, filename], "E", function(error) {
		if (!assert(error, error)) {
			log("AWS Test did succeed");
		}
	});
}
