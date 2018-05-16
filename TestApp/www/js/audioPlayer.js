  /*
  HeaderView
    line 108 AudioPlayer.findAudioVersion(versionCode, silCode, function(bookList) {}) if error, return "" 

  AppInitializer
    line 114 AudioPlayer.isPlaying(function(playing) {}) if error, return "F"
    line 126 AudioPlayer.present(ref.book, ref.chapter, function() {}) return required, error not returned
    line 139 AudioPlayer.stop(function() {}) error not returned
  */
 function testAudioPlayer() {
	 callNative('AudioPlayer', 'isPlaying', 'isPlayingHandler', []);
 }
 function isPlayingHandler(playing) {
	 if (assert((playing === "F"), "It is be playing is false")) {
		 callNative('AudioPlayer', 'findAudioVersion', 'findVersionHandler', ['versionxx', 'silCode']);
	 }
 }
 function findVersionHandler(bookList) {
	 if (assert((bookList === ""), "BookList must not be null")) {
		 callNative('AudioPlayer', 'findAudioVersion', 'findVersionHandler2', ['WEB', 'eng']);
	}
}
function findVersionHandler2(bookList) {
	log(typeof bookList);
	 if (assert(bookList.length > 100), "BookList must be a string of books") {
		 var books = bookList.split(',');
		 log(typeof books);
		 if (assert((books.length > 20), "BookList must be a comma separated list")) {
			 var book = "JHN";
			 var chapter = 3;
			 callNative('AudioPlayer', 'present', 'presentHandler', [book, chapter]);
		 }
	 }
 }
 function presentHandler(nothing) {
	 log(nothing);
	 if (assert((nothing == null), "present should return nothing")) {
		 callNative('AudioPlayer', 'stop', 'stopHandler', []);
	 }
 }
 function stopHandler(nothing) {
	 if (assert((nothing == null), "stop should return nothing")) {
		 log('AudioPlayer test is complete');
	 }
 }