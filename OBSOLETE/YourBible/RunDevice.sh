#!/bin/sh -ev

./build_js.sh

if [ -z "$1" ]; then
	cordova run ios --device
else
	cordova run $1 --device
fi

