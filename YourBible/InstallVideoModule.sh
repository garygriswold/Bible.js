#!/bin/sh

cordova plugin remove com-shortsands-videoplayer
cordova plugin add $HOME/ShortSands/BibleApp/Plugins/VideoPlayer
cp plugins/com-shortsands-videoplayer/src/android/build-extras.gradle platforms/android/
cordova prepare ios

