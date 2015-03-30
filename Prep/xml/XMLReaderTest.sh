#!/bin/sh
cat XMLReader.js > temp.js
cat XMLWriter.js >> temp.js
cat XMLReaderTest.js >> temp.js
node temp.js