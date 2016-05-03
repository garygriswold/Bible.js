#!/bin/sh

node js/LoadVersions.js

cp Versions.db "$HOME/Library/Application Support/BibleAppNW/databases/file__0/2"

cp Versions.db ../YourBible/www
