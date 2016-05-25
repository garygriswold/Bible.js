#!/bin/sh
echo \"use strict\"\; > temp.js
cat XMLTokenizer.js >> temp.js
cat XMLTokenizerTest.js >> temp.js
node temp.js