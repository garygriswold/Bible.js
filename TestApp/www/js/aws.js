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
	callNative('AWS', 'downloadZipFile', 'downloadZipHandler1', [region, bucket, key, filename]);
}
function downloadZipHandler1(error) {
	log(error);
	if (assert(error, "Download should fail for non-existing object.")) {
		var region = 'TEST';
		var bucket = 'shortsands';
		var key = 'ERV-ENG.db.zip';
		var filename = 'ERV-ENG.db';
		callNative('AWS', 'downloadZipFile', 'downloadZipHandler2', [region, bucket, key, filename]);
	}
}
function downloadZipHandler2(error) {
	//log(error);
	if (!assert(error, error)) {
		log("AWS Test did succeed");
	}
}