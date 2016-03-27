This file contains notes of little got'yas found along the way.
It is here to help my weak memory, and others who might find it.
Gary Griswold

July 2, 2015
cordova run ios --device - produced an error as follows:
Unable to locate DeveloperDiskImage.dmg
It appears that it is expecting to find this in a directory called latest.  The solution is to create a symlink that defines latest.
cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport
sudo ln -s 8.1 ./Latest

Nov 29, 2015
Installed Beta version of WKWebView from Telerik
> cordova plugin add cordova-plugin-wkwebview --variable WKWEBVIEW_SERVER_PORT=12344
From: https://github.com/Telerik-Verified-Plugins/WKWebView
This change was essential to have smooth scrolling in ios, because UIWebView does not permit Javascript to execute while scrolling is happening, but this limitation was fixed in WKWebView, because it was otherwise much more efficient.