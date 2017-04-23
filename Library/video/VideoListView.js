/**
* This class presents a list of available video with thumbnails,
* and when a thumbnail is clicked it display more detail.
* and when the play button is clicked, it starts the video.
*/
"use strict";
function VideoListView() {
	this.countryCode = null;
	this.silCode = null;
	this.rootNode = null;
	Object.seal(this);
}
VideoListView.prototype.showView = function(countryCd, silCd) {
	console.log('INSIDE SHOW VIEW');
	var that = this;
	this.clearView();
	if (this.rootNode != null && this.rootNode.children.length > 0 && this.countryCode === countryCd && this.silCode === silCd) {
		this.reActivateView();
		return(true);
	} else {
		this.countryCode = countryCd;
		this.silCode = silCd;
		this.rootNode = this.addNode(document.body, 'table', 'videoList');
		return(false);
	}
};
VideoListView.prototype.reActivateView = function() {
	document.body.appendChild(this.rootNode);
	var nodeList = document.getElementsByClassName('videoListDesc');
	for (var i=0; i<nodeList.length; i++) {
		nodeList[i].setAttribute('hidden', 'hidden');
	}
};
VideoListView.prototype.showVideoItem = function(videoItem) {	
	console.log('INSIDE BUILD ITEM');
	var that = this;
	var row = this.addNode(this.rootNode, 'tr', 'videoList');
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
VideoListView.prototype.clearView = function() {
	while (document.body.lastChild) {
		document.body.removeChild(document.body.lastChild);
	}	
};
VideoListView.prototype.hideView = function() {
	document.body.removeChild(this.rootNode);
};
VideoListView.prototype.addNode = function(parent, type, clas, content, id) {
	var node = document.createElement(type);
	if (id) node.setAttribute('id', id);
	if (clas) node.setAttribute('class', clas);
	if (content) node.innerHTML = content;
	parent.appendChild(node);
	return(node);
};