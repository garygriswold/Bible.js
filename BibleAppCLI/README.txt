This file contains notes of little got'yas found along the way.
It is here to help my weak memory, and others who might find it.
Gary Griswold

July 2, 2015
cordova run ios --device - produced an error as follows:
Unable to locate DeveloperDiskImage.dmg
It appears that it is expecting to find this in a directory called latest.  The solution is to create a symlink that defines latest.
cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport
sudo ln -s 8.1 ./Latest