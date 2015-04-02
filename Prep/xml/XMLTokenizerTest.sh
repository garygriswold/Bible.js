#!/bin/sh
cat XMLTokenizer.js > temp.js
cat XMLSerializer.js >> temp.js
cat XMLTokenizerTest.js >> temp.js
node temp.js