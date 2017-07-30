#!/bin/sh -ev

# Usage build_ios.sh Release | Release-simulator | Debug | Debug-phone

LIBS=$HOME/Library/Frameworks

VIDEO=VideoPlayer.framework
AWS=AWS.framework
ZIP=Zip.framework
AWSCORE=AWSCore.framework

PLUGINS=$HOME/ShortSands/BibleApp/Plugins


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

# Copy VideoPlayer.framework to it's own build
TARGET=$PLUGINS/VideoPlayer/src/ios/build/$VIDEO
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$VIDEO $TARGET
lipo -info $TARGET/VideoPlayer

# Copy AWS.framework to VideoPlayer
TARGET=$PLUGINS/VideoPlayer/src/ios/VideoPlayer/$AWS
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$AWS $TARGET
lipo -info $TARGET/AWS

# Copy Zip.framework to VideoPlayer
TARGET=$PLUGINS/VideoPlayer/src/ios/VideoPlayer/$ZIP
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$ZIP $TARGET
lipo -info $TARGET/Zip

# Copy AWS.framework to it's own build
TARGET=$PLUGINS/AWS/src/ios/build/$AWS
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$AWS $TARGET
lipo -info $TARGET/AWS

# Copy Zip.framework to AWS
TARGET=$PLUGINS/AWS/src/ios/AWS/$ZIP
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$ZIP $TARGET
lipo -info $TARGET/Zip

# Copy Zip.framework to it's own build
TARGET=$PLUGINS/PKZip/src/ios/build/$ZIP
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$ZIP $TARGET
lipo -info $TARGET/Zip

# Copy AWSCore.framework to AWS
TARGET=$PLUGINS/AWS/src/ios/AWS/$AWSCORE
echo $TARGET
rm -rf $TARGET
cp -Rf $SOURCE/$AWSCORE $TARGET
lipo -info $TARGET/AWSCore


## Special Note about AWSCore
## There is an identical copy in each $SOURCE, except Release-iphoneos
## There the two non-iOS architectures were removed using the following:
## lipo -remove i386 AWSCore.framework/AWSCore -o it
## mv it AWSCore.framework/AWSCore 
## clipo -remove x86_64 AWSCore.framework/AWSCore -o it
## mv it AWSCore.framework/AWSCore 
## lipo -info AWSCore.framework/AWSCore 

