/**
* NOTE: This is a global method, not a class method, because it
* is called by the event handler created in createCopyrightNotice.
*/
var COPYRIGHT_VIEW = null;

function addCopyrightViewNotice(event) {
	event.stopImmediatePropagation();
	var target = event.target.parentNode;
	target.appendChild(COPYRIGHT_VIEW);
	
	var rect = target.getBoundingClientRect();
	if (window.innerHeight < rect.top + rect.height) {
		// Scrolls notice up when text is not in view.
		// limits scroll to rect.top so that top remains in view.
		window.scrollBy(0, Math.min(rect.top, rect.top + rect.height - window.innerHeight));	
	}
}
/**
* This class is used to create the copyright notice that is put 
* at the bottom of each chapter, and the learn more page that appears
* when that is clicked.
*/
function CopyrightView(version) {
	this.version = version;
	this.copyrightNotice = this.createCopyrightNotice();
	COPYRIGHT_VIEW = this.createAttributionView();
	Object.seal(this);
}
CopyrightView.prototype.createCopyrightNotice = function() {
	var html = [];
	html.push('<p><span class="copyright">');
	html.push(this.version.copyright, '</span>');
	html.push('<span class="copylink" onclick="addCopyrightViewNotice(event)"> \u261E </span>', '</p>');
	return(html.join(''));
};
CopyrightView.prototype.createCopyrightNoticeDOM = function() {
	var root = document.createElement('p');
	var dom = new DOMBuilder();
	dom.addNode(root, 'span', 'copyright', this.version.copyright);
	var link = dom.addNode(root, 'span', 'copylink', ' \u261E ');
	link.addEventListener('click',  addCopyrightViewNotice);	
	return(root);
};
CopyrightView.prototype.createTOCTitleDOM = function() {
	if (this.version.ownerCode === 'WBT') {
		var title = this.version.localLanguageName;
		var abbrev = ' (' + this.version.silCode + ')';
	} else {
		title = this.version.localVersionName;
		abbrev = ' (' + this.version.versionAbbr + ')';
	}
	var root = document.createElement('p');
	var dom = new DOMBuilder();
	dom.addNode(root, 'span', 'copyTitle', title);
	dom.addNode(root, 'span', 'copyAbbr', abbrev);
	return(root);
};
/**
* Language (lang code), Translation Name (trans code),
* Copyright C year, Organization,
* Organization URL, link image
*/
CopyrightView.prototype.createAttributionView = function() {
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
	
	var copyNode = dom.addNode(root, 'p', 'attribVers');
	dom.addNode(copyNode, 'span', null, this.version.copyright);
	
	if (this.version.introduction) {
		var intro = dom.addNode(root, 'div', 'introduction');
		intro.innerHTML = this.version.introduction;
	}
	
	var webAddress = 'http://' + this.version.ownerURL + '/';
	var link = dom.addNode(root, 'p', 'attribLink', webAddress);
	link.addEventListener('click', function(event) {
		cordova.InAppBrowser.open(webAddress, '_blank', 'location=yes');
	});
	return(root);
};

