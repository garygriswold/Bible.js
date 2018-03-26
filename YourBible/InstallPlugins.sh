#!/bin/sh -ve

#cordova plugin remove cordova-sqlite-ext
#cordova plugin remove com-shortsands-videoplayer
cordova plugin remove com-shortsands-audioplayer
#cordova plugin remove com-shortsands-aws
#cordova plugin remove com-shortsands-pkzip
#cordova plugin remove com-shortsands-utility
#cordova platform remove ios
#cordova platform add ios

#cordova plugin add $HOME/ShortSands/BibleApp/Plugins/AWS 
#cordova plugin add $HOME/ShortSands/BibleApp/Plugins/VideoPlayer
cordova plugin add $HOME/ShortSands/BibleApp/Plugins/AudioPlayer
#cordova plugin add $HOME/ShortSands/BibleApp/Plugins/Utility --nofetch
#cp plugins/com-shortsands-videoplayer/src/android/build-extras.gradle platforms/android/
#cordova plugin add cordova-sqlite-ext --save

#cordova prepare ios
cordova prepare android

