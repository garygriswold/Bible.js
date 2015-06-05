#!/bin/sh

echo \"use strict\"\; > temp.js
cat ../Library/manufacture/AssetType.js >> temp.js
cat ../Library/io/CommonIO.js >> temp.js
cat ../Library/io/NodeFileReader.js >> temp.js
cat ../Library/io/NodeFileWriter.js >> temp.js
cat ../Library/model/meta/QuestionItem.js >> temp.js
cat ../Library/model/meta/Questions.js >> temp.js
cat QuestionsTest.js >> temp.js
node temp.js