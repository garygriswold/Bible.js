#!/bin/sh

cat ../Library/css/Codex.css > css/BibleApp.css
cat ../Library/css/Copyright.css >> css/BibleApp.css
cat ../Library/css/History.css >> css/BibleApp.css
cat ../Library/css/Questions.css >> css/BibleApp.css
cat ../Library/css/Search.css >> css/BibleApp.css
cat ../Library/css/Status.css >> css/BibleApp.css
cat ../Library/css/TableContents.css >> css/BibleApp.css
cat ../Library/css/Settings.css >> css/BibleApp.css
cat ../Library/css/Video.css >> css/BibleApp.css

echo \"use strict\"\; > js/BibleApp.js
# BuildInfo is a cordova plugin
echo var BuildInfo={version:\"unknown\"}\; >> js/BibleApp.js
cat ../Library/gui/AppInitializer.js >> js/BibleApp.js
cat ../Library/gui/AppViewController.js >> js/BibleApp.js
cat ../Library/gui/CodexView.js >> js/BibleApp.js
cat ../Library/gui/CopyrightView.js >> js/BibleApp.js
cat ../Library/gui/HistoryView.js >> js/BibleApp.js
cat ../Library/gui/QuestionsView.js >> js/BibleApp.js
cat ../Library/gui/SearchView.js >> js/BibleApp.js
cat ../Library/gui/HeaderView.js >> js/BibleApp.js
cat ../Library/gui/TableContentsView.js >> js/BibleApp.js
cat ../Library/gui/SettingsView.js >> js/BibleApp.js
cat ../Library/gui/VersionsView.js >> js/BibleApp.js
cat ../Library/gui/RateMeView.js >> js/BibleApp.js

cat ../Library/gui/icons/drawCloseIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawQuestionsIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawSearchIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawSendIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawSettingsIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawTOCIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/GSPreloader.js >> js/BibleApp.js
cat ../Library/gui/icons/StopIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawVideoIcon.js >> js/BibleApp.js

cat ../Library/io/IOError.js >> js/BibleApp.js
cat ../Library/io/SettingStorage.js >> js/BibleApp.js
cat ../Library/io/DatabaseHelperWebKit.js >> js/BibleApp.js
cat ../Library/io/ChaptersAdapter.js >> js/BibleApp.js
cat ../Library/io/VersesAdapter.js >> js/BibleApp.js
cat ../Library/io/ConcordanceAdapter.js >> js/BibleApp.js
cat ../Library/io/TableContentsAdapter.js >> js/BibleApp.js
cat ../Library/io/StyleIndexAdapter.js >> js/BibleApp.js
cat ../Library/io/StyleUseAdapter.js >> js/BibleApp.js
cat ../Library/io/HistoryAdapter.js >> js/BibleApp.js
cat ../Library/io/QuestionsAdapter.js >> js/BibleApp.js
cat ../Library/io/VersionsAdapter.js >> js/BibleApp.js
cat ../Library/io/HttpClient.js >> js/BibleApp.js
cat ../Library/io/AppUpdater.js >> js/BibleApp.js
cat ../Library/io/FileDownloader.js >> js/BibleApp.js

cat ../Library/model/meta/BibleVersion.js >> js/BibleApp.js
cat ../Library/model/meta/Concordance.js >> js/BibleApp.js
cat ../Library/model/meta/Lookup.js >> js/BibleApp.js
cat ../Library/model/meta/QuestionItem.js >> js/BibleApp.js
cat ../Library/model/meta/Questions.js >> js/BibleApp.js
cat ../Library/model/meta/Reference.js >> js/BibleApp.js
cat ../Library/model/meta/TOC.js >> js/BibleApp.js
cat ../Library/model/meta/TOCBook.js >> js/BibleApp.js

cat ../Library/util/DateTimeFormatter.js >> js/BibleApp.js
cat ../Library/util/LocalizeNumber.js >> js/BibleApp.js
cat ../Library/util/nodeDeviceSettings.js >> js/BibleApp.js
cat ../Library/util/Performance.js >> js/BibleApp.js
cat ../Library/util/DOMBuilder.js >> js/BibleApp.js
cat ../Library/util/DynamicCSS.js >> js/BibleApp.js

cat ../Library/video/VideoListView.js >> js/BibleApp.js
cat ../Library/video/VideoMetaData.js >> js/BibleApp.js
cat ../Library/video/VideoTableAdapter.js >> js/BibleApp.js

node ../Library/util/BibleAppConfigWriter.js js/BibleAppConfig.js

cd ../BibleAppNW
npm start
