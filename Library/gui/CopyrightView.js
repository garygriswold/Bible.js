/**
* NOTE: This is a global method, not a class method, because it
* is called by the event handler created in createCopyrightNotice.
*/
function copyrightViewNotice(event) {
	event.stopImmediatePropagation();
	document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_ATTRIB, { detail: { x: event.x, y: event.y }}));
}
/**
* This class is used to create the copyright notice that is put 
* at the bottom of each chapter, and the learn more page that appears
* when that is clicked.
*/
function CopyrightView(version) {
	this.version = version;
	this.rootNode = document.createElement('div');
	document.body.appendChild(this.rootNode);
	this.copyrightNotice = this.createCopyrightNotice();
	this.viewRoot = null;
	var that = this;
	document.body.addEventListener(BIBLE.SHOW_ATTRIB, function(event) {
		if (that.viewRoot == null) {
			that.viewRoot = that.createAttributionView();
		}
		var clickPos = String(event.detail.x) + 'px ' + String(event.detail.y) + 'px';
		that.rootNode.appendChild(that.viewRoot);
		TweenMax.set(that.viewRoot, { scale: 0 });
		TweenMax.to(that.viewRoot, 0.7, { scale: 1, transformOrigin: clickPos });
	});
	Object.seal(this);
}
CopyrightView.prototype.hideView = function() {
	for (var i=this.rootNode.children.length -1; i>=0; i--) {
		this.rootNode.removeChild(this.rootNode.children[i]);
	}
};
CopyrightView.prototype.createCopyrightNotice = function() {
	var html = [];
	html.push('<p><span class="copyright">');
	html.push(this.plainCopyrightNotice(), '</span>');
	html.push('<span class="copylink" onclick="copyrightViewNotice(event)"> \u261E </span>', '</p>');
	return(html.join(''));
};
CopyrightView.prototype.createCopyrightNoticeDOM = function() {
	var root = document.createElement('p');
	var dom = new DOMBuilder();
	dom.addNode(root, 'span', 'copyright', this.plainCopyrightNotice());
	var link = dom.addNode(root, 'span', 'copyLink', ' \u261E ');
	link.setAttribute('onclick', 'copyrightViewNotice(event)');
	return(root);
};
CopyrightView.prototype.createTOCTitleDOM = function() {
	if (this.version.ownerCode === 'WBT') {
		var title = this.version.localLanguageName + ' (' + this.version.silCode + ')';
	} else {
		title = this.version.localVersionName + ' (' + this.version.code + ')';
	}
	var root = document.createElement('p');
	var dom = new DOMBuilder();
	dom.addNode(root, 'span', 'copyTitle', title);
	return(root);
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
* Language (lang code), Translation Name (trans code),
* Copyright C year, Organization,
* Organization URL, link image
*/
CopyrightView.prototype.createAttributionView = function() {
	console.log('inside show Attribution View');
	var dom = new DOMBuilder();
	var root = document.createElement('div');
	root.setAttribute('id', 'attribution');
	
	var closeIcon = drawCloseIcon(24, '#F70000');
	closeIcon.setAttribute('id', 'closeIcon');
	root.appendChild(closeIcon);
	var that = this;
	closeIcon.addEventListener('click', function(event) {
		for (var i=that.rootNode.children.length -1; i>=0; i--) {
			that.rootNode.removeChild(that.rootNode.children[i]);
		}
	});
	
	var nameNode = dom.addNode(root, 'p', 'attribVers');
	dom.addNode(nameNode, 'span', null, addAbbrev(this.version.localVersionName, this.version.code) + ', ');
	dom.addNode(nameNode, 'span', null, addAbbrev(this.version.localLanguageName, this.version.silCode));
	var copyNode = dom.addNode(root, 'p', 'attribCopy');
	if (this.version.copyrightYear === 'PUBLIC') {
		dom.addNode(copyNode, 'span', null, 'Public Domain');
	} else {
		dom.addNode(copyNode, 'span', null, String.fromCharCode('0xA9') + String.fromCharCode('0xA0') + this.version.copyrightYear);
	}
	dom.addNode(copyNode, 'span', null, ', ' + this.version.ownerName);
	var link = dom.addNode(root, 'p', 'attribLink', 'http://www.' + this.version.ownerURL + '/');
	link.addEventListener('click', function(event) {
		cordova.InAppBrowser.open('http://' + this.version.ownerURL, '_blank', 'location=yes');
	});
	return(root);
	
	function addAbbrev(name, abbrev) {
		return(name + String.fromCharCode('0xA0') + '(' + abbrev + ')');
	}
};

