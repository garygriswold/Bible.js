  /*
  HeaderView
    line 108 AudioPlayer.findAudioVersion(versionCode, silCode, function(bookList) {}) if error, return "" 

  AppInitializer
    line 114 AudioPlayer.isPlaying(function(playing) {}) if error, return "F"
    line 126 AudioPlayer.present(ref.book, ref.chapter, function() {}) return required, error not returned
    line 139 AudioPlayer.stop(function() {}) error not returned
  */
 function testAudioPlayer() {
	callNative('AudioPlayer', 'isPlaying', [], "S", function(result) {
		if (assert((result === "F"), "It is be playing is false")) {
			testFindVersion1();
		}
	});
 }
 function testFindVersion1() {
	callNative('AudioPlayer', 'findAudioVersion', ['versionxx', 'silCode'], "S", function(result) {
		if (assert((result === ""), "BookList must not be null")) {
			testFindVersion2();
		}
	});
 }
 function testFindVersion2() {
	callNative('AudioPlayer', 'findAudioVersion', ['WEB', 'eng'], "S", function(result) {
		if (assert(result.length > 100), "BookList must be a string of books") {
			var books = result.split(',');
			log(typeof books);
			if (assert((books.length > 20), "BookList must be a comma separated list")) {
				testPresentAudio();
			}
		}		
	});
}
function testPresentAudio() {
	var book = "JHN";
	var chapter = 3;
	callNative('AudioPlayer', 'present', [book, chapter], "N", function() {
		//if (assert((nothing == null), "present should return nothing")) {
			testStopAudio();
		//}	
	});
 }
 function testStopAudio() {
	callNative('AudioPlayer', 'stop', [], "E", function(error) {
		if (assert((error == null), "stop should return nothing")) {
			log('AudioPlayer test is complete');
		}		
	});
 }
 