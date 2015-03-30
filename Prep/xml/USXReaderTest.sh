#!/bin/sh
cat USXReader.js > temp.js
cat ../model/USX.js >> temp.js
cat ../model/Book.js >> temp.js
cat ../model/Chapter.js >> temp.js
cat ../model/Para.js >> temp.js
cat ../model/Verse.js >> temp.js
cat ../model/Note.js >> temp.js
cat ../model/Char.js >> temp.js
cat ../model/Text.js >> temp.js
cat USXReaderTest.js >> temp.js
node temp.js

