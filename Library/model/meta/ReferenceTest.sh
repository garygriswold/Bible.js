#!/bin/sh

cat Reference.js > temp.js
cat ReferenceTest.js >> temp.js
node temp.js
