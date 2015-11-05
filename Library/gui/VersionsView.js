/**
* This class presents the list of available versions to download
*/
function VersionsView() {
	this.database = new VersionsAdapter()
	this.root = null;
	this.rootNode = document.getElementById('settingRoot');
	this.dom = new DOMBuilder();
	this.scrollPosition = 0;
	Object.seal(this);
}
VersionsView.prototype.showView = function() {
	if (! this.root) {
		this.buildCountriesList();
	} 
	else if (this.rootNode.children.length < 1) {
		this.rootNode.appendChild(this.root);
		window.scrollTo(10, this.scrollPosition);
	}
};
VersionsView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.scrollPosition = window.scrollY; // save scroll position till next use.
		this.rootNode.removeChild(this.root);
	}
};
VersionsView.prototype.buildCountriesList = function() {
	var that = this;
	var root = document.createElement('ul');
	this.database.selectCountries(function(results) {
		if (! (results instanceof IOError)) {
			for (var i=0; i<results.length; i++) {
				var row = results[i];
				var countryNode = that.dom.addNode(root, 'li', 'ctry', row.localName, 'cty' + row.countryCode);
				countryNode.setAttribute('data-lang', row.primLanguage);
				countryNode.addEventListener('click', countryClickHandler);
				var flagNode = that.dom.addNode(countryNode, 'img');
				flagNode.setAttribute('src', 'media/flags/64/' + row.countryCode + '.png');
				flagNode.setAttribute('alt', 'Flag');
			}
		}
		that.rootNode.appendChild(root);
		that.root = root;
	});
	
	function countryClickHandler(event) {
		this.removeEventListener('click', countryClickHandler);
		console.log('user clicked in', this.id);
		that.buildVersionList(this);
	}
};
VersionsView.prototype.buildVersionList = function(parent) {
	var that = this;
	var countryCode = parent.id.substr(3);
	var primLanguage = parent.getAttribute('data-lang');
	var versionNodeList = document.createElement('div');
	this.database.selectVersions(countryCode, primLanguage, function(results) {
		if (! (results instanceof IOError)) {
			for (var i=0; i<results.length; i++) {
				var row = results[i];
				var versionNode = that.dom.addNode(versionNodeList, 'div');
				that.dom.addNode(versionNode, 'p', 'langName', row.localLanguageName);
				var versionName = (row.localVersionName) ? row.localVersionName : row.scope;
				that.dom.addNode(versionNode, 'p', 'versName', versionName);
				that.dom.addNode(versionNode, 'p', 'copy', copyright(row));
				
				versionNode.addEventListener('click', versionClickHandler);
			}
			parent.appendChild(versionNodeList);
		}
	});
	
	function versionClickHandler(event) {
		this.removeEventListener('click', versionClickHandler);
		console.log('click on version');
	}
	function copyright(row) {
		if (row.copyrightYear === 'PUBLIC') {
			return(row.ownerName + ' Public Domain');
		} else {
			var result = [String.fromCharCode('0xA9')];
			if (row.copyrightYear) result.push(row.copyrightYear + ',');
			if (row.ownerName) result.push(row.ownerName);
			return(result.join(' '));
		}
	}
};