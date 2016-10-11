#!/bin/sh
STDOUT=output/$1/xml/XMLTokenizerTest.out
echo \"use strict\"\; > temp.js
cat ../Library/util/Directory.js >> temp.js
cat ../Library/xml/XMLTokenizer.js >> temp.js
cat js/XMLTokenizerTest.js >> temp.js
node temp.js $* > $STDOUT
cat $STDOUT