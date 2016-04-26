/**
* This class is used to create the copyright notice that is put 
* at the bottom of each chapter, and the learn more page that appears
* when that is clicked.
*/
function CopyrightView(version) {
	this.version = version;
	this.copyrightNotice = this.createCopyrightNotice();
	Object.freeze(this);
}
CopyrightView.prototype.createCopyrightNotice = function() {
	var html = [];
	html.push('<p><span class="copyright">');
	html.push(this.plainCopyrightNotice(), '</span>');
	html.push('<span class="copylink" onclick="copyrightViewNotice()"> \u261E </span>', '</p>');
	return(html.join(''));
};
/**
* Translation Name (trans code) | Language Name (lang code),
* Copyright C year, Organization hand-link
*/
CopyrightView.prototype.plainCopyrightNotice = function() {
	var notice = [];
	if (this.version.ownerCode === 'WBT') {
		notice.push(this.version.localLanguageName, ' (', this.version.silCode);
	} else {
		notice.push(this.version.localVersionName, ' (', this.version.code);
	}
	notice.push('), ');
	if (this.version.copyrightYear === 'PUBLIC') {
		notice.push('Public Domain');
	} else {
		notice.push(String.fromCharCode('0xA9'), String.fromCharCode('0xA0'), this.version.copyrightYear);
	}
	notice.push(', ', this.version.ownerName, '.');
	return(notice.join(''));
};
/**
* NOTE: This is a global method, not class method
* Language (lang code), Translation Name (trans code),
* Copyright C year, Organization,
* Organization URL, link image
*/
function copyrightViewNotice() {
	console.log('Copyright notice is clicked');
}

/**
					that.dom.addNode(leftNode, 'p', 'langName', row.localLanguageName);
					var versionName = (row.localVersionName) ? row.localVersionName : row.scope;
					that.dom.addNode(leftNode, 'span', 'versName', versionName + ',  ');
					
					if (row.copyrightYear === 'PUBLIC') {
						that.dom.addNode(leftNode, 'span', 'copy', 'Public Domain');
					} else {
						var copy = String.fromCharCode('0xA9') + String.fromCharCode('0xA0');
						var copyright = (row.copyrightYear) ?  copy + row.copyrightYear + ', ' : copy;
						var copyNode = that.dom.addNode(leftNode, 'span', 'copy', copyright);
						var ownerNode = that.dom.addNode(leftNode, 'span', 'copy', row.ownerName);
						if (row.ownerURL) {
							ownerNode.setAttribute('style', 'color: #2A48B4; text-decoration: underline');
							ownerNode.addEventListener('click', function(event) {
								cordova.InAppBrowser.open('http://' + row.ownerURL, '_blank', 'location=yes');
							});
						}
					}
**/