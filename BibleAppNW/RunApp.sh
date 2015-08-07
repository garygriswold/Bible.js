#!/bin/sh
cat ../Library/css/Codex.css > css/BibleApp.css
cat ../Library/css/History.css >> css/BibleApp.css
cat ../Library/css/Questions.css >> css/BibleApp.css
cat ../Library/css/Search.css >> css/BibleApp.css
cat ../Library/css/Status.css >> css/BibleApp.css
cat ../Library/css/TableContents.css >> css/BibleApp.css

echo \"use strict\"\; > js/BibleApp.js
cat ../Library/gui/AppViewController.js >> js/BibleApp.js
cat ../Library/gui/CodexView.js >> js/BibleApp.js
cat ../Library/gui/HistoryView.js >> js/BibleApp.js
cat ../Library/gui/QuestionsView.js >> js/BibleApp.js
cat ../Library/gui/SearchView.js >> js/BibleApp.js
cat ../Library/gui/HeaderView.js >> js/BibleApp.js
cat ../Library/gui/TableContentsView.js >> js/BibleApp.js

cat ../Library/gui/icons/drawQuestionsIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawSearchIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawSendIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawSettingsIcon.js >> js/BibleApp.js
cat ../Library/gui/icons/drawTOCIcon.js >> js/BibleApp.js

cat ../Library/io/IOError.js >> js/BibleApp.js
cat ../Library/io/DeviceDatabaseWebSQL.js >> js/BibleApp.js
cat ../Library/io/ChaptersAdapter.js >> js/BibleApp.js
cat ../Library/io/VersesAdapter.js >> js/BibleApp.js
cat ../Library/io/ConcordanceAdapter.js >> js/BibleApp.js
cat ../Library/io/TableContentsAdapter.js >> js/BibleApp.js
cat ../Library/io/StyleIndexAdapter.js >> js/BibleApp.js
cat ../Library/io/StyleUseAdapter.js >> js/BibleApp.js
cat ../Library/io/HistoryAdapter.js >> js/BibleApp.js
cat ../Library/io/QuestionsAdapter.js >> js/BibleApp.js

cat ../Library/model/meta/BibleCache.js >> js/BibleApp.js
cat ../Library/model/meta/Canon.js >> js/BibleApp.js
cat ../Library/model/meta/Concordance.js >> js/BibleApp.js
cat ../Library/model/meta/Lookup.js >> js/BibleApp.js
cat ../Library/model/meta/QuestionItem.js >> js/BibleApp.js
cat ../Library/model/meta/Questions.js >> js/BibleApp.js
cat ../Library/model/meta/Reference.js >> js/BibleApp.js
cat ../Library/model/meta/TOC.js >> js/BibleApp.js
cat ../Library/model/meta/TOCBook.js >> js/BibleApp.js

cat ../Library/model/usx/Book.js >> js/BibleApp.js
cat ../Library/model/usx/Chapter.js >> js/BibleApp.js
cat ../Library/model/usx/Char.js >> js/BibleApp.js
cat ../Library/model/usx/Note.js >> js/BibleApp.js
cat ../Library/model/usx/Para.js >> js/BibleApp.js
cat ../Library/model/usx/Text.js >> js/BibleApp.js
cat ../Library/model/usx/USX.js >> js/BibleApp.js
cat ../Library/model/usx/Verse.js >> js/BibleApp.js

cat ../Library/util/DateTimeFormatter.js >> js/BibleApp.js
cat ../Library/util/nodeDeviceSettings.js >> js/BibleApp.js
cat ../Library/util/Performance.js >> js/BibleApp.js

cat ../Library/xml/USXParser.js >> js/BibleApp.js
cat ../Library/xml/XMLTokenizer.js >> js/BibleApp.js

cd ../BibleAppNW
npm start
