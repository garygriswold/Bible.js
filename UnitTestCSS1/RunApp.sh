#!/bin/sh

cat ../Prep/model/usx/USX.js > www/js/BibleApp.js
cat ../Prep/model/usx/Book.js >> www/js/BibleApp.js
cat ../Prep/model/usx/Chapter.js >> www/js/BibleApp.js
cat ../Prep/model/usx/Para.js >> www/js/BibleApp.js
cat ../Prep/model/usx/Verse.js >> www/js/BibleApp.js
cat ../Prep/model/usx/Note.js >> www/js/BibleApp.js
cat ../Prep/model/usx/Char.js >> www/js/BibleApp.js
cat ../Prep/model/usx/Text.js >> www/js/BibleApp.js
cat ../Prep/xml/XMLTokenizer.js >> www/js/BibleApp.js
cat ../Prep/xml/USXParser.js >> www/js/BibleApp.js
cat ../Prep/visitors/DOMBuilder.js >> www/js/BibleApp.js
cordova build ios
cordova emulate ios