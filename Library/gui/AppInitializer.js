/**
* This class initializes the App with the correct Bible versions
* and starts.
* It also contains all of the custom event handler.  This is so they are
* guaranteed to only be created once, even when there are multiple
*/
function AppInitializer() {
	this.controller = null;
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
		    if (versionFilename) {
			    // Process with User's Version
		    	changeVersionHandler(versionFilename);
		    } else {
			    deviceSettings.prefLanguage(function(locale) {
				    console.log('user locale ', locale);
					var parts = locale.split('-');
					var versionsAdapter = new VersionsAdapter();
					versionsAdapter.defaultVersion(parts[0], function(filename) {
						console.log('default version determined ', filename);
						var parts = filename.split('.');
						var versionCode = parts[0]; // This hack requires version code to be part of filename.
						if (appUpdater.installedVersions[versionCode]) {
							// Process locale's default version installed
							changeVersionHandler(filename);
						} else {
							var gsPreloader = new GSPreloader(gsPreloaderOptions);
							gsPreloader.active(true);
							var downloader = new FileDownloader(SERVER_HOST, SERVER_PORT, versionsAdapter, 'none');
							downloader.download(filename, function(error) {
								//console.log('Download error', JSON.stringify(error));
								gsPreloader.active(false);
								if (error) {
									console.log(JSON.stringify(error));
									// Process all default version on error
									changeVersionHandler(DEFAULT_VERSION);
								} else {
									settingStorage.setVersion(versionCode, filename);
									// Process locale's default version downloaded
									changeVersionHandler(filename);
								}
							});
						}
					});
				});
			}
		});
	});
    
    document.body.addEventListener(BIBLE.CHG_VERSION, function(event) {
		changeVersionHandler(event.detail.version);
	});
		
	function changeVersionHandler(versionFilename) {
		console.log('CHANGE VERSION TO', versionFilename);
		var bibleVersion = new BibleVersion();
		bibleVersion.fill(versionFilename, function() {
			if (that.controller) {
				that.controller.close();
			}
			settingStorage.setCurrentVersion(bibleVersion.filename);
			that.controller = new AppViewController(bibleVersion, settingStorage);
			that.controller.begin();
			console.log('*** DID enable handlers ALL');
			enableHandlersExcept('NONE');		
		});
	}
	function showTocHandler(event) {
		disableHandlers();
		that.controller.clearViews();		
		that.controller.tableContentsView.showView();
		enableHandlersExcept(BIBLE.SHOW_TOC);
	}
	function showSearchHandler(event) {
		disableHandlers();
		that.controller.clearViews();	
		that.controller.searchView.showView();
		enableHandlersExcept(BIBLE.SHOW_SEARCH);
	}		
	function showPassageHandler(event) {
		disableHandlers();
		that.controller.clearViews();
		setTimeout(function() { // delay is needed because with changes from History prior pages can interfere. Consider animation
			that.controller.codexView.showView(event.detail.id);
			enableHandlersExcept('NONE');
			var historyItem = { timestamp: new Date(), reference: event.detail.id, 
				source: 'P', search: event.detail.source };
			that.controller.history.replace(historyItem, function(count) {});
		}, 5); 
	}
	function showQuestionsHandler(event) {
		disableHandlers();
		that.controller.clearViews();	
		that.controller.questionsView.showView();
		enableHandlersExcept(BIBLE.SHOW_QUESTIONS);
	}	
	function showSettingsHandler(event) {
		disableHandlers();
		that.controller.clearViews();
		that.controller.settingsView.showView();
		enableHandlersExcept(BIBLE.SHOW_SETTINGS);
	}	
	function disableHandlers() {
		document.body.removeEventListener(BIBLE.SHOW_TOC, showTocHandler);
		document.body.removeEventListener(BIBLE.SHOW_SEARCH, showSearchHandler);
		document.body.removeEventListener(BIBLE.SHOW_PASSAGE, showPassageHandler);
		document.body.removeEventListener(BIBLE.SHOW_QUESTIONS, showQuestionsHandler);
		document.body.removeEventListener(BIBLE.SHOW_SETTINGS, showSettingsHandler);
	}
	function enableHandlersExcept(name) {
		if (name !== BIBLE.SHOW_TOC) document.body.addEventListener(BIBLE.SHOW_TOC, showTocHandler);
		if (name !== BIBLE.SHOW_SEARCH) document.body.addEventListener(BIBLE.SHOW_SEARCH, showSearchHandler);
		if (name !== BIBLE.SHOW_PASSAGE) document.body.addEventListener(BIBLE.SHOW_PASSAGE, showPassageHandler);
		if (name !== BIBLE.SHOW_QUESTIONS) document.body.addEventListener(BIBLE.SHOW_QUESTIONS, showQuestionsHandler);
		if (name !== BIBLE.SHOW_SETTINGS) document.body.addEventListener(BIBLE.SHOW_SETTINGS, showSettingsHandler);
	}
};