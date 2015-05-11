#!/bin/sh
cat ../Library/gui/AppViewController.js > js/BibleApp.js
cat ../Library/gui/TableContentsView.js >> js/BibleApp.js
cat ../Library/gui/CodexView.js >> js/BibleApp.js
cat ../Library/gui/SearchView.js >> js/BibleApp.js

cat ../Library/model/meta/Canon.js >> js/BibleApp.js
cat ../Library/model/meta/Reference.js >> js/BibleApp.js
cat ../Library/model/meta/BibleCache.js >> js/BibleApp.js
cat ../Library/model/meta/Concordance.js >> js/BibleApp.js
cat ../Library/model/meta/TOC.js >> js/BibleApp.js
cat ../Library/model/meta/TOCBook.js >> js/BibleApp.js
cat ../Library/model/meta/StyleIndex.js >> js/BibleApp.js
cat ../Library/model/meta/History.js >> js/BibleApp.js
cat ../Library/model/meta/HistoryItem.js >> js/BibleApp.js

cat ../Library/io/CommonIO.js >> js/BibleApp.js
cat ../Library/io/NodeFileReader.js >> js/BibleApp.js
cat ../Library/io/NodeFileWriter.js >> js/BibleApp.js

cat ../Library/xml/USXParser.js >> js/BibleApp.js
cat ../Library/xml/XMLTokenizer.js >> js/BibleApp.js

cat ../Library/manufacture/AssetType.js >> js/BibleApp.js
cat ../Library/manufacture/AssetController.js >> js/BibleApp.js
cat ../Library/manufacture/AssetChecker.js >> js/BibleApp.js
cat ../Library/manufacture/AssetBuilder.js >> js/BibleApp.js
cat ../Library/manufacture/TOCBuilder.js >> js/BibleApp.js
cat ../Library/manufacture/ConcordanceBuilder.js >> js/BibleApp.js
cat ../Library/manufacture/StyleIndexBuilder.js >> js/BibleApp.js
cat ../Library/manufacture/ChapterBuilder.js >> js/BibleApp.js

cat ../Library/manufacture/AssetLoader.js >> js/BibleApp.js
cat ../Library/manufacture/DOMBuilder.js >> js/BibleApp.js

cat ../Library/model/usx/USX.js >> js/BibleApp.js
cat ../Library/model/usx/Book.js >> js/BibleApp.js
cat ../Library/model/usx/Chapter.js >> js/BibleApp.js
cat ../Library/model/usx/Para.js >> js/BibleApp.js
cat ../Library/model/usx/Verse.js >> js/BibleApp.js
cat ../Library/model/usx/Note.js >> js/BibleApp.js
cat ../Library/model/usx/Char.js >> js/BibleApp.js
cat ../Library/model/usx/Text.js >> js/BibleApp.js

cat ../Library/util/Performance.js >> js/BibleApp.js

#cat ../Library/manufacture/HTMLBuilder.js >> js/BibleApp.js

npm start