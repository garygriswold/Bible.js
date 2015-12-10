#!/bin/sh
cat ../Library/css/Codex.css > www/css/BibleApp.css
cat ../Library/css/History.css >> www/css/BibleApp.css
cat ../Library/css/Questions.css >> www/css/BibleApp.css
cat ../Library/css/Search.css >> www/css/BibleApp.css
cat ../Library/css/Status.css >> www/css/BibleApp.css
cat ../Library/css/TableContents.css >> www/css/BibleApp.css
cat ../Library/css/Settings.css >> www/css/BibleApp.css

echo \"use strict\"\; > www/js/BibleApp.js
cat ../Library/gui/AppViewController.js >> www/js/BibleApp.js
cat ../Library/gui/CodexView.js >> www/js/BibleApp.js
cat ../Library/gui/HistoryView.js >> www/js/BibleApp.js
cat ../Library/gui/QuestionsView.js >> www/js/BibleApp.js
cat ../Library/gui/SearchView.js >> www/js/BibleApp.js
cat ../Library/gui/HeaderView.js >> www/js/BibleApp.js
cat ../Library/gui/TableContentsView.js >> www/js/BibleApp.js
cat ../Library/gui/SettingsView.js >> www/js/BibleApp.js
cat ../Library/gui/VersionsView.js >> www/js/BibleApp.js
cat ../Library/gui/DOMBuilder.js >> www/js/BibleApp.js

cat ../Library/gui/icons/drawQuestionsIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawSearchIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawSendIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawSettingsIcon.js >> www/js/BibleApp.js
cat ../Library/gui/icons/drawTOCIcon.js >> www/js/BibleApp.js

cat ../Library/io/IOError.js >> www/js/BibleApp.js
cat ../Library/io/DeviceDatabaseWebSQL.js >> www/js/BibleApp.js
cat ../Library/io/ChaptersAdapter.js >> www/js/BibleApp.js
cat ../Library/io/VersesAdapter.js >> www/js/BibleApp.js
cat ../Library/io/ConcordanceAdapter.js >> www/js/BibleApp.js
cat ../Library/io/TableContentsAdapter.js >> www/js/BibleApp.js
cat ../Library/io/StyleIndexAdapter.js >> www/js/BibleApp.js
cat ../Library/io/StyleUseAdapter.js >> www/js/BibleApp.js
cat ../Library/io/HistoryAdapter.js >> www/js/BibleApp.js
cat ../Library/io/QuestionsAdapter.js >> www/js/BibleApp.js
cat ../Library/io/VersionsAdapter.js >> www/js/BibleApp.js
cat ../Library/io/FileDownloader.js >> www/js/BibleApp.js
cat ../Library/io/HttpClient.js >> www/js/BibleApp.js

##cat ../Library/manufacture/DOMBuilder.js >> www/js/BibleApp.js

cat ../Library/model/meta/BibleCache.js >> www/js/BibleApp.js
cat ../Library/model/meta/Canon.js >> www/js/BibleApp.js
cat ../Library/model/meta/Concordance.js >> www/js/BibleApp.js
cat ../Library/model/meta/Lookup.js >> www/js/BibleApp.js
cat ../Library/model/meta/QuestionItem.js >> www/js/BibleApp.js
cat ../Library/model/meta/Questions.js >> www/js/BibleApp.js
cat ../Library/model/meta/Reference.js >> www/js/BibleApp.js
cat ../Library/model/meta/TOC.js >> www/js/BibleApp.js
cat ../Library/model/meta/TOCBook.js >> www/js/BibleApp.js

cat ../Library/model/usx/Book.js >> www/js/BibleApp.js
cat ../Library/model/usx/Chapter.js >> www/js/BibleApp.js
cat ../Library/model/usx/Char.js >> www/js/BibleApp.js
cat ../Library/model/usx/Note.js >> www/js/BibleApp.js
cat ../Library/model/usx/Para.js >> www/js/BibleApp.js
cat ../Library/model/usx/Text.js >> www/js/BibleApp.js
cat ../Library/model/usx/USX.js >> www/js/BibleApp.js
cat ../Library/model/usx/Verse.js >> www/js/BibleApp.js

cat ../Library/util/DateTimeFormatter.js >> www/js/BibleApp.js
cat ../Library/util/cordovaDeviceSettings.js >> www/js/BibleApp.js

cat ../Library/xml/USXParser.js >> www/js/BibleApp.js
cat ../Library/xml/XMLTokenizer.js >> www/js/BibleApp.js

cordova run ios --device
