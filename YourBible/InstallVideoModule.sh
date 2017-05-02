#!/bin/sh

cordova plugin remove com-shortsands-videoplayer
cordova plugin add $HOME/ShortSands/BibleApp/Plugins/VideoPlayer
cp build-extras.gradle platforms/android/
cordova prepare ios
