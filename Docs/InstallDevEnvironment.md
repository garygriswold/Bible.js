Update the Development Environment - This is obsolete and should be recorded, as of July 2018, I not longer use corova
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

Console Logging
---------------

Console logging is not working on ios for simulator or device.  Although, for xcode simulator, the console
log does appear in the Xcode GUI, but I have not been able to find it on disk.

Where does Xcode put the console log?

The build is showing an error that I am not using the system copy of Ruby.
I have now fixed this by removing an older version of ruby that I was using,
and it does not fix this problem.
	
Android Environment Reinstall
-----------------------------

The Android environment stopped working because it did not find an ADV, and I did not know 
how to create one.

	PANIC: Broken AVD system path. Your ANDROID_SDK_ROOT is not set.

I first tried deleting the Android Studio and reinstalling, but I still did not get
all of the setup done.  So, it still got the same error.

So, I tried to install the tools, but still did not know how to create an adv,
it still not work.

***
Finally, I reinstalled the Studio again, but this time I went through a tutorial on creating
a Hello World Android program.  Doing the tutorial put me through all of the steps needed
to create the ADV
***

I removed a number of things generated by the install to make certain that it is fresh.

	cd /Applications/
	rm -rf "Android Studio.app"
	cd
	rm -rf .android
	cd "Library/Application Support"
	rm -rf AndroidStudio1.2
	rm -rf AndroidStudio2.2
	
Modify .profile

	export ANDROID_HOME=$HOME/Library/Android/sdk
	
	reboot
	
After reboot check that each of the deleted directories is gone

Download Studio App and Reinstall

	https://developer.android.com/studio/index.html
	
Followed Instructions for first Android Project

	https://developer.android.com/training/basics/firstapp/creating-project.html
	
Building on a connected device worked, but produced the following error:

	Instant Run detected that you are running on a target device that has a work profile or multiple user accounts.
    Launching the app under a work profile or another user account on the target device will result in a crash.
    Learn more about how to run your app under a work profile.
    
    Instructions for correcting the problem can be found at:
    https://developer.android.com/studio/run/index.html?utm_source=android-studio#ir-work-profile
    
    But, I need to have the device back in English to get this to work.
    
Build on an emulator, but it required that I develop an ADV first and prompted me through the process

Now, try it in cordova

	./RunDevice.sh android
	./RunApp.sh android
	
Both of these work well, and chrome://inspect works with each of them.

Update Platform Android
-----------------------
Nov 23, 2016
Bug was found in the handling of Android icons and splashscreens.
A note in jira said this was fixed in 6.1.0

	cordova platform rm android
	cordova platform add android@latest
	cordova platform list
	update config.xml with correct version
	
This corrected the bug

Update Node sqlite3
-------------------
Nov 27, 2016

Received an error that following file was missing:
/Users/garygriswold/node_modules/sqlite3/lib/binding/node-v48-darwin-x64/node_sqlite3.node

On inspection I did have the 'node-v46-darwin-x64'.
So, I updated sqlite3 as follows

	npm update sqlite3
	
Reinstall Cordova and All of Android
====================================
April 13, 2017

Nothing is working with Android. Builds don't work on Hello World even for cordova.
Chrome crashes, and Emulator crashes.  Android Studio seems to keep asking for the
same updates.

The solution is to delete and reinstall everything that is cordova and android,
and then use it to build a HelloWorld app before going back to my Apps.

First step is to uninstall and reinstall cordova	
	
	Tried to install and got this error
	# deprecated node-uuid@1.4.8, use uuid instead
	sudo npm -g uninstall node-uuid
	sudo npm -g uninstall cordova
	sudo npm -g install cordova
	cordova -v 6.5.0
	
Delete Android Studio and sdk

	cd /Applications/Android Studio.app
	rm -rf *
	cd ..
	rmdir "Android Studio.app"
	cd
	cd Library/Android/sdk
	rm -rf *
	
Install Android Studio

	Download from the web and follow instructions
	
Create a new empty project with android and ios platforms

	cd Desktop
	cordova create Hello3 com.shortsands.hello3 Hello3
	cd Hello3
	cordova platform add android
	cordova platform update android@6.2.1
	cordova platform add ios
	
Run the App on ios

	cordova emulate ios
	# it works

	cordova run ios --device
	Error 65 (No Team)
	Open XCode on Hello3/platforms/ios
	Set Team
	# It works

	xCode run App both in emulator and Device
	
Run the App on android

	cordova emulate android
	# Error: android: Command failed with exit code 2
	
	Android Studio with connected device
	# it works after device reboot.
	
	Android Studio with emulated device
	# it works after creating a new device
	
	chrome://inspect is working.
	
Try VideoModule project

	cordova platform update android@6.2.1
	
	cordova emulate android
	# Error: android: Command failed with exit code 2
	
	But, cordova run android --device works
	And Android Studio works both device and emulator
	And Chrome works.
	
======= Reinstall Android Studio ========
June 25, 2017

Followed the following instructions to completely erase existing Android Studio

Execute these commands from the terminal

rm -Rf /Applications/Android\ Studio.app
rm -Rf ~/Library/Preferences/AndroidStudio*
rm -Rf ~/Library/Preferences/com.google.android.*
rm -Rf ~/Library/Preferences/com.android.*
rm -Rf ~/Library/Application\ Support/AndroidStudio*
rm -Rf ~/Library/Logs/AndroidStudio*
rm -Rf ~/Library/Caches/AndroidStudio*
rm -Rf ~/.AndroidStudio*
if you would like to delete all projects:

rm -Rf ~/AndroidStudioProjects
to remove gradle related files (caches & wrapper)

rm -Rf ~/.gradle
use the below command to delete all Android Virtual Devices(AVDs) and *.keystore. 

rm -Rf ~/.android
to delete Android SDK tools

rm -Rf ~/Library/Android*

Then installed Android Studio
And set $ANDROID_HOME
And added $ANDROID_HOME/tools, tools/bin, platform-tools to PATH

But, when I ran cordova requirements, I still got an error that I did 
not have the sdk.  Apparently, because the one I had was too advanced.
So, I download the following:

https://dl.google.com/android/repository/tools_r25.2.3-macosx.zip

It contained a tools folder, which I used to in place of the one that I
had, and changed the sequence in PATH so that tools came before platform-tools

	

	
	
	
	

	










	

	







	

