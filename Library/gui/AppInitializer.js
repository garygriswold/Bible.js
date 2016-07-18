/**
* This class initializes the App with the correct Bible versions
* and starts.
*/
function AppInitializer() {
	this.appViewController = null;
	Object.seal(this);
}
AppInitializer.prototype.begin = function() {
	var that = this;
    var settingStorage = new SettingStorage();
	var appUpdater = new AppUpdater(settingStorage);
	console.log('START APP UPDATER');
	appUpdater.doUpdate(function() {
		console.log('DONE APP UPDATER');
	    settingStorage.getCurrentVersion(function(versionFilename) {
			changeVersionHandler(versionFilename);
		});
	});
    //});
    
    document.body.addEventListener(BIBLE.CHG_VERSION, function(event) {
		changeVersionHandler(event.detail.version);
	});
		
	function changeVersionHandler(versionFilename) {
		console.log('CHANGE VERSION TO', versionFilename);
		var bibleVersion = new BibleVersion();
		bibleVersion.fill(versionFilename, function() {
			if (that.appViewController) {
				that.appViewController.close();
			}
			settingStorage.setCurrentVersion(bibleVersion.filename);
			that.appViewController = new AppViewController(bibleVersion, settingStorage);
			that.appViewController.begin();			
		});
	}
};