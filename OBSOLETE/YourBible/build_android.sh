#!/bin/sh -ev

# Usage build_android.sh Release | Debug

LIBS=$HOME/Library/Frameworks

VIDEO=VideoPlayer.jar
AWS=AWS.jar
ZIP=PKZip.jar

PLUGINS=$HOME/ShortSands/BibleApp/YourBible/platforms/android/libs

if [ "$1" == "Release" ]; then
	SOURCE=$LIBS/Release-android
elif [ "$1" == "Debug" ]; then
	SOURCE=$LIBS/Debug-android
else
	echo "Usage: build_android.sh Release | Debug"
	exit 1
fi
echo $SOURCE

# Copy VideoPlayer.jar to SafeBible
TARGET=$PLUGINS/$VIDEO
echo $TARGET
#rm -f $TARGET
cp -f $SOURCE/$VIDEO $TARGET

# Copy AWS.jar to SafeBible
TARGET=$PLUGINS/$AWS
echo $TARGET
#rm -rf $TARGET
cp -f $SOURCE/$AWS $TARGET

## Copy PKZip.framework to SafeBible
TARGET=$PLUGINS/$ZIP
echo $TARGET
#rm -rf $TARGET
cp -f $SOURCE/$ZIP $TARGET
