/**
* This class initializes the App with the correct Bible versions
* and starts.
*/
function AppInitializer() {
	this.appViewController = null;
	Object.seal(this);
}
AppInitializer.prototype.begin = function() {
    var settingStorage = new SettingStorage();
    
    document.body.addEventListener(BIBLE.CHG_VERSION, function(event) {
		console.log('CHANGE VERSION TO', event.detail.version);
		settingStorage.setCurrentVersion(event.detail.version);
		changeVersionHandler(event.detail.version);
	});
    
    var that = this;
    settingStorage.create(function() {
	    settingStorage.getCurrentVersion(function(versionFilename) {
			if (versionFilename == null) {
				deviceSettings.prefLanguage(function(locale) {
					var parts = locale.split('-');
					versionFilename = settingStorage.defaultVersion(parts[0]);
					settingStorage.setCurrentVersion(versionFilename);
					settingStorage.initSettings();
					changeVersionHandler(versionFilename);
				});
			} else {
				changeVersionHandler(versionFilename);
			}
		});
    });
		
	function changeVersionHandler(versionFilename) {
		var bibleVersion = new BibleVersion();
		bibleVersion.fill(versionFilename, function() {
			if (that.appViewController) {
				that.appViewController.close();
			}
			that.appViewController = new AppViewController(bibleVersion, settingStorage);
			that.appViewController.begin();			
		});
	}
};