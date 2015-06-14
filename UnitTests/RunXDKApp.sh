#!/bin/sh
cat ../Library/css/Codex.css > ../BibleAppXDK/www/css/BibleApp.css
cat ../Library/css/History.css >> ../BibleAppXDK/www/css/BibleApp.css
cat ../Library/css/Questions.css >> ../BibleAppXDK/www/css/BibleApp.css
cat ../Library/css/Search.css >> ../BibleAppXDK/www/css/BibleApp.css
cat ../Library/css/Status.css >> ../BibleAppXDK/www/css/BibleApp.css
cat ../Library/css/TableContents.css >> ../BibleAppXDK/www/css/BibleApp.css

echo \"use strict\"\; > ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/AppViewController.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/CodexView.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/HistoryView.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/QuestionsView.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/SearchView.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/StatusBar.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/TableContentsView.js >> ../BibleAppXDK/www/js/BibleApp.js

cat ../Library/gui/icons/drawQuestionsIcon.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/icons/drawSearchIcon.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/icons/drawSendIcon.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/icons/drawSettingsIcon.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/gui/icons/drawTOCIcon.js >> ../BibleAppXDK/www/js/BibleApp.js

cat ../Library/io/CommonIO.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/io/CordovaFileReader.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/io/CordovaFileWriter.js >> ../BibleAppXDK/www/js/BibleApp.js

cat ../Library/manufacture/AssetBuilder.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/AssetChecker.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/AssetController.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/AssetLoader.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/AssetType.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/ChapterBuilder.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/ConcordanceBuilder.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/DOMBuilder.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/HTMLBuilder.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/StyleIndexBuilder.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/TOCBuilder.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/manufacture/WordCountBuilder.js >> ../BibleAppXDK/www/js/BibleApp.js

cat ../Library/model/meta/BibleCache.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/Canon.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/Concordance.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/History.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/HistoryItem.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/Lookup.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/QuestionItem.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/Questions.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/Reference.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/TOC.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/TOCBook.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/StyleIndex.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/meta/VerseAccessor.js >> ../BibleAppXDK/www/js/BibleApp.js

cat ../Library/model/usx/Book.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/usx/Chapter.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/usx/Char.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/usx/Note.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/usx/Para.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/usx/Text.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/usx/USX.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/model/usx/Verse.js >> ../BibleAppXDK/www/js/BibleApp.js

cat ../Library/util/DateTimeFormatter.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/util/Performance.js >> ../BibleAppXDK/www/js/BibleApp.js

cat ../Library/xml/USXParser.js >> ../BibleAppXDK/www/js/BibleApp.js
cat ../Library/xml/XMLTokenizer.js >> ../BibleAppXDK/www/js/BibleApp.js

