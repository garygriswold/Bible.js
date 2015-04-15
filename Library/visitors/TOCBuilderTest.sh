#!/bin/sh
cat ../model/usx/USX.js > temp.js
cat ../model/usx/Book.js >> temp.js
cat ../model/usx/Chapter.js >> temp.js
cat ../model/usx/Para.js >> temp.js
cat ../model/usx/Verse.js >> temp.js
cat ../model/usx/Note.js >> temp.js
cat ../model/usx/Char.js >> temp.js
cat ../model/usx/Text.js >> temp.js
cat ../xml/XMLTokenizer.js >> temp.js
cat ../xml/USXParser.js >> temp.js
cat ../model/meta/TOC.js >> temp.js
cat ../model/meta/TOCBook.js >> temp.js
cat ../io/CommonIO.js >> temp.js
cat TOCBuilder.js >> temp.js
cat TOCBuilderTest.js >> temp.js
node temp.js