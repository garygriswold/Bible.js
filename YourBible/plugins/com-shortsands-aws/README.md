AWS
===

This plugin provides a cordova interface to S3 routines to upload, download
and generate signed URLs.

The plugin is a thin wrapper around classes of the same function that could
be called by other native language code.


Example Use of Plugin
---------------------


	
Android Development
===================	
	
Development Process
-------------------

	develop at: ShortSands/BibleApp/Plugins/AWS
	
	create app: Desktop/AWS
	
	script to install plugin
	./TestAWS.sh
	
Testing Android Native VideoPlayer
----------------------------------

Test the Plugin inside a simple Cordova App, executing the App and plugin.
After changing the App, I must run cordova emulate android before using
Android Studio.  After changing the plugin, I must run ./TestAWS.sh
before using Android Studio.

	open Android Studio
	select Desktop/AWS/platforms/android
	run
	
Method Profiling on Android
---------------------------




Memory & CPU Profiling on Android
---------------------------------
		
	Tools -> Android -> Enable ADB integration (turn on)
	Start Process	
	When started: View -> Tools -> Android Monitor
	Select com.shortsands.<whatever>

	

Apple iOS Development
=====================	

Testing iOS Native VideoPlayer
------------------------------

	open Xcode
	select Desktop/AWS/platforms/ios
	run
	
Getting iOS to run
-----------------

	Modify Bridging-Header.h to include required things.
	<appname>/platforms/ios/VideoProto/Bridging-Header.h
	
	#import <Cordova/CDV.h>

	#import "SS_AWSS3PreSignedURL.h"
	#import "SS_AWSS3TransferUtility.h"

	#import "ioapi.h"
	#import "crypt.h"
	#import "zip.h"
	#import "unzip.h"
	

	