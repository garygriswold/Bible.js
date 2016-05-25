#!/bin/sh
echo \"use strict\"\; > Validator.js
cat ../Library/model/meta/Canon.js >> Validator.js
cat ConcordanceValidator.js >> Validator.js

node Validator.js $*
