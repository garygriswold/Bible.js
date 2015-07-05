#!/bin/sh
echo \"use strict\"\; > Publisher.js
cat ../Library/manufacture/AssetController.js >> Publisher.js
cat ../Library/manufacture/AssetType.js >> Publisher.js
cat ../Library/manufacture/AssetChecker.js >> Publisher.js
cat ../Library/manufacture/AssetBuilder.js >> Publisher.js
cat ../Library/manufacture/AssetLoader.js >> Publisher.js
cat ../Library/manufacture/ChapterBuilder.js >> Publisher.js
cat ../Library/manufacture/TOCBuilder.js >> Publisher.js
cat ../Library/manufacture/ConcordanceBuilder.js >> Publisher.js
cat ../Library/manufacture/HistoryBuilder.js >> Publisher.js
cat ../Library/manufacture/StyleIndexBuilder.js >> Publisher.js
cat ../Library/manufacture/StyleUseBuilder.js >> Publisher.js
cat ../Library/manufacture/HTMLBuilder.js >> Publisher.js
cat ../Library/model/usx/USX.js >> Publisher.js
cat ../Library/model/usx/Book.js >> Publisher.js
cat ../Library/model/usx/Chapter.js >> Publisher.js
cat ../Library/model/usx/Para.js >> Publisher.js
cat ../Library/model/usx/Verse.js >> Publisher.js
cat ../Library/model/usx/Note.js >> Publisher.js
cat ../Library/model/usx/Char.js >> Publisher.js
cat ../Library/model/usx/Text.js >> Publisher.js
cat ../Library/xml/XMLTokenizer.js >> Publisher.js
cat ../Library/xml/USXParser.js >> Publisher.js
cat ../Library/model/meta/Canon.js >> Publisher.js
cat ../Library/model/meta/TOC.js >> Publisher.js
cat ../Library/model/meta/TOCBook.js >> Publisher.js
cat ../Library/model/meta/Concordance.js >> Publisher.js
cat ../Library/model/meta/History.js >> Publisher.js
cat ../Library/io/CommonIO.js >> Publisher.js
cat ../Library/io/NodeFileReader.js >> Publisher.js
cat ../Library/io/NodeFileWriter.js >> Publisher.js
cat ../Library/io/DeviceDatabase.js >> Publisher.js
cat ../Library/io/DeviceCollection.js >> Publisher.js
cat ../Library/manufacture/AssetControllerTest.js >> Publisher.js
#node Publisher.js
npm start