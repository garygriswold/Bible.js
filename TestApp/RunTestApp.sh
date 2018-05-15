#!/bin/sh -ev

export IOS_DIR=TestAppIOS/TestAppIOS/www/
export AND_DIR=TestAppAndroid/app/src/main/assets/www/

rm -rf $IOS_DIR
rm -rf $AND_DIR

mkdir $IOS_DIR
mkdir $AND_DIR

mkdir $IOS_DIR/js
mkdir $AND_DIR/js

echo '"use strict";' > 			BibleApp.js
cat www/js/tester.js >> 		BibleApp.js
cat www/js/utility.js >>		BibleApp.js
cat www/js/sqlite.js >>			BibleApp.js
cat www/js/aws.js >>			BibleApp.js
#cat www/js/audioPlayer.js >>	BibleApp.js		
cat www/js/videoPlayer.js >>	BibleApp.js

cp BibleApp.js BibleAppIos.js
cat www/js/iosOnly.js >> 		BibleAppIos.js
mv BibleAppIos.js $IOS_DIR/js/BibleApp.js

cp BibleApp.js BibleAppAndroid.js
cat www/js/androidOnly.js >> 	BibleAppAndroid.js
mv BibleAppAndroid.js $AND_DIR/js/BibleApp.js

cp www/index.html $IOS_DIR
cp www/index.html $AND_DIR

cp www/Versions.db $IOS_DIR
cp www/Versions.db $AND_DIR

cp www/ERV-ENG.db $IOS_DIR
cp www/ERV-ENG.db $AND_DIR


