#!/bin/sh

export SOURCE_SM=Bible_blue_128.png
export SOURCE_LG=Bible_blue_512.png
export IOS_TARGET=../platforms/ios/Bible.js/Resources/icons
export AND_TARGET=../platforms/android/res

convert $SOURCE_SM -resize 40x40 	$IOS_TARGET/icon-40.png
convert $SOURCE_SM -resize 80x80 	$IOS_TARGET/icon-40@2x.png
convert $SOURCE_SM -resize 50x50 	$IOS_TARGET/icon-50.png
convert $SOURCE_SM -resize 100x100	$IOS_TARGET/icon-50@2x.png
convert $SOURCE_SM -resize 60x60 	$IOS_TARGET/icon-60.png
convert $SOURCE_SM -resize 120x120 	$IOS_TARGET/icon-60@2x.png
convert $SOURCE_LG -resize 180x180	$IOS_TARGET/icon-60@3x.png
convert $SOURCE_SM -resize 72x72 	$IOS_TARGET/icon-72.png
convert $SOURCE_SM -resize 144x144 	$IOS_TARGET/icon-72@2x.png
convert $SOURCE_SM -resize 76x76 	$IOS_TARGET/icon-76.png
convert $SOURCE_SM -resize 152x152 	$IOS_TARGET/icon-76@2x.png
convert $SOURCE_SM -resize 29x29 	$IOS_TARGET/small.png
convert $SOURCE_SM -resize 58x58 	$IOS_TARGET/small@2x.png
convert $SOURCE_SM -resize 57x57 	$IOS_TARGET/icon.png
convert $SOURCE_SM -resize 114x114 	$IOS_TARGET/icon@2x.png

#convert $SOURCE_SM -resize 96x96	$AND_TARGET/drawable/icon.png
convert $SOURCE_SM -resize 72x72	$AND_TARGET/drawable-hdpi/icon.png
convert $SOURCE_SM -resize 36x36	$AND_TARGET/drawable-ldpi/icon.png
convert $SOURCE_SM -resize 48x48	$AND_TARGET/drawable-mdpi/icon.png
convert $SOURCE_SM -resize 96x96	$AND_TARGET/drawable-xhdpi/icon.png
