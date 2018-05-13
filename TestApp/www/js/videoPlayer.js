 /*
 VideoListView
   line 105 VideoPlayer.showVideo(mediaSource, videoId, languageId, silCode, videoUrl, function() {})
 */
 function testVideoPlayer() {
	 var mediaSource = 'FCBH';
	 var videoId = 'myvideoId';
	 var languageId = 'ENG';
	 var silCode = 'eng';
	 var videoUrl = 'http://whatever';
	 var parameters = [mediaSource, videoId, languageId, silCode, videoUrl];
	 callNative('VideoPlayer', 'showVideo', 'showVideoHandler1', parameters);
 }
 function showVideoHandler1(nothing) {
	 if (assert((nothing == null), "video should return nothing")) {
		 var mediaSource = "JFP";
		 var videoId = 'Jesus';
		 var languageId = '528';
		 var silCode = 'eng';
		 var videoUrl = 'https://arc.gt/1e62h?apiSessionId=587858aea460f2.62190595';
		 var parameters = [mediaSource, videoId, languageId, silCode, videoUrl];
		 callNative('VideoPlayer', 'showVideo', 'showVideoHandler2', parameters);		 
	 }
 }
 function showVideoHandler2(nothing) {
	 if (assert((nothing == null), "video should succeed, but return nothing")) {
		 console.log('VideoPlayer test is complete.');
	 }
 }