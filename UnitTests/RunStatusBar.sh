#!/bin/sh
cat ../Library/gui/StatusBar.js > ../BibleAppNW/js/BibleApp.js
cat ../Library/gui/AppViewController.js >> ../BibleAppNW/js/BibleApp.js
cd ../BibleAppNW
npm start
