  /*
  HeaderView
    line 108 AudioPlayer.findAudioVersion(versionCode, silCode, function(bookList) {}) if error, return nil (or should this be empty list?)

  AppInitializer
    line 114 AudioPlayer.isPlaying(function(playing) {}) if error, return "F"
    line 126 AudioPlayer.present(ref.book, ref.chapter, function() {}) return required, error not returned
    line 139 AudioPlayer.stop(function() {}) error not returned
  */
 function testAudioPlayer() {
	 callNative('AudioPlayer', 'isPlaying', 'isPlayingHandler', []);
 }
 function isPlayingHandler(playing) {
	 if (assert(!playing, "It is be playing is false")) {
		 callNative('AudioPlayer', 'findAudioVersion', 'findVersionHandler', ['versionCode', 'silCode']);
	 }
 }
 function findVersionHandler(bookList) {
	 if (assert((bookList == null), "BookList must not be null")) {
		 if (assert(bookList.length > 100), "BookList must be a string of books") {
			 var books = bookList.split(',');
			 if (assert((books.length > 100), "BookList must be a comma separated list")) {
				 var book = "JHN";
				 var chapter = 3;
				 callNative('AudioPlayer', 'present', 'presentHandler', [book, chapter]);
			 }
		 }
	 }
 }
 function presentHandler(nothing) {
	 if (assert((nothing == null), "present should return nothing")) {
		 callNative('AudioPlayer', 'stop', 'stopHandler', []);
	 }
 }
 function stopHandler(nothing) {
	 if (assert((nothing == null), "stop should return nothing")) {
		 console.log('AudioPlayer test is complete');
	 }
 }