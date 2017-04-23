#!/bin/sh

cordova plugin remove com-shortsands-videoplayer
cordova plugin add $HOME/ShortSands/BibleApp/Plugins/VideoPlayer
cordova prepare ios
