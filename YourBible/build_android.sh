#!/bin/sh -ev

# Usage build_android.sh [Release]

LIBS=$HOME/Library/Frameworks
DEBUG=$LIBS/Debug-android
RELEASE=$LIBS/Release-android

VIDEO=VideoPlayer.jar
AWS=AWS.jar
ZIP=Zip.jar

PLUGINS=$HOME/ShortSands/BibleApp/Plugins

if [ -z "$1" ]; then
SOURCE=$DEBUG 
else
SOURCE=$RELEASE
fi
echo $SOURCE

# Copy VideoPlayer.framework to it's own plugin dir
TARGET=$PLUGINS/VideoPlayer/src/android/plugin/$VIDEO
echo $TARGET
#rm -f $TARGET
cp -f $SOURCE/$VIDEO $TARGET

# Copy AWS.framework to VideoPlayer
TARGET=$PLUGINS/VideoPlayer/src/android/app/libs/$AWS
echo $TARGET
#rm -rf $TARGET
cp -f $SOURCE/$AWS $TARGET

## Copy Zip.framework to VideoPlayer
TARGET=$PLUGINS/VideoPlayer/src/android/app/libs/$ZIP
echo $TARGET
#rm -rf $TARGET
cp -f $SOURCE/$ZIP $TARGET

# Copy AWS.framework to it's own plugin dir
TARGET=$PLUGINS/AWS/src/android/plugin/$AWS
echo $TARGET
#rm -f $TARGET
cp -f $SOURCE/$AWS $TARGET

# Copy Zip.framework to AWS
TARGET=$PLUGINS/AWS/src/android/app/libs/$ZIP
echo $TARGET
#rm -rf $TARGET
cp -f $SOURCE/$ZIP $TARGET

# Copy Zip.framework to it's own build
TARGET=$PLUGINS/PKZip/src/android/plugin/$ZIP
echo $TARGET
#rm -rf $TARGET
cp -f $SOURCE/$ZIP $TARGET
