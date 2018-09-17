 /*
 VideoListView
   line 105 VideoPlayer.showVideo(mediaSource, videoId, languageId, silCode, videoUrl, function() {}) if error, return error
 */
 function testVideoPlayer() {
	 var mediaSource = 'FCBH';
	 var videoId = 'myvideoId';
	 var languageId = 'ENG';
	 var silCode = 'eng';
	 var videoUrl = 'https://whatever';
	 var parameters = [mediaSource, videoId, languageId, silCode, videoUrl];
	 callNative('VideoPlayer', 'showVideo', parameters, "E", function(error) {
		 //if (assert(error === null), "video should return nothing") {
			 testVideoPlayer2();
		 //}
	 });
 }
 function testVideoPlayer2() {
	var mediaSource = "JFP";
	var videoId = 'Jesus';
	var languageId = '528';
	var silCode = 'eng';
	var videoUrl = 'https://arc.gt/j67rz?apiSessionId=5a8b6c35e31419.49477826';
	//var videoUrl = 'https://player.vimeo.com/external/157336122.m3u8?s=861d8aca0bddff67874ef38116d3bf5027474858';
	var parameters = [mediaSource, videoId, languageId, silCode, videoUrl];
	callNative('VideoPlayer', 'showVideo', parameters, "E", function(error) {
		if (assert((error == null), "video should succeed, but return nothing")) {
			console.log('VideoPlayer test is complete.');
	 	}
	});		 
 }
