#!/bin/sh

if [ -z "$1" ]; then
	echo "Usage: HTMLValidator.sh VERSION";
	exit 1;
fi

VERSION=$1;
DB_PATH=../../DBL/3prepared/${VERSION}.db;

echo ${DB_PATH}

sqlite3 ${DB_PATH} <<END_SQL
.output output/verses.txt
select reference, html from verses;
END_SQL

echo \"use strict\"\; > temp.js
cat ../Library/model/meta/Canon.js >> temp.js
cat ../Library/xml/XMLTokenizer.js >> temp.js
cat js/HTMLValidator.js >> temp.js

node temp.js $1

diff -w output/chapters.txt output/verses.txt

# -b displays errors of extra space in the verse text
# no option shows even more errors
