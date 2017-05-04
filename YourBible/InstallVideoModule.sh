#!/bin/sh

cordova plugin remove com-shortsands-videoplayer
cordova plugin add $HOME/ShortSands/BibleApp/Plugins/VideoPlayer
cp build-extras.gradle platforms/android/
cordova prepare ios

## change cp to pick it up from plugin, not app directory