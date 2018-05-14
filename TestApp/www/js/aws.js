/*
AppInitializer
  line 27 AWS.initializeRegion(function(done) {}) return false, if error occurs

FileDownloader
  line 21 AWS.downloadZipFile(s3Bucket, s3Key, filePath, function(error) {}) returns error, if occurs, else null
*/
function testAWS() {
	callNative('AWS', 'initialize', 'initializeHandler', []);
}
function initializeHandler(done) {
	if (assert(done, "Initialize should return done")) {
		var bucket = 'nonehere';
		var key = 'nonehere';
		var filename = 'nonehere';
		callNative('AWS', 'downloadZipFile', 'downloadZipHandler1', [bucket, key, filename]);
	}
}
function downloadZipHandler1(error) {
	if (assert(error, "Download should fail for non-existing object.")) {
		var bucket = 'shortsands';
		var key = 'ERV-ENG.db.zip';
		var filename = 'ERV-ENG.db';
		callNative('AWS', 'downloadZipFile', 'downloadZipHandler2', [bucket, key, filename]);
	}
}
function downloadZipHandler2(error) {
	if (!assert(error, error)) {
		console.log("AWS Test did succeed");
	}
}