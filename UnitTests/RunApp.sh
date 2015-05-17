#!/bin/sh
cat ../Library/gui/AppViewController.js > ../BibleAppNW/js/BibleApp.js
cat ../Library/gui/TableContentsView.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/gui/CodexView.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/gui/SearchView.js >> ../BibleAppNW/js/BibleApp.js

cat ../Library/model/meta/Canon.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/meta/Reference.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/meta/BibleCache.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/meta/Concordance.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/meta/TOC.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/meta/TOCBook.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/meta/StyleIndex.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/meta/History.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/meta/HistoryItem.js >> ../BibleAppNW/js/BibleApp.js

cat ../Library/io/CommonIO.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/io/NodeFileReader.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/io/NodeFileWriter.js >> ../BibleAppNW/js/BibleApp.js

cat ../Library/xml/USXParser.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/xml/XMLTokenizer.js >> ../BibleAppNW/js/BibleApp.js

cat ../Library/manufacture/AssetType.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/manufacture/AssetController.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/manufacture/AssetChecker.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/manufacture/AssetBuilder.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/manufacture/TOCBuilder.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/manufacture/ConcordanceBuilder.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/manufacture/WordCountBuilder.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/manufacture/StyleIndexBuilder.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/manufacture/ChapterBuilder.js >> ../BibleAppNW/js/BibleApp.js

cat ../Library/manufacture/AssetLoader.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/manufacture/DOMBuilder.js >> ../BibleAppNW/js/BibleApp.js

cat ../Library/model/usx/USX.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/usx/Book.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/usx/Chapter.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/usx/Para.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/usx/Verse.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/usx/Note.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/usx/Char.js >> ../BibleAppNW/js/BibleApp.js
cat ../Library/model/usx/Text.js >> ../BibleAppNW/js/BibleApp.js

cat ../Library/util/Performance.js >> ../BibleAppNW/js/BibleApp.js

#cat ../Library/manufacture/HTMLBuilder.js >> ../BibleAppNW/js/BibleApp.js

cd ../BibleAppNW

npm start
