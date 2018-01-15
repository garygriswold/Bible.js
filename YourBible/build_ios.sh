#!/bin/sh -ev

# Usage build_ios.sh Release | Release-simulator | Debug | Debug-phone

LIBS=$HOME/Library/Frameworks

VIDEO=VideoPlayer.framework
AWS=AWS.framework
ZIP=PKZip.framework
AWSCORE=AWSCore.framework

PLUGINS=$HOME/ShortSands/BibleApp/YourBible/platforms/ios/SafeBible/Plugins

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

# Copy VideoPlayer.framework to SafeBible
TARGET=$PLUGINS/com-shortsands-videoplayer/$VIDEO
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$VIDEO $TARGET
lipo -info $TARGET/VideoPlayer

# Copy AWS.framework to SafeBible
TARGET=$PLUGINS/com-shortsands-aws/$AWS
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$AWS $TARGET
lipo -info $TARGET/AWS

# Copy AWSCore.framework to SafeBible
TARGET=$PLUGINS/com-shortsands-aws/$AWSCORE
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$AWSCORE $TARGET
lipo -info $TARGET/AWSCore

# Copy PKZip.framework to SafeBible
TARGET=$PLUGINS/com-shortsands-pkzip/$ZIP
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$ZIP $TARGET
lipo -info $TARGET/PKZip


## Special Note about AWSCore
## There is an identical copy in each $SOURCE, except Release-iphoneos
## There the two non-iOS architectures were removed using the following:
## lipo -remove i386 AWSCore.framework/AWSCore -o it
## mv it AWSCore.framework/AWSCore 
## clipo -remove x86_64 AWSCore.framework/AWSCore -o it
## mv it AWSCore.framework/AWSCore 
## lipo -info AWSCore.framework/AWSCore 

