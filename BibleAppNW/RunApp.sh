#!/bin/sh

cat ../Prep/model/usx/USX.js > js/BibleApp.js
cat ../Prep/model/usx/Book.js >> js/BibleApp.js
cat ../Prep/model/usx/Chapter.js >> js/BibleApp.js
cat ../Prep/model/usx/Para.js >> js/BibleApp.js
cat ../Prep/model/usx/Verse.js >> js/BibleApp.js
cat ../Prep/model/usx/Note.js >> js/BibleApp.js
cat ../Prep/model/usx/Char.js >> js/BibleApp.js
cat ../Prep/model/usx/Text.js >> js/BibleApp.js
cat ../Prep/xml/XMLTokenizer.js >> js/BibleApp.js
cat ../Prep/xml/USXParser.js >> js/BibleApp.js
car ../Prep/io/NodeFileReader.js >> js/BibleApp.js
cat ../Prep/visitors/DOMBuilder.js >> js/BibleApp.js
cordova build ios
cordova emulate ios