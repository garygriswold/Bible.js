#!/bin/sh -ve

xcodebuild -version

xcodebuild -showsdks

xcodebuild -list -project PKZip/src/ios/Zip.xcodeproj

xcodebuild -list -project AWS/src/ios/AWS.xcodeproj

xcodebuild -list -project VideoPlayer/src/ios/VideoPlayer.xcodeproj

