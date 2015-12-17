/**
* This class presents the list of available versions to download
*/
var FLAG_PATH = 'licensed/icondrawer/flags/64/';

function VersionsView(settingStorage) {
	this.settingStorage = settingStorage;
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
				flagNode.setAttribute('src', FLAG_PATH + row.countryCode.toLowerCase() + '.png');
				that.dom.addNode(countryNode, 'span', null, row.localName);
			}
		}
		that.rootNode.appendChild(root);
		that.root = root;
	});
	
	function countryClickHandler(event) {
		this.removeEventListener('click', countryClickHandler);
		that.buildVersionList(this);
	}
};
VersionsView.prototype.buildVersionList = function(countryNode) {
	var that = this;
	var parent = countryNode.parentElement;
	var countryCode = countryNode.id.substr(3);
	var primLanguage = countryNode.getAttribute('data-lang');
	this.settingStorage.getVersions();
	this.settingStorage.getCurrentVersion(function(currentVersion) {
		that.database.selectVersions(countryCode, primLanguage, function(results) {
			if (! (results instanceof IOError)) {
				for (var i=0; i<results.length; i++) {
					var row = results[i];
					var versionNode = that.dom.addNode(parent, 'table', 'vers');
					var rowNode = that.dom.addNode(versionNode, 'tr');
					var leftNode = that.dom.addNode(rowNode, 'td', 'versLeft');
					that.dom.addNode(leftNode, 'p', 'langName', row.localLanguageName);
					var versionName = (row.localVersionName) ? row.localVersionName : row.scope;
					that.dom.addNode(leftNode, 'span', 'versName', versionName + ',  ');
					that.dom.addNode(leftNode, 'span', 'copy', copyright(row));
					
					var rightNode = that.dom.addNode(rowNode, 'td', 'versRight');
					var btnNode = that.dom.addNode(rightNode, 'button', 'versIcon');
					
					var iconNode = that.dom.addNode(btnNode, 'img');
					iconNode.setAttribute('id', 'ver' + row.versionCode);
					iconNode.setAttribute('data-id', 'fil' + row.filename);
					if (row.filename === currentVersion) {
						iconNode.setAttribute('src', 'licensed/sebastiano/check.png');
					} else if (that.settingStorage.hasVersion(row.versionCode)) {
						iconNode.setAttribute('src', 'licensed/sebastiano/contacts.png');
						iconNode.addEventListener('click',  selectVersionHandler);
					} else {
						iconNode.setAttribute('src', 'licensed/sebastiano/cloud-download.png');
						iconNode.addEventListener('click', downloadVersionHandler);
					}
				}
			}
		});
	});
	
	function selectVersionHandler(event) {
		var filename = this.getAttribute('data-id').substr(3);
		document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_VERSION, { detail: { version: filename }}));
	}
	function downloadVersionHandler(event) {
		this.removeEventListener('click', downloadVersionHandler);
		var gsPreloader = new GSPreloader(gsPreloaderOptions);
		gsPreloader.active(true);
		var iconNode = this;
		var versionCode = iconNode.id.substr(3);
		var versionFile = iconNode.getAttribute('data-id').substr(3);
		
		var downloader = new FileDownloader(SERVER_HOST, SERVER_PORT);
		downloader.download(versionFile, function(results) {
			gsPreloader.active(false);
			if (results instanceof IOError) {
				// download did not succeed.  What error do I show?
			} else {
				that.settingStorage.setVersion(versionCode, versionFile);
				iconNode.setAttribute('src', 'licensed/sebastiano/contacts.png');
				document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_VERSION, { detail: { version: versionFile }}));
			}
		});
	}
	function copyright(row) {
		if (row.copyrightYear === 'PUBLIC') {
			return(row.ownerName + ', Public Domain');
		} else {
			var result = String.fromCharCode('0xA9');
			if (row.copyrightYear) result += String.fromCharCode('0xA0') + row.copyrightYear;
			if (row.ownerName) result += ', ' + row.ownerName;
			return(result);
		}
	}
};

