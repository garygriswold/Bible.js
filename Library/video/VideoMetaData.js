


"use strict";
function VideoMetaData() {
	this.mediaSource = null;
	this.languageId = null;
	this.silCode = null;
	this.langCode = null;
	this.mediaId = null;
	this.title = null;
	//this.shortDescription = null;
	this.hasDescription = null;
	this.longDescription = null;
	this.lengthInMilliseconds = null;
	this.imageHighRes = null;
	this.imageMedRes = null;
	this.mediaURL = null;
	Object.seal(this);
}
VideoMetaData.prototype.duration = function() {
	var totalSeconds = this.lengthInMilliseconds / 1000;
	var hours = totalSeconds / 3600;
	var minutes = (hours - Math.floor(hours)) * 60;
	var seconds = (minutes - Math.floor(minutes)) * 60;
	return(Math.floor(hours) + ':' + Math.floor(minutes) + ':' + Math.floor(seconds)); 
};
VideoMetaData.prototype.toJSON = function() {
	return('videoMetaData: { languageId: ' + this.languageId +
			', silCode: ' + this.silCode +
			', langCode: ' + this.langCode +
			', mediaId: ' + this.mediaId + 
			', title: ' + this.title +
			', hasDescription: ' + this.hasDescription +
			', longDescription: ' + this.longDescription +
			', lengthInMilliseconds: ' + this.lengthInMilliseconds +
			', imageHighRes: ' + this.imageHighRes +
			', imageMedRes: ' + this.imageMedRes +
			', mediaURL: ' + this.mediaURL + ' }');
};