#!/bin/sh
cat ../Library/model/usx/USX.js > js/BibleApp.js
cat ../Library/model/usx/Book.js >> js/BibleApp.js
cat ../Library/model/usx/Chapter.js >> js/BibleApp.js
cat ../Library/model/usx/Para.js >> js/BibleApp.js
cat ../Library/model/usx/Verse.js >> js/BibleApp.js
cat ../Library/model/usx/Note.js >> js/BibleApp.js
cat ../Library/model/usx/Char.js >> js/BibleApp.js
cat ../Library/model/usx/Text.js >> js/BibleApp.js
cat ../Library/xml/XMLTokenizer.js >> js/BibleApp.js
cat ../Library/xml/USXParser.js >> js/BibleApp.js
cat ../Library/io/NodeFileReader.js >> js/BibleApp.js
cat ../Library/io/NodeFileWriter.js >> js/BibleApp.js
cat ../Library/visitors/DOMBuilder.js >> js/BibleApp.js
cat ../Library/visitors/HTMLBuilder.js >> js/BibleApp.js
cat ../Library/gui/CodexGUI.js >> js/BibleApp.js
npm start