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
		that.database.buildTranslateMap('es', function(results) {
			that.translation = results;
		});		
	});
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

				var countryNode = that.dom.addNode(groupNode, 'table', 'ctry', null, 'cty' + row.countryCode);
				countryNode.addEventListener('click', countryClickHandler);
				
				var rowNode = that.dom.addNode(countryNode, 'tr');
				var flagCell = that.dom.addNode(rowNode, 'td', 'ctryFlag');
				
				var flagNode = that.dom.addNode(flagCell, 'img');
				flagNode.setAttribute('src', FLAG_PATH + row.countryCode.toLowerCase() + '.png');
				
				that.dom.addNode(rowNode, 'td', 'localCtryName', row.localCountryName);
				var prefLangName = that.translation[row.countryCode];
				if (prefLangName !== row.localCountryName) {
					flagCell.setAttribute('rowspan', 2);
					var row2Node = that.dom.addNode(countryNode, 'tr');
					that.dom.addNode(row2Node, 'td', 'ctryName', prefLangName);
				}
			}
		}
		that.rootNode.appendChild(root);
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
					
					var prefLangName = that.translation[row.langCode];
					var languageName = (prefLangName === row.localLanguageName) ? prefLangName : row.localLanguageName + ' (' + prefLangName + ')';
					that.dom.addNode(leftNode, 'p', 'langName', languageName);
					var versionName = (row.localVersionName) ? row.localVersionName : row.scope;
					that.dom.addNode(leftNode, 'span', 'versName', versionName + ',  ');
					
					var ownerNode = that.dom.addNode(leftNode, 'span', 'versName', row.localOwnerName);
					
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
		that.settingStorage.getCurrentVersion(function(currVersion) {
			var downloader = new FileDownloader(SERVER_HOST, SERVER_PORT, currVersion);
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
};

