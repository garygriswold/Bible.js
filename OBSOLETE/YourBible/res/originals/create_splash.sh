#!/bin/sh

export SOURCE_PORT=splash-port.png
export SOURCE_LAND=splash-land.png
export IOS_TARGET=../ios/splash
export AND_TARGET=../android/splash

convert $SOURCE_PORT -resize 320x480\! 	$IOS_TARGET/Default~iphone.png
convert $SOURCE_PORT -resize 640x960\! 	$IOS_TARGET/Default@2x~iphone.png
convert $SOURCE_PORT -resize 768x1024\! 	$IOS_TARGET/Default-Portrait~ipad.png
convert $SOURCE_PORT -resize 1536x2048\! $IOS_TARGET/Default-Portrait@2x~ipad.png
convert $SOURCE_LAND -resize 1024x768\! 	$IOS_TARGET/Default-Landscape~ipad.png
convert $SOURCE_LAND -resize 2048x1536\! $IOS_TARGET/Default-Landscape@2x~ipad.png
convert $SOURCE_PORT -resize 640x1136\! 	$IOS_TARGET/Default-568h@2x~iphone.png
convert $SOURCE_PORT -resize 750x1334\! 	$IOS_TARGET/Default-667h.png
convert $SOURCE_PORT -resize 1242x2208\! $IOS_TARGET/Default-736h.png
convert $SOURCE_LAND -resize 2208x1242\! $IOS_TARGET/Default-Landscape-736h.png

convert $SOURCE_LAND -resize 800x480\!	$AND_TARGET/land-hdpi.png
convert $SOURCE_LAND -resize 320x200\!	$AND_TARGET/land-ldpi.png
convert $SOURCE_LAND -resize 480x320\!	$AND_TARGET/land-mdpi.png
convert $SOURCE_LAND -resize 1280x720\!	$AND_TARGET/land-xhdpi.png

convert $SOURCE_PORT -resize 480x800\!	$AND_TARGET/port-hdpi.png
convert $SOURCE_PORT -resize 200x320\!	$AND_TARGET/port-ldpi.png
convert $SOURCE_PORT -resize 320x480\!	$AND_TARGET/port-mdpi.png
convert $SOURCE_PORT -resize 720x1280\!	$AND_TARGET/port-xhdpi.png
