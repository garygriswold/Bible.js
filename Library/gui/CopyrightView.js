/**
* NOTE: This is a global method, not a class method, because it
* is called by the event handler created in createCopyrightNotice.
*/
function addCopyrightViewNotice(event) {
	event.stopImmediatePropagation();
	document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_ATTRIB, { detail: event }));
}
/**
* This class is used to create the copyright notice that is put 
* at the bottom of each chapter, and the learn more page that appears
* when that is clicked.
*/
function CopyrightView(version) {
	this.version = version;
	this.copyrightNotice = this.createCopyrightNotice();
	this.viewRoot = null;
	var that = this;
	document.body.addEventListener(BIBLE.SHOW_ATTRIB, function(event) {
		if (that.viewRoot == null) {
			that.viewRoot = that.createAttributionView();
		}
		var target = event.detail.target.parentNode;
		target.appendChild(that.viewRoot);
		
		var rect = target.getBoundingClientRect();
		if (window.innerHeight < rect.top + rect.height) {
			// Scrolls notice up when text is not in view.
			// limits scroll to rect.top so that top remains in view.
			window.scrollBy(0, Math.min(rect.top, rect.top + rect.height - window.innerHeight));	
		}
	});
	Object.seal(this);
}
CopyrightView.prototype.createCopyrightNotice = function() {
	var html = [];
	html.push('<p><span class="copyright">');
	html.push(this.plainCopyrightNotice(), '</span>');
	html.push('<span class="copylink" onclick="addCopyrightViewNotice(event)"> \u261E </span>', '</p>');
	return(html.join(''));
};
CopyrightView.prototype.createCopyrightNoticeDOM = function() {
	var root = document.createElement('p');
	var dom = new DOMBuilder();
	dom.addNode(root, 'span', 'copyright', this.plainCopyrightNotice());
	var link = dom.addNode(root, 'span', 'copylink', ' \u261E ');
	link.addEventListener('click',  addCopyrightViewNotice);	
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
	
	var closeIcon = drawCloseIcon(24, '#777777');
	closeIcon.setAttribute('id', 'closeIcon');
	root.appendChild(closeIcon);
	closeIcon.addEventListener('click', function(event) {
		if (root && root.parentNode) {
			root.parentNode.removeChild(root);
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
	var webAddress = 'http://' + this.version.ownerURL + '/';
	var link = dom.addNode(root, 'p', 'attribLink', webAddress);
	link.addEventListener('click', function(event) {
		cordova.InAppBrowser.open(webAddress, '_blank', 'location=yes');
	});
	return(root);
	
	function addAbbrev(name, abbrev) {
		return(name + String.fromCharCode('0xA0') + '(' + abbrev + ')');
	}
};

