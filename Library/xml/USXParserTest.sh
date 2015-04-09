#!/bin/sh
cat ../model/usx/USX.js > temp.js
cat ../model/usx/Book.js >> temp.js
cat ../model/usx/Chapter.js >> temp.js
cat ../model/usx/Para.js >> temp.js
cat ../model/usx/Verse.js >> temp.js
cat ../model/usx/Note.js >> temp.js
cat ../model/usx/Char.js >> temp.js
cat ../model/usx/Text.js >> temp.js
cat XMLTokenizer.js >> temp.js
cat USXParser.js >> temp.js
cat USXParserTest.js >> temp.js
node temp.js

