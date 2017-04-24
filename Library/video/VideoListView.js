/**
* This class presents a list of available video with thumbnails,
* and when a info btn is clicked it display more detail.
* and when the play button is clicked, it starts the video.
*/
"use strict";
function VideoListView(version, videoAdapter) {
	this.videoIdList = [ 'KOG_OT', 'KOG_NT', '1_jf-0-0', '1_wl-0-0', '1_cl-0-0' ];
	this.countryCode = version.countryCode;
	this.silCode = version.silCode;
	this.deviceType = deviceSettings.platform();
	this.videoAdapter = videoAdapter;
	console.log('IN VIDEO VIEW ', 'ctry', this.countryCode, 'sil', this.silCode, 'device', this.deviceType);
	this.rootNode = document.createElement('div');
	this.rootNode.id = 'videoRoot';
	document.body.appendChild(this.rootNode);
	this.viewNode = null;
	Object.seal(this);
}
VideoListView.prototype.showView = function() {
	console.log('INSIDE SHOW VIDEO LIST VIEW');
	var that = this;
	if (this.viewNode != null && this.viewNode.children.length > 0) {
		this.reActivateView();
	} else {
		this.viewNode = this.addNode(this.rootNode, 'table', 'videoList');
		getVideoTable(this.countryCode, this.silCode, this.deviceType);
	}
	
	function getVideoTable(countryCode, silCode, deviceType) {
		that.videoAdapter.selectJesusFilmLanguage(countryCode, silCode, function(lang) {
		
			that.videoAdapter.selectVideos(lang.languageId, silCode, deviceType, function(videoMap) {
				for (var i=0; i<that.videoIdList.length; i++) {
					var id = that.videoIdList[i];
					var metaData = videoMap[id];
					if (metaData) {
						that.showVideoItem(metaData);
					}
				}
			});
		});
	}
};
VideoListView.prototype.reActivateView = function() {
	this.rootNode.appendChild(this.viewNode);
	var nodeList = document.getElementsByClassName('videoListDesc');
	for (var i=0; i<nodeList.length; i++) {
		nodeList[i].setAttribute('hidden', 'hidden');
	}
};
VideoListView.prototype.showVideoItem = function(videoItem) {	
	console.log('INSIDE BUILD ITEM', videoItem.mediaId);
	var that = this;
	var row = this.addNode(this.viewNode, 'tr', 'videoList');
	var cell = this.addNode(row, 'td', 'videoList');
	
	var image = this.addNode(cell, 'img', 'videoList');
	image.src = 'img/' + videoItem.mediaId + '.jpg';
	image.alt = videoItem.title;
	
	var div = this.addNode(cell, 'div', 'videList');
	this.addNode(div, 'p', 'videoListTitle', videoItem.title);
	
	var play = this.addNode(div, 'img', 'videoListPlay');
	play.setAttribute('src', 'img/play.svg');
	play.setAttribute('mediaId', videoItem.mediaId);
	play.setAttribute('mediaURL', videoItem.mediaURL);
	play.addEventListener('click', playVideo);
	
	var info = this.addNode(div, 'img', 'videoListInfo');
	info.setAttribute('src', 'img/info.svg');

	this.addNode(div, 'p', 'videoListDur', videoItem.duration());
	
	if (videoItem.longDescription) {
		info.addEventListener('click', buildVideoDescription);
		var desc = this.addNode(div, 'p', 'videoListDesc', videoItem.longDescription);
		desc.setAttribute('hidden', 'hidden');
	} else {
		info.setAttribute('style', 'opacity: 0');
	}
	
	function buildVideoDescription(event) {
		var descNode = this.nextSibling.nextSibling;
		if (descNode.hasAttribute('hidden')) {
			descNode.removeAttribute('hidden');
		} else {
			descNode.setAttribute('hidden', 'hidden');
		}
	}
	
	function playVideo(event) {
		var videoId = this.getAttribute('mediaId');
		var videoUrl = this.getAttribute('mediaURL');
		
        console.log("\n\BEFORE VideoPlayer " + videoId + " : " + videoUrl);
		window.VideoPlayer.showVideo(videoId, videoUrl,
		function() {
			console.log("SUCCESS FROM VideoPlayer " + videoUrl);
		},
		function(error) {
			console.log("ERROR FROM VideoPlayer " + error);
		});
	}
};
VideoListView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		//this.scrollPosition = window.scrollY;
		for (var i=this.rootNode.children.length -1; i>=0; i--) {
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
	}
};
VideoListView.prototype.addNode = function(parent, type, clas, content, id) {
	var node = document.createElement(type);
	if (id) node.setAttribute('id', id);
	if (clas) node.setAttribute('class', clas);
	if (content) node.innerHTML = content;
	parent.appendChild(node);
	return(node);
};