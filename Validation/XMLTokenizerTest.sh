#!/bin/sh
echo \"use strict\"\; > temp.js
cat ../Library/xml/XMLTokenizer.js >> temp.js
cat js/XMLTokenizerTest.js >> temp.js
node temp.js $1