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
    settingStorage.create(function() {
    	var fileMover = new FileMover(settingStorage);
    	console.log('START MOVE FILES');
		fileMover.copyFiles(function() {
			console.log('DONE WITH MOVE FILES');
			settingStorage.initSettings();   
		    settingStorage.getCurrentVersion(function(versionFilename) {
				if (versionFilename == null) {
					deviceSettings.prefLanguage(function(locale) {
						var parts = locale.split('-');
						versionFilename = settingStorage.defaultVersion(parts[0]);
						settingStorage.setCurrentVersion(versionFilename);
						changeVersionHandler(versionFilename);
					});
				} else {
					changeVersionHandler(versionFilename);
				}
			});
    	});
    });
    
    document.body.addEventListener(BIBLE.CHG_VERSION, function(event) {
		settingStorage.setCurrentVersion(event.detail.version);
		changeVersionHandler(event.detail.version);
	});
		
	function changeVersionHandler(versionFilename) {
		console.log('CHANGE VERSION TO', versionFilename);
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