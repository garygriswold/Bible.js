#!/bin/sh -ve

FRAMEROOT=$HOME/Library/Frameworks
PROJROOT=$HOME/ShortSands/BibleApp/Plugins
TARGET=$PROJROOT/AWS/src/ios/AWS

ZIP=PKZip.framework

# Build iOS/Release
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Release-iphoneos/$ZIP $TARGET/
xcodebuild -configuration Release -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build

# Build Simulator/Release
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Release-iphonesimulator/$ZIP $TARGET/
xcodebuild -configuration Release -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build

# Build iOS/Debug
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Debug-iphoneos/$ZIP $TARGET/
xcodebuild -configuration Debug -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build

# Build Simulator/Debug
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$ZIP $TARGET/
xcodebuild -configuration Debug -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build

# Notice that Simulator/Debug is the last to process in order to leave Xcode in that mode.

# Copy Framework for Cordova AWS Plugin
AWS=AWS.framework
rm -rf $TARGET/../build/$AWS
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$AWS $TARGET/../build/

# Copy Framework to VideoPlayer
DEST=$PROJROOT/VideoPlayer/src/ios/VideoPlayer/$AWS
rm -rf $DEST
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$AWS $DEST

# Copy Framework to AudioPlayer
DEST=$PROJROOT/AudioPlayer/src/ios_AudioPlayer/AudioPlayer/$AWS
rm -rf $DEST
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$AWS $DEST

# Lipo info commands
lipo -info $FRAMEROOT/Release-iphoneos/AWS.framework/AWS
lipo -info $FRAMEROOT/Release-iphonesimulator/AWS.framework/AWS
lipo -info $FRAMEROOT/Debug-iphoneos/AWS.framework/AWS
lipo -info $FRAMEROOT/Debug-iphonesimulator/AWS.framework/AWS


## Special Note about AWSCore
## There is an identical copy in each $SOURCE, except Release-iphoneos
## There the two non-iOS architectures were removed using the following:
## lipo -remove i386 AWSCore.framework/AWSCore -o it
## mv it AWSCore.framework/AWSCore 
## clipo -remove x86_64 AWSCore.framework/AWSCore -o it
## mv it AWSCore.framework/AWSCore 
## lipo -info AWSCore.framework/AWSCore 
