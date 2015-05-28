#!/bin/sh
echo \"use strict\"\; > temp.js
cat Reference.js >> temp.js
cat ReferenceTest.js >> temp.js
node temp.js
