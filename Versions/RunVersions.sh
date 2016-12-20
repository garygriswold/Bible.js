#!/bin/sh -v

sqlite3 Versions.db < Versions.sql

node js/VersionAdapter.js
node js/InstallVersions.js
node js/VersionIdentity.js

cp Versions.db "$HOME/Library/Application Support/BibleAppNW/databases/file__0/9"

cp Versions.db ../YourBible/www/Versions.db
