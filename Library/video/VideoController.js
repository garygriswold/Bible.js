/**
* 1. Get the Inputs to JesusFilmAPI
* deviceType, locale determine with functions
* silCode, langCode must be input, or determined from Filename
* 2. Execute the JesusFilmAPI for all films (or for 1 film)
* 3. Present VideoListView, which contains the images and text of the video
* 4. When the User selects a Video to view, present VideoPlayer
*/
"use strict";
function VideoController(silCode, langCode, countryCode) {
						// KingOfGlory, Jesus, Magdalene, Children
	this.videoIdList = [ 'KOG_OT', 'KOG_NT', '1_jf-0-0', '1_wl-0-0', '1_cl-0-0' ];
 	this.deviceType = device.platform.toLowerCase();
	this.silCode = silCode;
	this.langCode = langCode;
	this.countryCode = countryCode;
	Object.seal(this);
}
VideoController.prototype.begin = function() {
	var that = this;
	var videoListView = new VideoListView();
	var viewDone = videoListView.showView(that.countryCode, that.silCode);
	if (! viewDone) {
		
		getVideoTable(that.countryCode, that.silCode, that.deviceType, function(count) {
			if (count < 1) {
				var jesusFilm = new JesusFilmAPI(that.deviceType, that.countryCode, that.silCode, that.langCode);
				jesusFilm.getMetaData(function(mediaAvailable) {
					getEachMedia(jesusFilm, videoListView, 0, that.videoIdList, mediaAvailable, function() {
						languageList.showView(); // Just for VideoModule
					});
				});
			} else {
				languageList.showView(); // Just for VideoModule	
			}
		});
	}
	
	function getVideoTable(countryCode, silCode, deviceType, callback) {
		var databaseHelper = new DatabaseHelper('Versions.db', true);
		var videoAdapter = new VideoTableAdapter(databaseHelper);
		videoAdapter.selectJesusFilmLanguage(countryCode, silCode, function(lang) {
		
			videoAdapter.selectVideos(lang.languageId, silCode, deviceType, function(videoMap) {
				for (var i=0; i<that.videoIdList.length; i++) {
					var id = that.videoIdList[i];
					var metaData = videoMap[id];
					if (metaData) {
						videoListView.showVideoItem(metaData);
					}
				}
				callback(Object.keys(videoMap).length);
			});
		});
	}
	
	function getEachMedia(jesusFilm, videoListView, index, mediaIdList, mediaAvailable, callback) {
		if (index < mediaIdList.length) {
			var mediaId = mediaIdList[index];
			if (mediaAvailable[mediaId]) {
				var videoMetaData = new VideoMetaData();
				videoMetaData.mediaId = mediaId;
				jesusFilm.getMedia(videoMetaData, function(){
					videoListView.showVideoItem(videoMetaData);
					
					getEachMedia(jesusFilm, videoListView, index + 1, mediaIdList, mediaAvailable, callback);
				});
			} else {
				getEachMedia(jesusFilm, videoListView, index + 1, mediaIdList, mediaAvailable, callback);
			}
		} else {
			callback();
		}
	}
};


