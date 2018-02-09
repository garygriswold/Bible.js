This plugin has been removed from the build as of Feb 8, 2018 by GNG.  This module had been 
a framework build, but something changed in XCode so that the command line xcodebuild script 
that I used was no longer working.  I tried to change it into a Cordova plugin which loaded 
files and not a framework, but I did not get this working because I did not know how to correctly
load a directory of C files into a Cordova plugin.

This code was not actually being used when it was removed.  It was used by one method in the
AWS class AwsS3, but that method has been commented out.  The method was to unzip a file
immediately upon download using the PKZip algorithm.  The production App currently downloads
files using the file-transfer plugin and unzips them with a Zip plugin.  It would be add
reliability to change that download to use the AWS module's TransferUtility, and this Zip 
package was intended to support this.

Although, it would really be better to use a builtin AWS unzip utility if they were to 
provide one.  They do currently have a gunzip feature, but I did not think it would work
with downloaded files.

Before resurrecting this plugin make sure that AWS has not provided an unzip feature that
could be used in conjunction with AWS S3 TransferUtility.  That would be preferable, or a 
a built-in iOS library based upon zlib or something else would also be better.



![Zip - Zip and unzip files in Swift](https://cloud.githubusercontent.com/assets/889949/12374908/252373d0-bcac-11e5-8ece-6933aeae8222.png)

[![Build Status](https://travis-ci.org/marmelroy/Zip.svg?branch=master)](https://travis-ci.org/marmelroy/Zip) [![Version](http://img.shields.io/cocoapods/v/Zip.svg)](http://cocoapods.org/?q=Zip)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Zip
A Swift 3.0 framework for zipping and unzipping files. Simple and quick to use. Built on top of [minizip](https://github.com/nmoinvaz/minizip).

## Usage

Import Zip at the top of the Swift file.

```swift
import Zip
```

## Quick functions

The easiest way to use Zip is through quick functions. Both take local file paths as NSURLs, throw if an error is encountered and return an NSURL to the destination if successful.
```swift
do {
    let filePath = Bundle.main.url(forResource: "file", withExtension: "zip")!
    let unzipDirectory = try Zip.quickUnzipFile(filePath) // Unzip
    let zipFilePath = try Zip.quickZipFiles([filePath], fileName: "archive") // Zip
}
catch {
  print("Something went wrong")
}
```

## Advanced Zip

For more advanced usage, Zip has functions that let you set custom  destination paths, work with password protected zips and use a progress handling closure. These functions throw if there is an error but don't return.
```swift
do {
    let filePath = Bundle.main.url(forResource: "file", withExtension: "zip")!
    let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
    try Zip.unzipFile(filePath, destination: documentsDirectory, overwrite: true, password: "password", progress: { (progress) -> () in
        print(progress)
    }) // Unzip

    let zipFilePath = documentsFolder.appendingPathComponent("archive.zip")
    try Zip.zipFiles([filePath], zipFilePath: zipFilePath, password: "password", progress: { (progress) -> () in
        print(progress)
    }) //Zip

}
catch {
  print("Something went wrong")
}
```

## Custom File Extensions

Zip supports '.zip' and '.cbz' files out of the box. To support additional zip-derivative file extensions:
```
Zip.addCustomFileExtension("file-extension-here")
```

### Setting up with [CocoaPods](http://cocoapods.org/?q=Zip)
```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'Zip', '~> 0.7'
```

### Setting up with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Zip into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "marmelroy/Zip"
```
