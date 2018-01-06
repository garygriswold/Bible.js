#!/bin/sh -ve

FRAMEROOT=$HOME/Library/Frameworks
PROJROOT=$HOME/ShortSands/BibleApp/Plugins
TARGET=$PROJROOT/PKZip/src/ios/Zip

# Build iOS/Release
xcodebuild -configuration Release -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build

# Build Simulator/Release
xcodebuild -configuration Release -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build

# Build iOS/Debug
xcodebuild -configuration Debug -sdk iphoneos SYMROOT="$FRAMEROOT" BITCODE_GENERATION_MODE=bitcode clean build

# Build Simulator/Debug
xcodebuild -configuration Debug -sdk iphonesimulator SYMROOT="$FRAMEROOT" clean build

# Notice that Simulator/Debug is the last to process in order to leave Xcode in that mode.

# Copy Framework for Cordova PKZip Plugin
ZIP=Zip.framework
rm -rf $TARGET/../build/$ZIP
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$ZIP $TARGET/../build/

# Copy Framework to AWS Plugin
DEST=$PROJROOT/AWS/src/ios/AWS/$ZIP
rm -rf $DEST
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$ZIP $DEST

# Copy Framework to VideoPlayer Plugin
DEST=$PROJROOT/VideoPlayer/src/ios/VideoPlayer/$ZIP
rm -rf $DEST
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$ZIP $DEST

# Copy Framework to AudioPlayer Plugin
DEST=$PROJROOT/AudioPlayer/src/ios_AudioPlayer/AudioPlayer/$ZIP
rm -rf $DEST
cp -Rp $FRAMEROOT/Debug-iphonesimulator/$ZIP $DEST

# Lipo info commands
lipo -info $FRAMEROOT/Release-iphoneos/Zip.framework/Zip
lipo -info $FRAMEROOT/Release-iphonesimulator/Zip.framework/Zip
lipo -info $FRAMEROOT/Debug-iphoneos/Zip.framework/Zip
lipo -info $FRAMEROOT/Debug-iphonesimulator/Zip.framework/Zip
