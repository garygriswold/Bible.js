


Development Process
-------------------

	develop at: ShortSands/BibleApp/Plugins/VideoPlayer
	
	create app: ShortSands/VideoProto
	
	script to install plugin
	./TestVideoPlugin.sh
	
Testing Android Native VideoPlayer
----------------------------------

	open Android Studio
	select ShortSands/VideoProto/platforms/android
	run
	
Profiling on Android
--------------------

	disable Instant Run: Preferences -> Build -> Instant Run
	
	Trying to use Systrace, but need to install pip the python manager
	
	
	

Testing iOS Native VideoPlayer
------------------------------

	open Finder
	open VideoPlayer/src/ios/VideoPlayer.xcodeproj
	run
	
Getting it to run
-----------------

	Modify Bridging-Header.h to include required things.
	<appname>/platforms/ios/VideoProto/Bridging-Header.h
	
	#import <AVFoundation/AVFoundation.h>
	#import <AVKit/AVKit.h>
	#import <UIKit/UIKit.h>
	
	Removed unused functions that require ios 9 or 10.
	
	Renamed ViewController to VideoViewController
	
	?? console logging is not working ??
	
	