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
	
	
================================
Nov 15, 2016 

Attempt to update to the latest, because old ios 3.9.2 is not building
The problem is that one plugin cordova-plugin-wkwebview is not compatible
with ios 4.0 and above.

So, try to update the system to all of the latest without wkwebview and try
to get everything running.  Once that works, then try a different wkwebview plugin.


Current Status
--------------
The current versions are, and the latest versions are as follows:

cordova currently 6.1.0, latest 6.4.0

ios current 3.9.2, latest 4.3.0
android current 5.1.1 latest 6.0.0

cordova-plugin-console spec="~1.0.2" -> 1.0.4
cordova-plugin-device spec="~1.1.1" -> 1.1.3
cordova-plugin-file spec="~4.1.1" -> 4.3.0
cordova-plugin-file-transfer spec="~1.5.0" -> 1.6.0
cordova-plugin-globalization spec="~1.0.3" -> 1.0.4
cordova-plugin-inappbrowser spec="~1.3.0" -> 1.5.0
cordova-plugin-network-information spec="~1.2.0" -> 1.3.0
cordova-plugin-splashscreen spec="~3.2.1" -> 4.0.0
cordova-plugin-statusbar spec="~2.1.2" -> 2.2.0
cordova-plugin-zip spec="~3.1.0" -> unchanged
cordova-sqlite-ext spec="~0.8.6" -> 0.10.2
com.telerik.plugins.wkwebview spec="~0.6.9"  -> unchanged
cordova-plugin-buildinfo spec="~1.1.0" -> unchanged
cordova-plugin-whitelist spec="~1.2.2" -> 1.3.0
ionic-plugin-keyboard spec="~2.2.1" -> unchanged

Upgrade to Latest
-----------------

	cd
	sudo npm install -g cordova@latest
	
This gets numerous "uid must be an unsigned int" appears caused by npm 3.10.8

	sudo npm install -g npm
	
This gets the same error, and still has 3.10.8

	sudo npm install -g npm@latest 
	
This gets the same error

	sudo n stable
	
This installed 7.0.0

	sudo n 6.9.1
	
This is the recommended version on the node.js website

	sudo npm install -g cordova@latest
	
** This now worked after getting the current node installed, even though the same version of npm was in use
	
	cd ShortSands/BibleApp/YourBible
	
	cordova platform update ios@latest --save
	
version 4.3.0 installed
	
	cordova platform update android@latest
	
This installed 6.1.0

	cordova platform update android@6.0.0
	
version 6.0.0 installed
	
	cordova platform update browser@latest
	
Error loading cordova-browser

*** Must manually update the platform versions in config.xml
	
	cordova plugin rm cordova-plugin-console --save
	cordova plugin add cordova-plugin-console --save
	version 1.0.4
	
This failed, because a sdk license agreement was not signed.
Downloaded an update to Android Studio

*** Changed export ANDROID_HOME=$HOME/Library/Android/sdk
This probably means the old ANDROID_HOME i.e. $HOME/Android_SDKS/android-sdk-macosx can be deleted
	
	cordova plugin rm cordova-plugin-device --save
	cordova plugin add cordova-plugin-device --save
	version 1.1.3
	
	cordova plugin rm cordova-plugin-file-transfer --save
	cordova plugin rm cordova-plugin-zip --save
		
	cordova plugin rm cordova-plugin-file --save
	cordova plugin add cordova-plugin-file --save
	version 4.3.0
	
	cordova plugin add cordova-plugin-file-transfer --save
	version 1.6.0
	
	cordova plugin rm cordova-plugin-globalization --save
	cordova plugin add cordova-plugin-globalization --save
	version 1.0.4
	
	cordova plugin rm cordova-plugin-inappbrowser --save
	cordova plugin add cordova-plugin-inappbrowser --save
	version 1.5.0
	
	cordova plugin rm cordova-plugin-network-information --save
	cordova plugin add cordova-plugin-network-information --save
	version 1.3.0
	
	cordova plugin rm cordova-plugin-splashscreen --save
	cordova plugin add cordova-plugin-splashscreen --save
	version 4.0.0
	
	cordova plugin rm cordova-plugin-statusbar --save
	cordova plugin add cordova-plugin-statusbar --save
	version 2.2.0
	
	cordova plugin add cordova-plugin-zip --save
	version 3.1.0
	
	cordova plugin rm cordova-sqlite-ext --save
	cordova plugin add cordova-sqlite-ext --save
	version 0.10.2
	
	cordova plugin rm com.telerik.plugins.wkwebview --save
	cordova plugin add ???????? --save
	
	cordova plugin rm cordova-plugin-buildinfo --save
	cordova plugin add cordova-plugin-buildinfo --save
	version 1.1.0 (no change)
	
	cordova plugin rm cordova-plugin-whitelist --save
	cordova plugin add cordova-plugin-whitelist --save
	version 1.3.0
	
	cordova plugin rm ionic-plugin-keyboard --save
	cordova plugin add ionic-plugin-keyboard --save
	version 2.2.1 (no change)
	
