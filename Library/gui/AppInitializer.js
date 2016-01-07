/**
* This class initializes the App with the correct Bible versions
* and starts.
*/
function AppInitializer() {	
}
AppInitializer.prototype.begin = function() {
    FastClick.attach(document.body);
    var settingStorage = new SettingStorage();
    
    document.body.addEventListener(BIBLE.CHG_VERSION, function(event) {
		console.log('CHANGE VERSION TO', event.detail.version);
		settingStorage.setCurrentVersion(event.detail.version);
		changeVersionHandler(event.detail.version);
	});

	settingStorage.getCurrentVersion(function(version) {
		if (version == null) {
			version = 'WEB.db1'; // Where does the defalt come from.  There should be one for each major language.
			settingStorage.setVersion('WEB', version);//records version is on device.
			settingStorage.setCurrentVersion(version);//records this is current version.
		}
		changeVersionHandler(version);
	});
		
	function changeVersionHandler(version) {
		var controller = new AppViewController(version, settingStorage);
		controller.begin();
	}
};