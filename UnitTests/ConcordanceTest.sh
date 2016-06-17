#!/bin/sh

echo \"use strict\"\; > temp.js
cat ../Library/model/meta/Concordance.js >> temp.js
cat ../Library/io/ConcordanceAdapter.js >> temp.js
cat ../Library/io/DatabaseHelper.js >> temp.js
cat ../Library/io/IOError.js >> temp.js
cat ConcordanceTest.js >> temp.js
npm start