Reinstall platforms
-------------------

The above installation of the platforms did result in some errors that seemed like the
upgrade was incomplete, even though there were no errors.  Solution is to delete and reinstall
platforms

	cordova platform rm ios
	cordova platform rm android
	cordova platform rm browser
	
	cordova platform add ios@4.3.0
	cordova platform add android@6.0.0
	cordova platform add browser@latest
	
There are still two problems:

1) Android emulator fails for lack of space.  This must be some setting that is affecting the emulator.
I think that I recall setting it during the update of Android Studio

2) Code Signing problems on IOS

Code Signing Problems on IOS 10
-------------------------------

It seems that iOS 10 or Xcode 8 has introduced some changes in code signing.

The first step to recover from this is to create a build.json file in the root directory of the project.
Using information that is found at the following: https://dpogue.ca/articles/cordova-xcode8.html

	/usr/bin/codesign --force --sign 5411EE456B57BE9354702AB4F2189CCE2F00D1A9 --entitlements /Users/garygriswold/Library/Developer/Xcode/DerivedData/Your_Bible-fumfcrkrkiprjddabapgjzdzunaj/Build/Intermediates/ArchiveIntermediates/Your\ Bible/IntermediateBuildFilesPath/Your\ Bible.build/Debug-iphoneos/Your\ Bible.build/Your\ Bible.app.xcent --timestamp=none /Users/garygriswold/Library/Developer/Xcode/DerivedData/Your_Bible-fumfcrkrkiprjddabapgjzdzunaj/Build/Intermediates/ArchiveIntermediates/Your\ Bible/InstallationBuildProductsLocation/Applications/Your\ Bible.app
	Command /usr/bin/codesign failed with exit code 5

Some claim that this problem was caused by an invalid key '1' in the keychain and advised removing and recreating the KeyChain.
I did move the files the following files to the Desktop
	Library/Keychain/login.keychain-db
	Library/Keychain/login.keychain
I found developer.apple.com documentation that described this same procedure for recovering from a corrupted Keychain.

	Check dependencies
	No profiles for 'com.shortsands.yourbible' were found:  Xcode couldn't find a provisioning profile matching 'com.shortsands.yourbible'.
	Code signing is required for product type 'Application' in SDK 'iOS 10.1'
	
Used same provisioning file, and set team to SS ID

	Check dependencies
	Provisioning profile "iOS Team Provisioning Profile: com.shortsands.yourbible" doesn't include signing certificate "iPhone Developer: Gary N Griswold (4U62ERFA4L)".
	Code signing is required for product type 'Application' in SDK 'iOS 10.1'
	
*** I turned off "Automatic Signing" in Xcode, and selected the correct provisioning file in a pulldown.
*** This fixed the code signing problem.

	Error: Cordova needs ios-deploy version 1.9.0 or greater, you have version 1.8.5. Please download, build and install version 1.9.0 or greater from https://github.com/phonegap/ios-deploy into your path, or do 'npm install -g ios-deploy'
	
	npm install -f ios-deploy
	
*** This worked without the 'sudo'.  With the 'sudo' it did not work.
*** It installed 1.9.0.  This fixed the problem.

Update WKWebView
----------------

The com.telerik.plugins.wkwebview plugin was removed in a prior step, because it is not compatible with ios@4.
The cordova-plugin-wkwebview-engine, but it has many reported problems.  I will add it and see if it works,
and if it causes other problems.

	cordova plugin add cordova-plugin-wkwebview-engine --save
	
This is working very well.


	

	







	

