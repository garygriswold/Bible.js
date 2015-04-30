/**
* This object of the Director pattern, it contains a boolean member for each type of asset.
* Setting a member to true will be used by the Builder classes to control which assets are built.
*/
"use strict";

function AssetType(location, versionCode) {
	this.location = location;
	this.versionCode = versionCode;
	this.chapterFiles = false;
	this.tableContents = false;
	this.concordance = false;
	this.styleIndex = false;
	this.html = false;// this one is not ready
	Object.seal(this);
};
AssetType.prototype.mustDoQueue = function(filename) {
	switch(filename) {
		case 'chapterMetaData.json':
			this.chapterFiles = true;
			break;
		case 'toc.json':
			this.tableContents = true;
			break;
		case 'concordance.json':
			this.concordance = true;
			break;
		case 'styleIndex.json':
			this.styleIndex = true;
			break;
		default:
			throw new Error('File ' + filename + ' is not known in AssetType.mustDo.');

	}
};
AssetType.prototype.toBeDoneQueue = function() {
	var toDo = [];
	if (this.chapterFiles) {
		toDo.push('chapterMetaData.json');
	}
	if (this.tableContents) {
		toDo.push('toc.json');
	}
	if (this.concordance) {
		toDo.push('concordance.json');
	}
	if (this.styleIndex) {
		toDo.push('styleIndex.json');
	}
	return(toDo);
};
