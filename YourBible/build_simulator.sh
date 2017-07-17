#!/bin/sh -ev

# Usage build_simulator.sh [Release]

LIBS=$HOME/Library/Frameworks
DEBUG=$LIBS/Debug-iphonesimulator
RELEASE=$LIBS/Release-iphonesimulator

VIDEO=VideoPlayer.framework
AWS=AWS.framework
ZIP=Zip.framework

PLUGINS=$HOME/ShortSands/BibleApp/Plugins

if [ -z "$1" ]; then
SOURCE=$DEBUG 
else
SOURCE=$RELEASE
fi
echo $SOURCE

# Copy VideoPlayer.framework to it's own build
TARGET=$PLUGINS/VideoPlayer/src/ios/build/$VIDEO
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$VIDEO $TARGET

# Copy AWS.framework to VideoPlayer
TARGET=$PLUGINS/VideoPlayer/src/ios/VideoPlayer/$AWS
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$AWS $TARGET

# Copy Zip.framework to VideoPlayer
TARGET=$PLUGINS/VideoPlayer/src/ios/VideoPlayer/$ZIP
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$ZIP $TARGET

# Copy AWS.framework to it's own build
TARGET=$PLUGINS/AWS/src/ios/build/$AWS
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$AWS $TARGET

# Copy Zip.framework to AWS
TARGET=$PLUGINS/AWS/src/ios/AWS/$ZIP
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$ZIP $TARGET

# Copy Zip.framework to it's own build
TARGET=$PLUGINS/PKZip/src/ios/build/$ZIP
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$ZIP $TARGET
