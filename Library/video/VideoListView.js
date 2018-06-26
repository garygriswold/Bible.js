/**
* This class presents a list of available video with thumbnails,
* and when a info btn is clicked it display more detail.
* and when the play button is clicked, it starts the video.
*/

function VideoListView(version, videoAdapter) {
	this.videoIdList = [ 'KOG_OT', 'KOG_NT', '1_jf-0-0', '1_wl-0-0', '1_cl-0-0' ];
	this.version = version;
	this.videoAdapter = videoAdapter;
	console.log('IN VIDEO VIEW ', 'ctry', this.countryCode, 'sil', this.silCode);
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
		var portWidth = (window.innerWidth < window.innerHeight) ? window.innerWidth : window.innerHeight;
		this.viewNode.setAttribute('width', portWidth);
		getVideoTable(this.version);
	}
	
	function getVideoTable(vers) {
		that.videoAdapter.selectJesusFilmLanguage(vers.countryCode, vers.silCode, function(lang) {
		
			that.videoAdapter.selectVideos(lang.languageId, vers.silCode, vers.langCode, vers.langPrefCode, function(videoMap) {
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
	play.setAttribute('mediaSource', videoItem.mediaSource);
	play.setAttribute('mediaId', videoItem.mediaId);
	play.setAttribute('languageId', videoItem.languageId);
	play.setAttribute('silCode', videoItem.silCode);
	play.setAttribute('mediaURL', videoItem.mediaURL);
	play.addEventListener('click', playVideo);
	
	var info = this.addNode(div, 'img', 'videoListInfo');
	info.setAttribute('src', 'img/info.svg');

	this.addNode(div, 'p', 'videoListDur', videoItem.duration());
	
	if (videoItem.hasDescription == 1) {
		info.addEventListener('click', buildVideoDescription);
	} else {
		info.setAttribute('style', 'opacity: 0');
	}
	
	function buildVideoDescription(event) {
		if (videoItem.longDescription == null) {
			that.videoAdapter.selectDescription(videoItem.languageId, videoItem.silCode, videoItem.mediaId, function(results) {
				videoItem.longDescription = results;
				var desc = that.addNode(div, 'p', 'videoListDesc', videoItem.longDescription);
				desc.setAttribute('hidden', 'hidden');
				displayVideoDescription(desc);
			});
		} else {
			displayVideoDescription(this.nextSibling.nextSibling);
		}
	}
	
	function displayVideoDescription(descNode) {
		if (descNode.hasAttribute('hidden')) {
			descNode.removeAttribute('hidden');
		} else {
			descNode.setAttribute('hidden', 'hidden');
		}
	}
	
	function playVideo(event) {
		var mediaSource = this.getAttribute('mediaSource');
		var videoId = this.getAttribute('mediaId');
		var languageId = this.getAttribute('languageId');
		var silCode = this.getAttribute('silCode');
		var videoUrl = this.getAttribute('mediaURL');
		
        console.log("\n\BEFORE VideoPlayer " + videoId + " : " + videoUrl);
        document.dispatchEvent(new CustomEvent(BIBLE.STOP_AUDIO));
		var parameters = [mediaSource, videoId, languageId, silCode, videoUrl];
		callNative('VideoPlayer', 'showVideo', parameters, "E", function(error) {
			if (error) {
				console.log("ERROR FROM VideoPlayer " + error);
			} else {
				console.log("SUCCESS FROM VideoPlayer " + videoUrl);
			}
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