

Testing Android Native VideoPlayer
----------------------------------

	open Android Studio
	select ShortSands/Plugins/android/VideoPlayer
	run

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
	
	