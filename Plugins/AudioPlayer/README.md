AudioPlayer
===========

Native AudioPlayers for Android and iOS, which "bookmark" the position of play
for multiple videos.

Example Use of Plugin
---------------------

    var audioUrl = "https://arc.gt/1e62h?apiSessionId=587858aea460f2.62190595";
	window.AudioPlayer.present("jesusFilm", videoUrl,
	function() {
		console.log("SUCCESS FROM AudioPlayer");
	},
	function(error) {
		console.log("ERROR FROM AudioPlayer " + error);
	});
	
Android Development
===================	
	
Development Process
-------------------

	develop at: ShortSands/BibleApp/Plugins/AudioPlayer
	
	create app: ShortSands/AudioModule
	
	script to install plugin
	./TestAudioPlugin.sh
	
Testing Android Native AudioPlayer
----------------------------------

Test the Plugin inside a simple Cordova App, executing the App and plugin.
After changing the App, I must run cordova emulate android before using
Android Studio.  After changing the plugin, I must run ./TestVideoPlugin.sh
before using Android Studio.

	open Android Studio
	select ShortSands/AudioModule/platforms/android
	run
	
Method Profiling on Android
---------------------------

	disable Instant Run: Preferences -> Build -> Instant Run
	
	Tried to use Systrace, but need to install pip the python manager
	
	Try TraceView
	
	Add Debug.startMethodTracing("plugin"); to VideoPlayer.execute
	Add Debug.stopMethodTracing(); to VideoPlayer.onActivityResult
	Add <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" /> to AndroidManifest.xml
	
	Run the App on a device or emulator
	
	In a terminal window:
		adb devices
		adb -s 015d25785e27ea11 pull /sdcard/plugin.trace $HOME
		
	In Android Studio turn on Tools -> Android -> Android Device Monitor
	
	open $HOME/plugin.trace
	
A review of the CPU utilization of my code looked good.


Memory & CPU Profiling on Android
---------------------------------
		
	Tools -> Android -> Enable ADB integration (turn on)
	Start Process	
	When started: View -> Tools -> Android Monitor
	Select com.shortsands.<whatever>
	
//Memory is usually at 7.4Meg, cpu near zero, and network near zero
//If I stop the application with Back button, home button, or kill button and restart with icon,
//the memory use stays about the same, but the CPU use spikes to 40% for couple seconds
//which looks like the prepare and seek, and then it stays high 10-20% for a few more seconds
//while it does more buffering in of content.  After that cpu use drops to near zero with just 
//and occasional jump.

//The one finding of concern is that the memory use never drops below 6.9Meg while the App is not running.
//Except if I kill the App entirely, and then it appears to drop to zero.  But, I used onDestroy to
//verify that MediaPlayer had been released and was null, and setting VideoView and VideoController
//to null did not reduce memory noticably.
	

Apple iOS Development
=====================	

Testing iOS Native AudioPlayer
------------------------------

	open Xcode
	select ShortSands/AudioModule/platforms/ios
	run
	
Getting iOS to run
-----------------

	Modify Bridging-Header.h to include required things.
	<appname>/platforms/ios/VideoProto/Bridging-Header.h
	
	#import <AVFoundation/AVFoundation.h>
	#import <AVKit/AVKit.h>
	#import <UIKit/UIKit.h>
	
	Removed unused functions that require ios 9 or 10.
	
//After installing cordova-plugin-console, the JS console.log messages do get
//into the XCode console.log, but they do not get into a file in the cordova directory
//that can be accessed when running cordova and not xCode.
	