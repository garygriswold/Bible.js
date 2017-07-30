#!/bin/sh -ve

FRAMEROOT=$HOME/Library/Frameworks
PROJROOT=$HOME/ShortSands/BibleApp/Plugins
TARGET=$PROJROOT/VideoPlayer/src/ios/VideoPlayer

ZIP=Zip.framework
AWS=AWS.framework

# Build iOS/Release
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Release-iphoneos/$ZIP $TARGET/
rm -rf $TARGET/$AWS
cp -Rp $FRAMEROOT/Release-iphoneos/$AWS $TARGET/
xcodebuild -configuration Release -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build

# Build Simulator/Release
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Release-iphonesimulator/$ZIP $TARGET/
rm -rf $TARGET/$AWS
cp -Rp $FRAMEROOT/Release-iphonesimulator/$AWS $TARGET/
xcodebuild -configuration Release -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build

# Build iOS/Debug
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Debug-iphoneos/$ZIP $TARGET/
rm -rf $TARGET/$AWS
cp -Rp $FRAMEROOT/Debug-iphoneos/$AWS $TARGET/
xcodebuild -configuration Debug -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build

# Build Simulator/Debug
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$ZIP $TARGET/
rm -rf $TARGET/$AWS
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$AWS $TARGET/
xcodebuild -configuration Debug -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build

# Notice that Simulator/Debug is the last to process in order to leave Xcode in that mode.

# Link for Cordova VideoPlayer Plugin
VIDEO=VideoPlayer.framework
rm -rf $TARGET/../build/$VIDEO
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$VIDEO $TARGET/../build/

# Lipo info commands
lipo -info $FRAMEROOT/Release-iphoneos/VideoPlayer.framework/VideoPlayer
lipo -info $FRAMEROOT/Release-iphonesimulator/VideoPlayer.framework/VideoPlayer
lipo -info $FRAMEROOT/Debug-iphoneos/VideoPlayer.framework/VideoPlayer
lipo -info $FRAMEROOT/Debug-iphonesimulator/VideoPlayer.framework/VideoPlayer




