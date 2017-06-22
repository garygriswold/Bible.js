#!/bin/sh -ve

FRAMEROOT=$HOME/Library/Frameworks
PROJROOT=$HOME/ShortSands/BibleApp/Plugins
TARGET=$PROJROOT/AWS/src/ios/AWS

ZIP=Zip.framework

# Build iOS/Release
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Release-iphoneos/$ZIP $TARGET/
xcodebuild -configuration Release -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build install 

# Build Simulator/Release
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Release-iphonesimulator/$ZIP $TARGET/
xcodebuild -configuration Release -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build install

# Build iOS/Debug
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Debug-iphoneos/$ZIP $TARGET/
xcodebuild -configuration Debug -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build install 

# Build Simulator/Debug
rm -rf $TARGET/$ZIP
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$ZIP $TARGET/
xcodebuild -configuration Debug -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build install

# Notice that Simulator/Debug is the last to process in order to leave Xcode in that mode.

# Copy Framework for Cordova AWS Plugin
AWS=AWS.framework
rm -rf $TARGET/../build/$AWS
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$AWS $TARGET/../build/

