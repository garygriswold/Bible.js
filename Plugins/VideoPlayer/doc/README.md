

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
	
	