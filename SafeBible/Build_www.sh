#!/bin/sh -ve

export IOS_DIR=SafeBible_iOS/SafeBible/www
#export AND_DIR=SafeBible_Android/app/src/main/assets/www

node ../Library/util/BibleAppConfigWriter.js www/js/BibleAppConfig.js

cat ../Library/css/Status.css > www/css/BibleApp.css
cat ../Library/css/Codex.css >> www/css/BibleApp.css
cat ../Library/css/Copyright.css >> www/css/BibleApp.css
cat ../Library/css/History.css >> www/css/BibleApp.css
cat ../Library/css/Questions.css >> www/css/BibleApp.css
cat ../Library/css/Search.css >> www/css/BibleApp.css
cat ../Library/css/TableContents.css >> www/css/BibleApp.css
cat ../Library/css/Settings.css >> www/css/BibleApp.css
cat ../Library/css/Video.css >> www/css/BibleApp.css

echo \"use strict\"\; > www/js/BibleApp.js
cat ../Library/gui/AppInitializer.js >> www/js/BibleApp.js
cat ../Library/gui/AppViewController.js >> www/js/BibleApp.js
cat ../Library/gui/CodexView.js >> www/js/BibleApp.js
cat ../Library/gui/CopyrightView.js >> www/js/BibleApp.js
cat ../Library/gui/HistoryView.js >> www/js/BibleApp.js
cat ../Library/gui/QuestionsView.js >> www/js/BibleApp.js
cat ../Library/gui/SearchView.js >> www/js/BibleApp.js
cat ../Library/gui/HeaderView.js >> www/js/BibleApp.js
cat ../Library/gui/TableContentsView.js >> www/js/BibleApp.js
cat ../Library/gui/SettingsView.js >> www/js/BibleApp.js
cat ../Library/gui/VersionsView.js >> www/js/BibleApp.js
cat ../Library/gui/RateMeView.js >> www/js/BibleApp.js

cat ../Library/gui/icons/drawCloseIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawQuestionsIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawSearchIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawSendIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawSettingsIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawTOCIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/GSPreloader.js >> www/js/BibleApp.js
cat ../Library/gui/icons/StopIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawVideoIcon.js >> www/js/BibleApp.js

cat ../Library/io/IOError.js >> www/js/BibleApp.js
cat ../Library/io/SettingStorage.js >> www/js/BibleApp.js
cat ../Library/io/DatabaseHelper.js >> www/js/BibleApp.js
cat ../Library/io/ChaptersAdapter.js >> www/js/BibleApp.js
cat ../Library/io/VersesAdapter.js >> www/js/BibleApp.js
cat ../Library/io/ConcordanceAdapter.js >> www/js/BibleApp.js
cat ../Library/io/TableContentsAdapter.js >> www/js/BibleApp.js
cat ../Library/io/HistoryAdapter.js >> www/js/BibleApp.js
cat ../Library/io/QuestionsAdapter.js >> www/js/BibleApp.js
cat ../Library/io/VersionsAdapter.js >> www/js/BibleApp.js
cat ../Library/io/HttpClient.js >> www/js/BibleApp.js
cat ../Library/io/AppUpdater.js >> www/js/BibleApp.js
cat ../Library/io/FileDownloader.js >> www/js/BibleApp.js

cat ../Library/model/meta/BibleVersion.js >> www/js/BibleApp.js
cat ../Library/model/meta/Concordance.js >> www/js/BibleApp.js
cat ../Library/model/meta/Lookup.js >> www/js/BibleApp.js
cat ../Library/model/meta/QuestionItem.js >> www/js/BibleApp.js
cat ../Library/model/meta/Questions.js >> www/js/BibleApp.js
cat ../Library/model/meta/Reference.js >> www/js/BibleApp.js
cat ../Library/model/meta/TOC.js >> www/js/BibleApp.js
cat ../Library/model/meta/TOCBook.js >> www/js/BibleApp.js

cat ../Library/util/DateTimeFormatter.js >> www/js/BibleApp.js
cat ../Library/util/LocalizeNumber.js >> www/js/BibleApp.js
cat ../Library/util/cordovaDeviceSettings.js >> www/js/BibleApp.js
cat ../Library/util/DOMBuilder.js >> www/js/BibleApp.js
cat ../Library/util/DynamicCSS.js >> www/js/BibleApp.js

cat ../Library/video/VideoListView.js >> www/js/BibleApp.js
cat ../Library/video/VideoMetaData.js >> www/js/BibleApp.js
cat ../Library/video/VideoTableAdapter.js >> www/js/BibleApp.js

rm -rf $IOS_DIR
#rm -rf $AND_DIR

cp -R www $IOS_DIR
#cp -R www $AND_DIR

echo \"use strict\"\; > /tmp/callNativeiOS.js
cat ../Library/native/callNative.js >> /tmp/callNativeiOS.js
cat ../Library/native/iosOnly.js >> /tmp/callNativeiOS.js
cp /tmp/callNativeiOS.js $IOS_DIR/js/CallNative.js

#echo \"use strict\"\; > /tmp/callNativeAndroid.js
#cat ../Library/native/callNative.js >> /tmp/callNativeAndroid.js
#cat ../Library/native/androidOnly.js >> /tmp/callNativeAndroid.js
#cp /tmp/callNativeAndroid.js $AND_DIR/js/CallNative.js


