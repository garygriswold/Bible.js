#!/bin/sh

#export SOURCE_SM=Bible_blue_128.png
#export SOURCE_LG=Bible_blue_512.png
export SOURCE=icon2.png
export IOS_TARGET=../ios/icons
export AND_TARGET=../android/icons

convert $SOURCE -resize 180x180	$IOS_TARGET/icon-60@3x.png
convert $SOURCE -resize 60x60 	$IOS_TARGET/icon-60.png
convert $SOURCE -resize 120x120 	$IOS_TARGET/icon-60@2x.png
convert $SOURCE -resize 76x76 	$IOS_TARGET/icon-76.png
convert $SOURCE -resize 152x152 	$IOS_TARGET/icon-76@2x.png
convert $SOURCE -resize 40x40 	$IOS_TARGET/icon-40.png
convert $SOURCE -resize 80x80 	$IOS_TARGET/icon-40@2x.png
convert $SOURCE -resize 57x57    $IOS_TARGET/icon.png
convert $SOURCE -resize 114x114  $IOS_TARGET/icon@2x.png
convert $SOURCE -resize 72x72 	$IOS_TARGET/icon-72.png
convert $SOURCE -resize 144x144 	$IOS_TARGET/icon-72@2x.png
convert $SOURCE -resize 29x29    $IOS_TARGET/icon-small.png
convert $SOURCE -resize 58x58    $IOS_TARGET/icon-small@2x.png
convert $SOURCE -resize 50x50 	$IOS_TARGET/icon-50.png
convert $SOURCE -resize 100x100	$IOS_TARGET/icon-50@2x.png


convert $SOURCE -resize 36x36	$AND_TARGET/ldpi.png
convert $SOURCE -resize 48x48	$AND_TARGET/mdpi.png
convert $SOURCE -resize 72x72	$AND_TARGET/hdpi.png
convert $SOURCE -resize 96x96	$AND_TARGET/xhdpi.png
convert $SOURCE -resize 144x144  $AND_TARGET/xxhdpi.png
convert $SOURCE -resize 192x192  $AND_TARGET/xxxhdpi.png
