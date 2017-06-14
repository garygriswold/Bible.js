/**
 * This test file must be copied into the www/js folder of the application.
 * An entry for it should be added to index.html
 * It can be invoked from js/index.js
 * To make this test work, one must take note of the location of the Documents directory
 * and move the needed file or files to it.
 */
function PKZipUnitTest() {
	
}

PKZipUnitTest.prototype.testNoInput = function() {
    PKZip.zip("/Documents/xxxxx.x", "/Documents/yyyyy.y.zip", function(done) {
        console.log("testNoINput zip should be false " + done);
    });
    PKZip.unzip("/Documents/xxxxx.x", "/Documents/yyyy", function(done) {
        console.log("testNoInput nozip should be false " + done);
    });
};

PKZipUnitTest.prototype.testUnzip = function() {
    PKZip.unzip("/Documents/WEB.db.zip", "/Documents", function(done) {
        console.log("TestUnzip should be true if file present " + done);
    });
};

PKZipUnitTest.prototype.testZip = function() {
	PKZip.zip("/Documents/WEB.db", "/Documents/WEB_OUT.db.zip", function(done) {
		console.log("TestZip should be true if file is present " + done);
	});
};

