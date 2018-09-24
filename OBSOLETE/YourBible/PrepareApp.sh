#!/bin/sh

./build_js.sh

if [ -z "$1" ]; then
	cordova prepare ios 
else
	cordova prepare $1 
fi
