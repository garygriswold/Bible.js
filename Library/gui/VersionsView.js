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
	else if (this.rootNode.children.length < 4) {
		this.rootNode.appendChild(this.root);
		window.scrollTo(10, this.scrollPosition);// move to settings view?
	}
};
VersionsView.prototype.buildCountriesList = function() {
	var that = this;
	var root = document.createElement('div');
	this.database.selectCountries(function(results) {
		if (! (results instanceof IOError)) {
			for (var i=0; i<results.length; i++) {
				var row = results[i];
				var groupNode = that.dom.addNode(root, 'div');
				var countryNode = that.dom.addNode(groupNode, 'div', 'ctry', null, 'cty' + row.countryCode);
				countryNode.setAttribute('data-lang', row.primLanguage);
				countryNode.addEventListener('click', countryClickHandler);
				var flagNode = that.dom.addNode(countryNode, 'img');
				flagNode.setAttribute('src', 'media/flags/64/' + row.countryCode + '.png');
				flagNode.setAttribute('alt', 'Flag');
				that.dom.addNode(countryNode, 'span', null, row.localName);
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
VersionsView.prototype.buildVersionList = function(countryNode) {
	var that = this;
	var parent = countryNode.parentElement;
	var countryCode = countryNode.id.substr(3);
	var primLanguage = countryNode.getAttribute('data-lang');
	this.database.selectVersions(countryCode, primLanguage, function(results) {
		if (! (results instanceof IOError)) {
			for (var i=0; i<results.length; i++) {
				var row = results[i];
				var versionNode = that.dom.addNode(parent, 'div', 'vers');
				that.dom.addNode(versionNode, 'p', 'langName', row.localLanguageName);
				var versionName = (row.localVersionName) ? row.localVersionName : row.scope;
				that.dom.addNode(versionNode, 'span', 'versName', versionName + ',  ');
				that.dom.addNode(versionNode, 'span', 'copy', copyright(row));
				
				versionNode.addEventListener('click', versionClickHandler);
			}
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