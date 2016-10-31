/**
* This class presents the list of available versions to download
*/
var FLAG_PATH = 'licensed/icondrawer/flags/64/';

function VersionsView(settingStorage) {
	this.settingStorage = settingStorage;
	this.database = new VersionsAdapter();
	var that = this;
	that.translation = null;
	deviceSettings.prefLanguage(function(locale) {
		that.database.buildTranslateMap(locale, function(results) {
			that.translation = results;
		});		
	});
	this.root = null;
	this.rootNode = document.getElementById('settingRoot');
	this.defaultCountryNode = null;
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

				var countryNode = that.dom.addNode(groupNode, 'table', 'ctry', null, 'cty' + row.countryCode);
				countryNode.addEventListener('click', countryClickHandler);
				if (row.countryCode === 'WORLD') {
					that.defaultCountryNode = countryNode;
				}
				
				var rowNode = that.dom.addNode(countryNode, 'tr');
				var flagCell = that.dom.addNode(rowNode, 'td', 'ctryFlag');
				
				var flagNode = that.dom.addNode(flagCell, 'img');
				flagNode.setAttribute('src', FLAG_PATH + row.countryCode.toLowerCase() + '.png');
				
				var prefCtryName = that.translation[row.countryCode];
				if (prefCtryName == null) {
					prefCtryName = that.translation['en'];
				}
				that.dom.addNode(rowNode, 'td', 'localCtryName', prefCtryName);
			}
		}
		that.dom.addNode(root, 'p', 'shortsands', 'Your Bible by Short Sands, LLC. support@shortsands.com, version: ' + 
					BuildInfo.version);
		that.rootNode.appendChild(root);
		that.buildVersionList(that.defaultCountryNode);
		that.root = root;
	});
	
	function countryClickHandler(event) {
		if (this.parentElement.children.length === 1) {
			that.buildVersionList(this);		
		} else {
			var parent = this.parentElement;
			for (var i=parent.children.length -1; i>0; i--) {
				parent.removeChild(parent.children[i]);
			}
		}
	}
};
VersionsView.prototype.buildVersionList = function(countryNode) {
	var that = this;
	var parent = countryNode.parentElement;
	var countryCode = countryNode.id.substr(3);
	this.settingStorage.getVersions();
	this.settingStorage.getCurrentVersion(function(currentVersion) {
		that.database.selectVersions(countryCode, function(results) {
			if (! (results instanceof IOError)) {
				for (var i=0; i<results.length; i++) {
					var row = results[i];
					var versionNode = that.dom.addNode(parent, 'table', 'vers');
					var rowNode = that.dom.addNode(versionNode, 'tr');
					var leftNode = that.dom.addNode(rowNode, 'td', 'versLeft');
					
					var preferredName = that.translation[row.langCode];
					var languageName = (preferredName == null || preferredName === row.localLanguageName) 
						? row.localLanguageName 
						: row.localLanguageName + ' (' + preferredName + ')';
					that.dom.addNode(leftNode, 'p', 'langName', languageName);
					var versionName = (row.localVersionName) ? row.localVersionName : row.scope;
					var versionAbbr = (row.versionAbbr && row.versionAbbr.length > 0) ? row.versionAbbr : '';
					
					var versNode = that.dom.addNode(leftNode, 'p', 'versDesc');
					versNode.setAttribute('dir', row.direction);
					that.dom.addNode(versNode, 'span', 'versName', '\u2000' + versionName + '\u2000');
					that.dom.addNode(versNode, 'bdi', 'versAbbr', '\u2000' + versionAbbr + '\u2000');
					that.dom.addNode(versNode, 'bdi', 'versOwner', '\u2000' + row.localOwnerName + '\u2000');
					
					var rightNode = that.dom.addNode(rowNode, 'td', 'versRight');
					var btnNode = that.dom.addNode(rightNode, 'button', 'versIcon');
					
					var iconNode = that.dom.addNode(btnNode, 'img');
					iconNode.setAttribute('id', 'ver' + row.versionCode);
					iconNode.setAttribute('data-id', 'fil' + row.filename);
					if (row.filename === currentVersion) {
						iconNode.setAttribute('src', 'licensed/sebastiano/check.png');
						iconNode.addEventListener('click', selectVersionHandler);
					} else if (that.settingStorage.hasVersion(row.versionCode)) {
						iconNode.setAttribute('src', 'licensed/sebastiano/contacts.png');
						iconNode.addEventListener('click',  selectVersionHandler);
					} else {
						iconNode.setAttribute('src', 'licensed/sebastiano/cloud-download.png');
						iconNode.addEventListener('click', downloadVersionHandler);
					}
				}
			}
			debugLogVersions();
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
		that.settingStorage.getCurrentVersion(function(currVersion) {
			var downloader = new FileDownloader(SERVER_HOST, SERVER_PORT, that.database, currVersion);
			downloader.download(versionFile, function(error) {
				gsPreloader.active(false);
				if (error) {
					console.log(JSON.stringify(error));
				} else {
					that.settingStorage.setVersion(versionCode, versionFile);
					iconNode.setAttribute('src', 'licensed/sebastiano/contacts.png');
					document.body.dispatchEvent(new CustomEvent(BIBLE.CHG_VERSION, { detail: { version: versionFile }}));
				}
			});
		});
	}
	function debugLogVersions() {
		var versionNames = Object.keys(that.settingStorage.loadedVersions);
		for (var i=0; i<versionNames.length; i++) {
			var version = versionNames[i];
			var filename = that.settingStorage.loadedVersions[version];
			console.log('INSTALLED VERSION', version, filename);
		}
		that.settingStorage.selectSettings(function(results) {
			console.log('SETTINGS', JSON.stringify(results));
		});
	}
};

