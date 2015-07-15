#!/bin/sh

echo \"use strict\"\; > www/BibleServer.js
cat ../Library/server/BibleServer.js >> www/BibleServer.js
node www/BibleServer.js