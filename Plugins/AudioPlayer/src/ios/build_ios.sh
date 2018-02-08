#!/bin/sh -ev

# Usage build_ios.sh Release | Release-simulator | Debug | Debug-phone

LIBS=$HOME/Library/Frameworks

AWS=AWS.framework
ZIP=PKZip.framework
AWSCORE=AWSCore.framework

PLUGINS=$HOME/ShortSands/BibleApp/Plugins/AudioPlayer/src/ios/AudioPlayer


if [ "$1" == "Release" ]; then
	SOURCE=$LIBS/Release-iphoneos
elif [ "$1" == "Release-simulator" ]; then
	SOURCE=$LIBS/Release-iphonesimulator
elif [ "$1" == "Debug" ]; then
	SOURCE=$LIBS/Debug-iphonesimulator
elif [ "$1" == "Debug-phone" ]; then
	SOURCE=$LIBS/Debug-iphoneos
else
	echo "Usage: build_ios.sh Release | Release-simulator | Debug | Debug-phone"
	exit 1
fi
echo $SOURCE

# Copy AWS.framework
TARGET=$PLUGINS/$AWS
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$AWS $TARGET
lipo -info $TARGET/AWS

# Copy AWSCore.framework
TARGET=$PLUGINS/$AWSCORE
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$AWSCORE $TARGET
lipo -info $TARGET/AWSCore

# Copy Zip.framework
TARGET=$PLUGINS/$ZIP
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$ZIP $TARGET
lipo -info $TARGET/PKZip



