#!/bin/sh -ve

./build_js.sh

if [ -z "$1" ]; then
	cordova emulate ios 
else
	cordova emulate $1 
fi
