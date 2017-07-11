#!/bin/sh -ve

cordova plugin remove com-shortsands-videoplayer
cordova plugin remove com-shortsands-aws
cordova plugin remove com-shortsands-pkzip
#cordova platform remove ios
#cordova platform add ios
cordova plugin add $HOME/ShortSands/BibleApp/Plugins/PKZip --nofetch
cordova plugin add $HOME/ShortSands/BibleApp/Plugins/AWS --nofetch
cordova plugin add $HOME/ShortSands/BibleApp/Plugins/VideoPlayer --nofetch
#cp plugins/com-shortsands-videoplayer/src/android/build-extras.gradle platforms/android/
cordova prepare ios

