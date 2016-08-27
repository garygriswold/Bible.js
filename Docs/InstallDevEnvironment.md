Update the Development Environment
==================================

This contains notes of little got'yas found along the way.
It is here to help my weak memory, and others who might find it.
Gary Griswold

July 2, 2015
cordova run ios --device - produced an error as follows:
Unable to locate DeveloperDiskImage.dmg
It appears that it is expecting to find this in a directory called latest.  The solution is to create a symlink that defines latest.
cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport
sudo ln -s 8.1 ./Latest

Nov 29, 2015
Installed Beta version of WKWebView from Telerik
cordova plugin add cordova-plugin-wkwebview --variable WKWEBVIEW_SERVER_PORT=12344
From: https://github.com/Telerik-Verified-Plugins/WKWebView
This change was essential to have smooth scrolling in ios, because UIWebView does not permit Javascript to execute while scrolling is happening, but this limitation was fixed in WKWebView, because it was otherwise much more efficient.

March 26, 2016

Download Node 4.4.1
-------------------

	download from nodejs.org and run installer
	node -v -> 4.4.1
	npm -v -> 2.14.20
	
Install all needed node modules
-------------------------------

	sudo npm install -g node-gyp   # needed for sqlite and must be -g
	npm install sqlite3
	npm install node-uuid
	npm install restify
	
Start Server Locally & Test
---------------------------

	cd Server/www
	./ServerDev.sh
	cd UnitTests
	./ServerMethodTests.sh
	
Update Cordova to Latest
------------------------

I had tried an upgrade to 6.x and then attempted to run everything, and nothing worked,
and there was no diagnostic information that I could find.  So, this is a re-attempt by
recreating everything and then moving the current project into a new project.

	sudo npm install -g cordova
	# got warnings
	sudo npm -g uninstall cordova
	sudo npm install -g cordova
	# still got warnings 
	cordova -v -> 6.1.0
	
	cordova create YourBible com.shortsands.yourbible YourBible
	cd YourBible
	cordova platform add browser --save
	cordova platform add ios --save
	cordova platform add android --save
	
	cordova plugin list
	cordova plugin add cordova-plugin-console
	cordova plugin add cordova-plugin-device
	cordova plugin add cordova-plugin-file
	cordova plugin add cordova-plugin-file-transfer (already install)
	cordova plugin add cordova-plugin-globalization
	cordova plugin add cordova-plugin-inappbrowser
	cordova plugin add cordova-plugin-network-information
	cordova plugin add cordova-plugin-splashscreen
	cordova plugin add cordova-plugin-statusbar
	cordova plugin add cordova-plugin-zip (already installed)
	cordova plugin add cordova-sqlite-storage
	
	plugin version changes in upgrade
	WKWebView 			0.6.7	eliminated
	Console 			1.0.2	1.0.2
	Device 				1.1.0	1.1.1
	File 				3.0.0	4.1.1
	File Transfer 		1.4.0	1.5.0
	Globalization 		1.0.2	1.0.3
	InAppBrowser 		1.3.0	1.3.0
	Network Information 1.1.0	1.2.0
	Splashscreen 		3.0.0	3.2.1
	StatusBar 			2.0.0	2.1.2
	CordovaWebServer 	1.0.3	eliminated
	WhiteList 			1.2.0	1.2.1
	Zip 				3.0.0	3.1.0
	Sqlite 				0.7.7	0.8.5	
	
	cordova plugin save (updates config.xml with versions)
	
The file plugin produced the following message:
The Android Persistent storage location now defaults to "Internal". Please check this plugins README to see if you application needs any changes in its config.xml.
If this is a new application no changes are required.
If this is an update to an existing application that did not specify an "AndroidPersistentFileLocation" you may need to add:
      "<preference name="AndroidPersistentFileLocation" value="Compatibility" />"
to config.xml in order for the application to find previously stored files.


Setup IOS Platform
------------------

	xcode-select --install (message says already done)
	sudo npm install -g ios-sim (succeeds with warnings)
	sudo npm install -g ios-deploy --allow-root (fails completely)
	
Problems with sqlite connector
------------------------------

The standard cordova-sqlite-storage plugin did not have the correct
	cordova plugin remove cordova-sqlite-storage
	cordova plugin add cordova-sqlite-ext

Setup Android Development Environment
-------------------------------------

	download JAVA JDK 8u77
	Set JAVA_HOME to Home directory beneath SDK (it was done by .dmg)
	download android SDK tools
	Set export ANDROID_HOME=$HOME/Android_SDKS/android-sdk-macosx
	
Add WKWebView
-------------

Some documentation for cordova 6.0 stated that support for WKWebView was built in,
but this does not appear to be the case with 6.1.  So, it probably never worked in 6.0.

	cordova plugin add cordova-plugin-wkwebview
	cordova plugin save
	
Unfortunately this resulted in a compile error, and a review of the plugin documentation 
states that the plugin is not compatible with ios 4.x, but use ios 3.x instead.

	cordova platform remove ios --save
	cordova platform add ios@^3.9.2 --save
	
Weinre
======

Install Weinre
--------------

	sudo npm -g install weinre
	
Run Weinre
----------

	weinre —-httpPort=3000 —-boundHost=-all-

	add the following to index.html temporarily
	<script src="http://10.0.1.18:3000/target/target-script-min.js"></script>

	cordova run platform —-device

	http://10.0.1.18:3000/
	
	
Re Add WhiteList
----------------

File download is not working for Android, and I think it is the absence of whitelist

	cordova plugin add cordova-plugin-whitelist --save

	
Add Keyboard
------------
	
	cordova plugin add ionic-plugin-keyboard --save

	

