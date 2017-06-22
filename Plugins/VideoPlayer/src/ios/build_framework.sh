#!/bin/sh -ve

FRAMEROOT=$HOME/Library/Frameworks
PROJROOT=$HOME/ShortSands/BibleApp/Plugins
TARGET=$PROJROOT/VideoPlayer/src/ios/VideoPlayer

ZIP=Zip.framework
AWS=AWS.framework

# Build iOS/Release
rm -f $TARGET/$ZIP
ln -s $FRAMEROOT/Release-iphoneos/$ZIP $TARGET/$ZIP
rm -f $TARGET/$AWS
ln -s $FRAMEROOT/Release-iphoneos/$AWS $TARGET/$AWS
xcodebuild -configuration Release -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build install 

# Build Simulator/Release
rm -f $TARGET/$ZIP
ln -s $FRAMEROOT/Release-iphonesimulator/$ZIP $TARGET/$ZIP
rm -f $TARGET/$AWS
ln -s $FRAMEROOT/Release-iphonesimulator/$AWS $TARGET/$AWS
xcodebuild -configuration Release -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build install

# Build iOS/Debug
rm -f $TARGET/$ZIP
ln -s $FRAMEROOT/Debug-iphoneos/$ZIP $TARGET/$ZIP
rm -f $TARGET/$AWS
ln -s $FRAMEROOT/Debug-iphoneos/$AWS $TARGET/$AWS
xcodebuild -configuration Debug -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build install 

# Build Simulator/Debug
rm -f $TARGET/$ZIP
ln -s $FRAMEROOT/Debug-iphonesimulator/$ZIP $TARGET/$ZIP
rm -f $TARGET/$AWS
ln -s $FRAMEROOT/Debug-iphonesimulator/$AWS $TARGET/$AWS
xcodebuild -configuration Debug -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build install

# Notice that Simulator/Debug is the last to process in order to leave Xcode in that mode.

# Link for Cordova VideoPlayer Plugin
VIDEO=VideoPlayer.framework
rm -f $TARGET/../build/$VIDEO
ln -s $FRAMEROOT/Debug-iphonesimulator/$VIDEO $TARGET/../build/$VIDEO




