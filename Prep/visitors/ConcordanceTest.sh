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
cat ../model/meta/Concordance.js >> temp.js
cat ConcordanceVisitor.js >> temp.js
cat ConcordanceTest.js >> temp.js
node temp.js
