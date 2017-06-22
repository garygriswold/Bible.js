#!/bin/sh -ve

FRAMEROOT=$HOME/Library/Frameworks
PROJROOT=$HOME/ShortSands/BibleApp/Plugins
TARGET=$PROJROOT/PKZip/src/ios/Zip

# Build iOS/Release
xcodebuild -configuration Release -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build install 

# Build Simulator/Release
xcodebuild -configuration Release -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build install

# Build iOS/Debug
xcodebuild -configuration Debug -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build install 

# Build Simulator/Debug
xcodebuild -configuration Debug -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build install

# Notice that Simulator/Debug is the last to process in order to leave Xcode in that mode.

# Copy Framework for Cordova PKZip Plugin
ZIP=Zip.framework
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$ZIP $TARGET/../build/

