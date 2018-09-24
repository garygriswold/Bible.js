#!/bin/sh -ve

LIBROOT=${HOME}/Library/Frameworks
DEBUG_ROOT=${LIBROOT}/Debug-android
RELSE_ROOT=${LIBROOT}/Release-android
JAR=Utility.jar

rm -f ${DEBUG_ROOT}/${JAR}
rm -f ${RELSE_ROOT}/${JAR}

./gradlew clean assemble check 

# Copy Jars to Frameworks
cp app/build/intermediates/bundles/debug/classes.jar ${DEBUG_ROOT}/${JAR}
cp app/build/intermediates/bundles/release/classes.jar ${RELSE_ROOT}/${JAR}

# Copy Debug Jar to this project plugin 
cp ${DEBUG_ROOT}/${JAR} plugin 

# Copy Debug Jar to AWS project libs
cp ${DEBUG_ROOT}/${JAR} ../../../AWS/src/android/app/libs/

# Copy Debug Jar to AudioPlayer project libs
cp ${DEBUG_ROOT}/${JAR} ../../../AudioPlayer/src/android/app/libs/

