/**
* This class initializes the App with the correct Bible versions
* and starts.
* It also contains all of the custom event handler.  This is so they are
* guaranteed to only be created once, even when there are multiple
*/
function AppInitializer() {
	this.controller = null;
	this.langPrefCode = null;
	this.countryCode = null;
	Object.seal(this);
}
AppInitializer.prototype.begin = function() {
	var that = this;
	console.log("AppInitializer.begin BibleAppConfig.versionCode = ", BibleAppConfig.versionCode);
	var settingStorage = new SettingStorage();
	deviceSettings.loadDeviceSettings();
	deviceSettings.locale(function(locale, langCode, scriptCode, countryCode) {
		console.log('user locale ', locale, langCode, countryCode);
		that.langPrefCode = langCode;
		that.countryCode = countryCode;
		var appUpdater = new AppUpdater(settingStorage);
		console.log('START APP UPDATER');
		appUpdater.doUpdate(function() {
			console.log('DONE APP UPDATER');
			var versionsAdapter = new VersionsAdapter();
			versionsAdapter.selectAWSRegion(countryCode, function(awsRegion) {
				AWS.initializeRegion(awsRegion, function(done) {
					console.log('AWS Initialized ' + awsRegion + ' ' + done);
				});
			});			
		    settingStorage.getCurrentVersion(function(versionFilename) {
			    if (versionFilename) {
				    // Process with User's Version
			    	changeVersionHandler(versionFilename);
			    } else {
					versionsAdapter.defaultVersion(langCode, function(filename) {
						console.log('default version determined ', filename);
						var parts = filename.split('.');
						var versionCode = parts[0]; // This hack requires version code to be part of filename.
						settingStorage.getInstalledVersion(versionCode, function(installedVersion) {
							if (installedVersion) {
								// Process locale's default version installed
								changeVersionHandler(filename);
							} else {
								var gsPreloader = new GSPreloader(gsPreloaderOptions);
								gsPreloader.active(true);
								var downloader = new FileDownloader(versionsAdapter, locale, 'none');
								downloader.download(filename, function(error) {
									//console.log('Download error', JSON.stringify(error));
									gsPreloader.active(false);
									if (error) {
										console.log(JSON.stringify(error));
										// Process all default version on error
										changeVersionHandler(DEFAULT_VERSION);
									} else {
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
	});
    
    document.body.addEventListener(BIBLE.CHG_VERSION, function(event) {
		changeVersionHandler(event.detail.version);
	});
		
	function changeVersionHandler(versionFilename) {
		console.log('CHANGE VERSION TO', versionFilename);
		var currBible = new BibleVersion(that.langPrefCode, that.countryCode);
		currBible.fill(versionFilename, function() {
			if (that.controller) {
				that.controller.close();
			}
			settingStorage.setCurrentVersion(versionFilename);
			settingStorage.setInstalledVersion(currBible.code, versionFilename, currBible.bibleVersion);
			console.log("Begin AppViewController");
			that.controller = new AppViewController(currBible, settingStorage);
			that.controller.begin();
			console.log('End AppViewController.begin');
			enableHandlersExcept('NONE');
			enableAudioPlayer();		
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
	function enableAudioPlayer() {
		console.log("INSIDE ENABLE AUDIO PLAYER");
		window.AudioPlayer.isPlaying(function(playing) {
			console.log("INSIDE IS PLAYING: " + playing);
			if (playing === "F") {
				document.body.addEventListener(BIBLE.SHOW_AUDIO, startAudioHandler);
			//} else {
				//document.body.removeEventListener(BIBLE.SHOW_AUDIO, startAudioHandler);
			}
		});
	}
	function startAudioHandler(event) {
		document.body.removeEventListener(BIBLE.SHOW_AUDIO, startAudioHandler);
		document.body.addEventListener(BIBLE.STOP_AUDIO, stopAudioHandler);
		document.body.addEventListener(BIBLE.SCROLL_TEXT, animateScrollToHandler);
		var ref = new Reference(event.detail.id);
		window.AudioPlayer.present(ref.book, ref.chapter,
			function() {
				console.log("SUCCESSFUL EXIT FROM AudioPlayer");
				document.body.removeEventListener(BIBLE.STOP_AUDIO, stopAudioHandler);
				document.body.removeEventListener(BIBLE.SCROLL_TEXT, animateScrollToHandler);
				document.body.addEventListener(BIBLE.SHOW_AUDIO, startAudioHandler);
			}
		);	
	}
	function stopAudioHandler(event) {
		document.body.removeEventListener(BIBLE.STOP_AUDIO, stopAudioHandler);
		document.body.removeEventListener(BIBLE.SCROLL_TEXT, animateScrollToHandler);
		document.body.addEventListener(BIBLE.SHOW_AUDIO, startAudioHandler);
		window.AudioPlayer.stop(function() {
			console.log("SUCCESSFUL STOP OF AudioPlayer");			
		});		
	}
	function animateScrollToHandler(event) {
		var nodeId = event.detail.id;
		console.log('animateScrollTo', nodeId);
		var verse = document.getElementById(nodeId);
		if (verse) {
			var rect = verse.getBoundingClientRect();
			TweenMax.killTweensOf(window);
			var yPosition = rect.top + window.scrollY - that.controller.header.barHite;
			TweenMax.to(window, 0.7, {scrollTo: { y: yPosition, autoKill: false }});
		}
	}
	function showQuestionsHandler(event) {
		disableHandlers();
		that.controller.clearViews();	
		that.controller.questionsView.showView();
		enableHandlersExcept(BIBLE.SHOW_QUESTIONS);
	}
	function showVideoListHandler(event) {
		disableHandlers();
		that.controller.clearViews();
		that.controller.videoListView.showView();
		enableHandlersExcept(BIBLE.SHOW_VIDEO);
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
		document.body.removeEventListener(BIBLE.SHOW_VIDEO, showVideoListHandler);
		document.body.removeEventListener(BIBLE.SHOW_SETTINGS, showSettingsHandler);
	}
	function enableHandlersExcept(name) {
		if (name !== BIBLE.SHOW_TOC) document.body.addEventListener(BIBLE.SHOW_TOC, showTocHandler);
		if (name !== BIBLE.SHOW_SEARCH) document.body.addEventListener(BIBLE.SHOW_SEARCH, showSearchHandler);
		if (name !== BIBLE.SHOW_PASSAGE) document.body.addEventListener(BIBLE.SHOW_PASSAGE, showPassageHandler);
		if (name !== BIBLE.SHOW_QUESTIONS) document.body.addEventListener(BIBLE.SHOW_QUESTIONS, showQuestionsHandler);
		if (name !== BIBLE.SHOW_VIDEO) document.body.addEventListener(BIBLE.SHOW_VIDEO, showVideoListHandler);
		if (name !== BIBLE.SHOW_SETTINGS) document.body.addEventListener(BIBLE.SHOW_SETTINGS, showSettingsHandler);
	}
};