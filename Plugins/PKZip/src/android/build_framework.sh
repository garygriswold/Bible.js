#!/bin/sh -ve

LIBROOT=${HOME}/Library/Frameworks
DEBUG_ROOT=${LIBROOT}/Debug-android
RELSE_ROOT=${LIBROOT}/Release-android
JAR=Zip.jar

rm -f ${DEBUG_ROOT}/${JAR}
rm -f ${RELSE_ROOT}/${JAR}

./gradlew clean assemble check 

cp app/build/intermediates/bundles/debug/classes.jar ${DEBUG_ROOT}/${JAR}
cp app/build/intermediates/bundles/default/classes.jar ${RELSE_ROOT}/${JAR}

